import 'dart:typed_data';

import 'package:sentc/sentc.dart';

class NonRegisteredKeyOut {
  final SymKey key;
  final String encryptedKey;

  NonRegisteredKeyOut(this.key, this.encryptedKey);
}

class SymKey {
  final String key;
  final String keyId;
  final String masterKeyId;
  final String _signKey;

  SymKey(this.key, this.keyId, this.masterKeyId, this._signKey);

  Future<CryptoRawOutput> encryptRaw(Uint8List data, [bool sign = false]) {
    String signKey = "";

    if (sign) {
      signKey = _signKey;
    }

    return Sentc.getApi().encryptRawSymmetric(key: key, data: data, signKey: signKey);
  }

  Future<Uint8List> decryptRaw(String head, Uint8List encryptedData, [String verifyKey = ""]) {
    return Sentc.getApi().decryptRawSymmetric(
      key: key,
      encryptedData: encryptedData,
      head: head,
      verifyKeyData: verifyKey,
    );
  }

  Future<Uint8List> encrypt(Uint8List data, [bool sign = false]) {
    String signKey = "";

    if (sign) {
      signKey = _signKey;
    }

    return Sentc.getApi().encryptSymmetric(key: key, data: data, signKey: signKey);
  }

  Future<Uint8List> decrypt(Uint8List data, [String verifyKey = ""]) {
    return Sentc.getApi().decryptSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }

  Future<String> encryptString(String data, [bool sign = false]) {
    String signKey = "";

    if (sign) {
      signKey = _signKey;
    }

    return Sentc.getApi().encryptStringSymmetric(key: key, data: data, signKey: signKey);
  }

  Future<String> decryptString(String data, [String verifyKey = ""]) {
    return Sentc.getApi().decryptStringSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }
}
