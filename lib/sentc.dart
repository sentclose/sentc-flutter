import 'dart:ffi';
import 'dart:io';

import 'package:sentc/generated.dart';

enum REFRESH_OPTIONS { cookie, cookie_fn, api }

class RefreshOptions {
  REFRESH_OPTIONS endpoint;
  String? endpoint_url;
  Future<String> Function(String old_jwt)? endpoint_fn;

  RefreshOptions({required this.endpoint, this.endpoint_url, this.endpoint_fn});
}

class Sentc {
  static SentcFlutterImpl? _api;

  static String _base_url = "";
  static String _app_token = "";
  static REFRESH_OPTIONS _refresh_endpoint = REFRESH_OPTIONS.api;
  static String _refresh_endpoint_url = "";
  static Future<String> Function(String old_jwt) _endpoint_fn = (String old_jwt) async {
    return "";
  };

  const Sentc._();

  static Future<void> init({
    String? base_url,
    required String app_token,
    String? file_part_url,
    RefreshOptions? refresh_options,
  }) async {
    if (_api != null) {
      //no Init, only once
      return;
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
    base_url = base_url ?? "https://api.sentc.com";

    REFRESH_OPTIONS refresh_endpoint =
        refresh_options != null ? refresh_options.endpoint : REFRESH_OPTIONS.api;

    String refresh_endpoint_url = refresh_options != null
        ? refresh_options.endpoint_url ?? "/api/v1/refresh"
        : "/api/v1/refresh";

    var refresh_endpoint_fn = refresh_options != null
        ? refresh_options.endpoint_fn ??
            (String old_jwt) async {
              return "";
            }
        : (String old_jwt) async {
            return "";
          };

    _api = api;
    _app_token = app_token;
    _refresh_endpoint = refresh_endpoint;
    _refresh_endpoint_url = refresh_endpoint_url;
    _endpoint_fn = refresh_endpoint_fn;

    /*
    TODO
      get actual user
      if user not logged in, do nothing
      if not then refresh the jwt
     */
  }

  static SentcFlutterImpl _getApi() {
    return _api ?? (throw Exception("Not init"));
  }

  static Future<String> register(String userIdentifier, String password) {
    return _getApi().register(
      baseUrl: _base_url,
      authToken: _app_token,
      password: password,
      userIdentifier: userIdentifier,
    );
  }
}
