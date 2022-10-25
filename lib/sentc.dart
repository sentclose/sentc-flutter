import 'dart:ffi';
import 'dart:io';

import 'package:sentc/generated.dart';

import 'sentc_platform_interface.dart';

class Sentc {
  final SentcFlutterImpl api;

  const Sentc._(this.api);

  Future<String?> getPlatformVersion() {
    return SentcPlatform.instance.getPlatformVersion();
  }

  factory Sentc()
  {
    const base = "sentc_flutter";
    final path = Platform.isWindows ? "$base.dll" : "lib$base.so";
    late final dylib = Platform.isIOS
        ? DynamicLibrary.process()
        : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);

    final SentcFlutterImpl api = SentcFlutterImpl(dylib);
    return Sentc._(api);
  }

  Future<String> register(String userIdentifier, String password)
  {
    return api.register(baseUrl: "",authToken: "",password: password, userIdentifier: userIdentifier);
  }
}
