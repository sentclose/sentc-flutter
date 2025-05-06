import 'dart:convert';
import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:sentc/sentc.dart';
import 'package:sentc/src/rust/api/user.dart' as api_user;
import 'package:sentc/src/rust/api/group.dart' as api_group;
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
    if (e is String) {
      return SentcError.fromJson(jsonDecode(e));
    }

    if (e is AnyhowException) {
      return SentcError.fromAnyhowException(e);
    }

    if (e is FrbException) {
      return SentcError.fromFfiException(e);
    }

    return SentcError(status: "client_0", errorMessage: "Unknown exception object: ${e.toString()}");
  }

  factory SentcError.fromAnyhowException(AnyhowException e) {
    return SentcError.fromJson(jsonDecode(e.message));
  }

  factory SentcError.fromFfiException(FrbException e) {
    return SentcError.fromJson(jsonDecode(e.toString()));
  }
}

_loadLib() async {
  if (RustLib.instance.initialized) {
    return;
  }

  /*
  String? ioDirectory;

  if (Platform.isWindows) {
    if (Abi.current() == Abi.windowsX64) {
      ioDirectory = "windows-x64/";
    } else if (Abi.current() == Abi.windowsArm64) {
      throw UnsupportedError('Unsupported Windows architecture: ${Abi.current()}');
    } else {
      throw UnsupportedError('Unsupported Windows architecture: ${Abi.current()}');
    }
  } else if (Platform.isLinux) {
    if (Abi.current() == Abi.linuxX64) {
      ioDirectory = "linux-x64/";
    } else if (Abi.current() == Abi.linuxArm64) {
      ioDirectory = "linux-arm64/";
    } else {
      throw UnsupportedError('Unsupported Linux architecture: ${Abi.current()}');
    }
  }
   */

  ExternalLibrary lib;
  if (Platform.isIOS || Platform.isMacOS) {
    lib = ExternalLibrary.process(iKnowHowToUseIt: true);
  } else {
    final libraryLoaderConfig = ExternalLibraryLoaderConfig(
      stem: RustLib.kDefaultExternalLibraryLoaderConfig.stem,
      ioDirectory: null,
      webPrefix: RustLib.kDefaultExternalLibraryLoaderConfig.webPrefix,
    );

    lib = await loadExternalLibrary(libraryLoaderConfig);
  }

  await RustLib.init(externalLibrary: lib);
}

class Sentc {
  static bool isInit = false;
  static common.StorageInterface? _storage;

  static String baseUrl = "";
  static String appToken = "";
  static RefreshOption refreshEndpoint = RefreshOption.api;
  static Future<String> Function(String oldJwt) _endpointFn = (String oldJwt) async {
    return "";
  };
  static String? filePartUrl;

  const Sentc._();

  static Future<User?> init({
    String? baseUrl,
    required String appToken,
    String? filePartUrl,
    RefreshOptions? refreshOptions,
    common.StorageInterface? storage,
  }) async {
    if (isInit) {
      try {
        return await getActualUser();
      } catch (e) {
        return null;
      }
    }

    //load the ffi lib
    await _loadLib();

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

    Sentc.appToken = appToken;
    Sentc.refreshEndpoint = refreshEndpoint;
    _endpointFn = refreshEndpointFn;
    Sentc.filePartUrl = filePartUrl;

    _storage = storage ?? common.SharedPreferencesStorage();
    await _storage!.init();

    try {
      final user = await getActualUser();

      if (refreshEndpoint == RefreshOption.api) {
        //do init only when refresh endpoint is api
        final out = await api_user.initUser(
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

  //________________________________________________________________________________________________

  static Future<bool> checkUserIdentifierAvailable(String userIdentifier) {
    if (userIdentifier == "") {
      return Future(() => false);
    }

    return api_user.checkUserIdentifierAvailable(
      baseUrl: baseUrl,
      authToken: appToken,
      userIdentifier: userIdentifier,
    );
  }

  static String prepareCheckUserIdentifierAvailable(String userIdentifier) {
    return api_user.prepareCheckUserIdentifierAvailable(userIdentifier: userIdentifier);
  }

  static bool doneCheckUserIdentifierAvailable(String serverOutput) {
    return api_user.doneCheckUserIdentifierAvailable(serverOutput: serverOutput);
  }

  static Future<api_user.GeneratedRegisterData> generateRegisterData() async {
    return api_user.generateUserRegisterData();
  }

  static Future<String> prepareRegister(String userIdentifier, String password) {
    if (userIdentifier == "" || password == "") {
      throw const FormatException();
    }

    return api_user.prepareRegister(userIdentifier: userIdentifier, password: password);
  }

  static String doneRegister(String serverOutput) {
    return api_user.doneRegister(serverOutput: serverOutput);
  }

  static Future<String> register(String userIdentifier, String password) {
    if (userIdentifier == "" || password == "") {
      throw const FormatException();
    }

    return api_user.register(
      baseUrl: baseUrl,
      authToken: appToken,
      password: password,
      userIdentifier: userIdentifier,
    );
  }

  static Future<String> prepareRegisterDeviceStart(String deviceIdentifier, String password) {
    if (deviceIdentifier == "" || password == "") {
      throw const FormatException();
    }

    return api_user.prepareRegisterDeviceStart(
      deviceIdentifier: deviceIdentifier,
      password: password,
    );
  }

  static doneRegisterDeviceStart(String serverOutput) {
    return api_user.doneRegisterDeviceStart(serverOutput: serverOutput);
  }

  static Future<String> registerDeviceStart(String deviceIdentifier, String password) {
    if (deviceIdentifier == "" || password == "") {
      throw const FormatException();
    }

    return api_user.registerDeviceStart(
      baseUrl: baseUrl,
      authToken: appToken,
      deviceIdentifier: deviceIdentifier,
      password: password,
    );
  }

  static Future<User> loginForced(String deviceIdentifier, String password) async {
    final out = await api_user.login(
      baseUrl: baseUrl,
      authToken: appToken,
      userIdentifier: deviceIdentifier,
      password: password,
    );

    if (out.masterKey != null || out.authKey != null) {
      throw Exception("User enabled mfa and this must be handled.");
    }

    final userData = await api_user.extractUserData(data: out.direct!);

    return getUser(deviceIdentifier, userData, false);
  }

  static Future<LoginUser> login(String deviceIdentifier, String password) async {
    final out = await api_user.login(
      baseUrl: baseUrl,
      authToken: appToken,
      userIdentifier: deviceIdentifier,
      password: password,
    );

    if (out.masterKey != null && out.authKey != null) {
      return MfaLogin(UserMfaLogin(
        masterKey: out.masterKey!,
        authKey: out.authKey!,
        deviceIdentifier: deviceIdentifier,
      ));
    }

    final userData = await api_user.extractUserData(data: out.direct!);

    return UserLogin(await getUser(deviceIdentifier, userData, false));
  }

  static Future<User> mfaLogin(String token, UserMfaLogin loginData) async {
    final out = await api_user.mfaLogin(
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
    final out = await api_user.mfaLogin(
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

  //________________________________________________________________________________________________

  static Future<PublicKeyData> getUserPublicKey(String userId) async {
    final storage = Sentc.getStorage();

    final key = await storage.getItem("user_public_key_$userId");

    if (key != null) {
      return PublicKeyData.fromJson(jsonDecode(key));
    }

    final fetchedKey = await api_user.userFetchPublicKey(baseUrl: baseUrl, authToken: appToken, userId: userId);

    final k = PublicKeyData(fetchedKey.publicKeyId, fetchedKey.publicKey, fetchedKey.publicKeySigKeyId, false);

    await storage.set("user_public_key_$userId", jsonEncode(k));

    return k;
  }

  static Future<String> getUserVerifyKey(String userId, String verifyKeyId) async {
    final storage = Sentc.getStorage();

    final key = await storage.getItem("user_verify_key_${userId}_$verifyKeyId");

    if (key != null) {
      return key;
    }

    final fetchedKey = await api_user.userFetchVerifyKey(
      baseUrl: baseUrl,
      authToken: appToken,
      userId: userId,
      verifyKeyId: verifyKeyId,
    );

    await storage.set("user_verify_key_${userId}_$verifyKeyId", fetchedKey);

    return fetchedKey;
  }

  static Future<String> refreshJwt(String oldJwt, String refreshToken) {
    if (refreshEndpoint == RefreshOption.api) {
      return api_user.refreshJwt(baseUrl: baseUrl, authToken: appToken, jwt: oldJwt, refreshToken: refreshToken);
    }

    if (refreshEndpoint == RefreshOption.cookieFn) {
      return _endpointFn(oldJwt);
    }

    throw UnimplementedError();
  }

  static Future<PublicGroupKeyData> getGroupPublicKeyData(String groupId) async {
    final storage = Sentc.getStorage();
    final key = await storage.getItem("group_public_key_$groupId");

    if (key != null) {
      return PublicGroupKeyData.fromJson(jsonDecode(key));
    }

    final fetchedKey = await api_group.groupGetPublicKeyData(baseUrl: baseUrl, authToken: appToken, id: groupId);

    final k = PublicGroupKeyData(fetchedKey.publicKeyId, fetchedKey.publicKey);

    await storage.set("group_public_key_$groupId", jsonEncode(k));

    return k;
  }

  static Future<bool> verifyUserPublicKey(String userId, PublicKeyData publicKey, [bool force = false]) async {
    if (publicKey.verified && !force) {
      return true;
    }

    if (publicKey.publicKeySigKeyId == null) {
      return false;
    }

    final verifyKey = await getUserVerifyKey(userId, publicKey.publicKeySigKeyId!);

    final verify = await api_user.userVerifyUserPublicKey(verifyKey: verifyKey, publicKey: publicKey.publicKey);

    publicKey.verified = verify;

    //store the new value
    final storage = Sentc.getStorage();
    await storage.set("user_public_key_$userId", jsonEncode(publicKey));

    return verify;
  }
}

//______________________________________________________________________________________________________________________

class PublicGroupKeyData {
  final String id;
  final String key;

  const PublicGroupKeyData(this.id, this.key);

  PublicGroupKeyData.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        key = json["key"];

  Map<String, dynamic> toJson() {
    return {"id": id, "key": key};
  }
}

class PublicKeyData {
  final String publicKeyId;
  final String publicKey;
  final String? publicKeySigKeyId;
  bool verified;

  PublicKeyData(this.publicKeyId, this.publicKey, this.publicKeySigKeyId, this.verified);

  PublicKeyData.fromJson(Map<String, dynamic> json)
      : publicKeyId = json["publicKeyId"],
        publicKey = json["publicKey"],
        publicKeySigKeyId = json["publicKeySigKeyId"],
        verified = json["verified"];

  Map<String, dynamic> toJson() {
    return {
      "publicKeyId": publicKeyId,
      "publicKey": publicKey,
      "verified": verified,
      "publicKeySigKeyId": publicKeySigKeyId
    };
  }
}

//______________________________________________________________________________________________________________________

typedef UserLogin = common.UserLogin<User>;

typedef MfaLogin = common.MfaLogin;

typedef UserMfaLogin = common.UserMfaLogin;

typedef LoginUser = common.LoginUser;
