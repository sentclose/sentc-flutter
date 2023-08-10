class InitReturn {
  bool status;
  String? err;
  String? warn;

  InitReturn(this.status, this.err, this.warn);
}

abstract class StorageInterface {
  Future<InitReturn> init();

  Future<void> cleanStorage();

  Future<void> delete(String key);

  Future<String?> getItem(String key);

  Future<void> set(String key, String item);
}
