import 'dart:ffi';
import 'dart:io';

import 'package:sentc/generated.dart';

enum REFRES_OPTIONS { cookie, cookie_fn, api }

class RefreshOptions {
  REFRES_OPTIONS endpoint;
  String? endpoint_url;
  Future<String> Function(String old_jwt)? endpoint_fn;

  RefreshOptions({required this.endpoint, this.endpoint_url, this.endpoint_fn});
}

class Sentc {
  final SentcFlutterImpl _api;

  final String _base_url;
  final String _app_token;
  final REFRES_OPTIONS _refresh_endpoint;
  final String _refresh_endpoint_url;
  final Future<String> Function(String old_jwt) _endpoint_fn;

  const Sentc._(
    this._api,
    this._base_url,
    this._app_token,
    this._refresh_endpoint,
    this._refresh_endpoint_url,
    this._endpoint_fn,
  );

  factory Sentc({
    String? base_url,
    required String app_token,
    String? file_part_url,
    RefreshOptions? refresh_options,
  }) {
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

    REFRES_OPTIONS refresh_endpoint =
        refresh_options != null ? refresh_options.endpoint : REFRES_OPTIONS.api;

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

    return Sentc._(
      api,
      base_url,
      app_token,
      refresh_endpoint,
      refresh_endpoint_url,
      refresh_endpoint_fn,
    );
  }

  Future<void> init() async {
    /*
    TODO
      get actual user
      if user not logged in, do nothing
      if not then refresh the jwt
     */
  }

  Future<String> register(String userIdentifier, String password) {
    return _api.register(
      baseUrl: _base_url,
      authToken: _app_token,
      password: password,
      userIdentifier: userIdentifier,
    );
  }
}
