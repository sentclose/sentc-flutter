import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:sentc_light/src/generated.dart';
import 'package:sentc_light/src/user.dart';
import 'package:sentc_common/sentc_common.dart' as common;

enum RefreshOption { cookie, cookieFn, api }

class RefreshOptions {
  RefreshOption endpoint;
  String? endpointUrl;
  Future<String> Function(String oldJwt)? endpointFn;

  RefreshOptions({required this.endpoint, this.endpointUrl, this.endpointFn});
}

class SentcError {
  String status;
  String errorMessage;

  SentcError({required this.status, required this.errorMessage});

  Map<String, dynamic> toJson() => <String, dynamic>{'error_message': errorMessage, 'status': status};

  factory SentcError.fromJson(Map<String, dynamic> json) => SentcError(
        status: json['status'],
        errorMessage: json['error_message'],
      );

  factory SentcError.fromError(Object e) {
    return SentcError.fromException(e as FfiException);
  }

  factory SentcError.fromException(FfiException e) {
    return SentcError.fromJson(jsonDecode(e.message));
  }
}

class Sentc {
  static SentcFlutterRustLightImpl? _api;
  static common.StorageInterface? _storage;

  static String baseUrl = "";
  static String appToken = "";

  static RefreshOption refreshEndpoint = RefreshOption.api;
  static Future<String> Function(String oldJwt) _endpointFn = (String oldJwt) async {
    return "";
  };

  const Sentc._();

  static Future<User?> init({
    String? baseUrl,
    required String appToken,
    RefreshOptions? refreshOptions,
    common.StorageInterface? storage,
  }) async {
    if (_api != null) {
      //no Init, only once
      try {
        return await getActualUser(jwt: true);
      } catch (e) {
        return null;
      }
    }

    //load the ffi lib
    const base = "sentc_light_flutter";
    final path = Platform.isWindows ? "$base.dll" : "lib$base.so";
    late final dylib = Platform.isIOS
        ? DynamicLibrary.process()
        : Platform.isMacOS
            ? DynamicLibrary.executable()
            : DynamicLibrary.open(path);

    final SentcFlutterRustLightImpl api = SentcFlutterRustLightImpl(dylib);
    Sentc.baseUrl = baseUrl ?? "https://api.sentc.com";

    RefreshOption refreshEndpoint = refreshOptions != null ? refreshOptions.endpoint : RefreshOption.api;

    var refreshEndpointFn = refreshOptions != null
        ? refreshOptions.endpointFn ??
            (String oldJwt) async {
              return "";
            }
        : (String oldJwt) async {
            return "";
          };

    _api = api;
    Sentc.appToken = appToken;
    Sentc.refreshEndpoint = refreshEndpoint;
    _endpointFn = refreshEndpointFn;

    _storage = storage ?? common.SharedPreferencesStorage();
    await _storage!.init();

    try {
      final user = await getActualUser();

      if (refreshEndpoint == RefreshOption.api) {
        //do init only when refresh endpoint is api
        final out = await getApi().initUser(
          baseUrl: Sentc.baseUrl,
          authToken: Sentc.appToken,
          jwt: user.jwt,
          refreshToken: user.refreshToken,
        );

        user.jwt = out.jwt;
        user.groupInvites = out.invites;
      } else {
        //do normal refresh (maybe with another strategy)
        await user.getJwt();

        return user;
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  static common.StorageInterface getStorage() {
    return _storage!;
  }

  static SentcFlutterRustLightImpl getApi() {
    return _api ?? (throw Exception("Not init"));
  }

  static Future<User> getActualUser({bool? jwt}) async {
    final storage = Sentc.getStorage();

    final actualUser = await storage.getItem("actual_user");

    if (actualUser == null) {
      throw Exception("No actual user found");
    }

    final userJson = await storage.getItem("user_data_$actualUser");

    if (userJson == null) {
      throw Exception("The actual user data was not found");
    }

    final user = User.fromJson(jsonDecode(userJson), baseUrl, appToken);

    if (jwt ?? false) {
      await user.getJwt();
    }

    return user;
  }

  //____________________________________________________________________________________________________________________

  static Future<bool> checkUserIdentifierAvailable(String userIdentifier) {
    if (userIdentifier == "") {
      return Future(() => false);
    }

    return getApi().checkUserIdentifierAvailable(
      baseUrl: baseUrl,
      authToken: appToken,
      userIdentifier: userIdentifier,
    );
  }

  static Future<GeneratedRegisterData> generateRegisterData() async {
    return getApi().generateUserRegisterData();
  }

  static Future<String> prepareRegister(String userIdentifier, String password) {
    if (userIdentifier == "" || password == "") {
      throw const FormatException();
    }

    return getApi().prepareRegister(userIdentifier: userIdentifier, password: password);
  }

  static Future<String> doneRegister(String serverOutput) {
    return getApi().doneRegister(serverOutput: serverOutput);
  }

  static Future<String> register(String userIdentifier, String password) {
    if (userIdentifier == "" || password == "") {
      throw const FormatException();
    }

    return getApi().register(
      baseUrl: baseUrl,
      authToken: appToken,
      password: password,
      userIdentifier: userIdentifier,
    );
  }

  static Future<void> doneRegisterDeviceStart(String serverOutput) {
    return getApi().doneRegisterDeviceStart(serverOutput: serverOutput);
  }

  static Future<String> registerDeviceStart(String deviceIdentifier, String password) {
    if (deviceIdentifier == "" || password == "") {
      throw const FormatException();
    }

    return getApi().registerDeviceStart(
      baseUrl: baseUrl,
      authToken: appToken,
      deviceIdentifier: deviceIdentifier,
      password: password,
    );
  }

  //____________________________________________________________________________________________________________________
  //login

  static Future<User> loginForced(String deviceIdentifier, String password) async {
    final out = await getApi().login(
      baseUrl: baseUrl,
      authToken: appToken,
      userIdentifier: deviceIdentifier,
      password: password,
    );

    if (out.mfa != null) {
      throw Exception("User enabled mfa and this must be handled.");
    }

    return getUser(deviceIdentifier, out.userData!, false);
  }

  static Future<LoginUser> login(String deviceIdentifier, String password) async {
    final out = await getApi().login(
      baseUrl: baseUrl,
      authToken: appToken,
      userIdentifier: deviceIdentifier,
      password: password,
    );

    if (out.mfa != null) {
      return MfaLogin(UserMfaLogin(
        masterKey: out.mfa!.masterKey,
        authKey: out.mfa!.authKey,
        deviceIdentifier: deviceIdentifier,
      ));
    }

    return UserLogin(await getUser(deviceIdentifier, out.userData!, false));
  }

  static Future<User> mfaLogin(String token, UserMfaLogin loginData) async {
    final out = await getApi().mfaLogin(
      baseUrl: baseUrl,
      authToken: appToken,
      masterKeyEncryption: loginData.masterKey,
      authKey: loginData.authKey,
      userIdentifier: loginData.deviceIdentifier,
      token: token,
      recovery: false,
    );

    return getUser(loginData.deviceIdentifier, out, true);
  }

  static Future<User> mfaRecoveryLogin(String recoveryToken, UserMfaLogin loginData) async {
    final out = await getApi().mfaLogin(
      baseUrl: baseUrl,
      authToken: appToken,
      masterKeyEncryption: loginData.masterKey,
      authKey: loginData.authKey,
      userIdentifier: loginData.deviceIdentifier,
      token: recoveryToken,
      recovery: true,
    );

    return getUser(loginData.deviceIdentifier, out, true);
  }

  //____________________________________________________________________________________________________________________

  static Future<String> refreshJwt(String oldJwt, String refreshToken) {
    if (refreshEndpoint == RefreshOption.api) {
      return getApi().refreshJwt(baseUrl: baseUrl, authToken: appToken, jwt: oldJwt, refreshToken: refreshToken);
    }

    if (refreshEndpoint == RefreshOption.cookieFn) {
      return _endpointFn(oldJwt);
    }

    throw UnimplementedError();
  }
}

//______________________________________________________________________________________________________________________

typedef UserLogin = common.UserLogin<User>;

typedef MfaLogin = common.MfaLogin;

typedef UserMfaLogin = common.UserMfaLogin;

typedef LoginUser = common.LoginUser;
