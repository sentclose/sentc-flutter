import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:sentc/src/generated.dart';
import 'package:sentc/src/storage/shared_preferences_storage.dart';
import 'package:sentc/src/storage/storage_interface.dart';
import 'package:sentc/src/user.dart';

enum REFRESH_OPTIONS { cookie, cookie_fn, api }

class RefreshOptions {
  REFRESH_OPTIONS endpoint;
  String? endpoint_url;
  Future<String> Function(String old_jwt)? endpoint_fn;

  RefreshOptions({required this.endpoint, this.endpoint_url, this.endpoint_fn});
}

class Sentc {
  static SentcFlutterImpl? _api;
  static StorageInterface? _storage;

  static String baseUrl = "";
  static String appToken = "";
  static REFRESH_OPTIONS refresh_endpoint = REFRESH_OPTIONS.api;
  static String _refresh_endpoint_url = "";
  static Future<String> Function(String old_jwt) _endpoint_fn = (String old_jwt) async {
    return "";
  };
  static String? file_part_url;

  const Sentc._();

  static Future<User?> init({
    String? base_url,
    required String app_token,
    String? file_part_url,
    RefreshOptions? refresh_options,
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
    baseUrl = base_url ?? "https://api.sentc.com";

    REFRESH_OPTIONS _refresh_endpoint = refresh_options != null ? refresh_options.endpoint : REFRESH_OPTIONS.api;

    String refresh_endpoint_url =
        refresh_options != null ? refresh_options.endpoint_url ?? "/api/v1/refresh" : "/api/v1/refresh";

    var refresh_endpoint_fn = refresh_options != null
        ? refresh_options.endpoint_fn ??
            (String old_jwt) async {
              return "";
            }
        : (String old_jwt) async {
            return "";
          };

    _api = api;
    appToken = app_token;
    refresh_endpoint = _refresh_endpoint;
    _refresh_endpoint_url = refresh_endpoint_url;
    _endpoint_fn = refresh_endpoint_fn;
    Sentc.file_part_url = file_part_url;

    _storage = storage ?? SharedPreferencesStorage();
    await _storage!.init();

    try {
      final user = await getActualUser();

      if (refresh_endpoint == REFRESH_OPTIONS.api) {
        //do init only when refresh endpoint is api
        final out = await getApi().initUser(
          baseUrl: baseUrl,
          authToken: app_token,
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

  static Future<String> prepareLoginStart(String userIdentifier) {
    return getApi().prepareLoginStart(baseUrl: baseUrl, authToken: appToken, userIdentifier: userIdentifier);
  }

  static Future<PrepareLoginOutput> prepareLogin(
    String userIdentifier,
    String password,
    String prepare_login_server_output,
  ) {
    return getApi().prepareLogin(
      userIdentifier: userIdentifier,
      password: password,
      serverOutput: prepare_login_server_output,
    );
  }

  static Future<User> doneLogin(
    String deviceIdentifier,
    String master_key_encryption_key,
    String done_login_server_output,
  ) async {
    final out = await getApi().doneLogin(
      masterKeyEncryption: master_key_encryption_key,
      serverOutput: done_login_server_output,
    );

    return getUser(deviceIdentifier, out);
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

    final k = PublicKeyData(fetchedKey.publicKey, fetchedKey.publicKeyId);

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
    if (refresh_endpoint == REFRESH_OPTIONS.api) {
      return getApi().refreshJwt(baseUrl: baseUrl, authToken: appToken, jwt: oldJwt, refreshToken: refreshToken);
    }

    if (refresh_endpoint == REFRESH_OPTIONS.cookie_fn) {
      return _endpoint_fn(oldJwt);
    }

    throw UnimplementedError();
  }

  static Future<PublicKeyData> getGroupPublicKeyData(String groupId) async {
    final storage = Sentc.getStorage();
    final key = await storage.getItem("group_public_key_$groupId");

    if (key != null) {
      return PublicKeyData.fromJson(jsonDecode(key));
    }

    final fetchedKey = await getApi().groupGetPublicKeyData(baseUrl: baseUrl, authToken: appToken, id: groupId);

    final k = PublicKeyData(fetchedKey.publicKeyId, fetchedKey.publicKey);

    await storage.set("group_public_key_$groupId", jsonEncode(k));

    return k;
  }
}

//______________________________________________________________________________________________________________________

class PublicKeyData {
  final String id;
  final String key;

  PublicKeyData(this.id, this.key);

  PublicKeyData.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        key = json["key"];

  Map<String, dynamic> toJson() {
    return {"id": id, "key": key};
  }
}
