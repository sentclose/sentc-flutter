import 'dart:typed_data';

import 'package:sentc/src/storage/storage_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStorage implements StorageInterface {
  ///Use file storage for file
  @override
  Future<void> cleanStorage() {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(key);
  }

  ///Use file storage for file
  @override
  Future<String> getDownloadUrl() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getItem(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(key);
  }

  @override
  Future<InitReturn> init() async {
    try {
      await SharedPreferences.getInstance();
      return InitReturn(true, null, null);
    } catch (error) {
      //
      return InitReturn(false, error.toString(), null);
    }
  }

  @override
  Future<void> set(String key, String item) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, item);
  }

  ///Use file storage for file
  @override
  Future<void> storePart(Uint8List chunk) {
    throw UnimplementedError();
  }
}
