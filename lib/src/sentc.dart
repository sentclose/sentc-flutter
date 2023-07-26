import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:sentc/src/generated.dart';
import 'package:sentc/src/storage/shared_preferences_storage.dart';
import 'package:sentc/src/storage/storage_interface.dart';
import 'package:sentc/src/user.dart';

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
  static SentcFlutterImpl? _api;
  static StorageInterface? _storage;

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
    StorageInterface? storage,
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
    const base = "sentc_flutter";
    final path = Platform.isWindows ? "$base.dll" : "lib$base.so";
    late final dylib = Platform.isIOS
        ? DynamicLibrary.process()
        : Platform.isMacOS
            ? DynamicLibrary.executable()
            : DynamicLibrary.open(path);

    final SentcFlutterImpl api = SentcFlutterImpl(dylib);
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
    Sentc.filePartUrl = filePartUrl;

    _storage = storage ?? SharedPreferencesStorage();
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

  static StorageInterface getStorage() {
    return _storage!;
  }

  static SentcFlutterImpl getApi() {
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

  //________________________________________________________________________________________________

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

  static Future<String> prepareCheckUserIdentifierAvailable(String userIdentifier) {
    return getApi().prepareCheckUserIdentifierAvailable(userIdentifier: userIdentifier);
  }

  static Future<bool> doneCheckUserIdentifierAvailable(String serverOutput) {
    return getApi().doneCheckUserIdentifierAvailable(serverOutput: serverOutput);
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

  static Future<String> prepareRegisterDeviceStart(String deviceIdentifier, String password) {
    if (deviceIdentifier == "" || password == "") {
      throw const FormatException();
    }

    return getApi().prepareRegisterDeviceStart(
      deviceIdentifier: deviceIdentifier,
      password: password,
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

  static Future<User> login(
    String deviceIdentifier,
    String password,
  ) async {
    final out = await getApi().login(
      baseUrl: baseUrl,
      authToken: appToken,
      userIdentifier: deviceIdentifier,
      password: password,
    );

    return getUser(deviceIdentifier, out);
  }

  //________________________________________________________________________________________________

  static Future<PublicKeyData> getUserPublicKey(String userId) async {
    final storage = Sentc.getStorage();

    final key = await storage.getItem("user_public_key_$userId");

    if (key != null) {
      return PublicKeyData.fromJson(jsonDecode(key));
    }

    final fetchedKey = await getApi().userFetchPublicKey(baseUrl: baseUrl, authToken: appToken, userId: userId);

    final k = PublicKeyData(fetchedKey.publicKey, fetchedKey.publicKeyId, fetchedKey.publicKeySigKeyId, false);

    await storage.set("user_public_key_$userId", jsonEncode(k));

    return k;
  }

  static Future<String> getUserVerifyKey(String userId, String verifyKeyId) async {
    final storage = Sentc.getStorage();

    final key = await storage.getItem("user_verify_key_${userId}_$verifyKeyId");

    if (key != null) {
      return key;
    }

    final fetchedKey = await getApi().userFetchVerifyKey(
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
      return getApi().refreshJwt(baseUrl: baseUrl, authToken: appToken, jwt: oldJwt, refreshToken: refreshToken);
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

    final fetchedKey = await getApi().groupGetPublicKeyData(baseUrl: baseUrl, authToken: appToken, id: groupId);

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

    final verify = await getApi().userVerifyUserPublicKey(verifyKey: verifyKey, publicKey: publicKey.publicKey);

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
