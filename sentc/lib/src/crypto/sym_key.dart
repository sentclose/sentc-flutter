import 'dart:typed_data';

import 'package:sentc/src/rust/api/crypto.dart' as api_crypto;

Future<SymKey> getNonRegisteredKey(String masterKey, String key, String masterKeyId, String signKey) async {
  final keyOut = await api_crypto.doneFetchSymKey(masterKey: masterKey, serverOut: key, nonRegistered: true);

  return SymKey("", "", keyOut, "non_register", masterKeyId, signKey);
}

Future<SymKey> getNonRegisteredKeyByPrivateKey(
  String privateKey,
  String key,
  String masterKeyId,
  String signKey,
) async {
  final keyOut = await api_crypto.doneFetchSymKeyByPrivateKey(
    privateKey: privateKey,
    serverOut: key,
    nonRegistered: true,
  );

  return SymKey("", "", keyOut, "non_register", masterKeyId, signKey);
}

class NonRegisteredKeyOut {
  final SymKey key;
  final String encryptedKey;

  NonRegisteredKeyOut(this.key, this.encryptedKey);
}

class SymKey {
  final String baseUrl;
  final String appToken;
  final String key;
  final String keyId;
  final String masterKeyId;
  final String _signKey;

  SymKey(this.baseUrl, this.appToken, this.key, this.keyId, this.masterKeyId, this._signKey);

  SymKey.fromJson(Map<String, dynamic> json, this._signKey, this.baseUrl, this.appToken)
      : key = json["key"],
        keyId = json["keyId"],
        masterKeyId = json["masterKeyId"];

  Map<String, dynamic> toJson() {
    return {"key": key, "keyId": keyId, "masterKeyId": masterKeyId};
  }

  Future<api_crypto.CryptoRawOutput> encryptRaw(Uint8List data, [bool sign = false]) {
    String? signKey;

    if (sign) {
      signKey = _signKey;
    }

    return api_crypto.encryptRawSymmetric(key: key, data: data, signKey: signKey);
  }

  Future<Uint8List> decryptRaw(String head, Uint8List encryptedData, [String? verifyKey]) {
    return api_crypto.decryptRawSymmetric(
      key: key,
      encryptedData: encryptedData,
      head: head,
      verifyKeyData: verifyKey,
    );
  }

  Future<Uint8List> encrypt(Uint8List data, [bool sign = false]) {
    String? signKey;

    if (sign) {
      signKey = _signKey;
    }

    return api_crypto.encryptSymmetric(key: key, data: data, signKey: signKey);
  }

  Future<Uint8List> decrypt(Uint8List data, [String? verifyKey]) {
    return api_crypto.decryptSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }

  Future<String> encryptString(String data, [bool sign = false]) {
    String? signKey;

    if (sign) {
      signKey = _signKey;
    }

    return api_crypto.encryptStringSymmetric(key: key, data: data, signKey: signKey);
  }

  Future<String> decryptString(String data, [String? verifyKey]) {
    return api_crypto.decryptStringSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }
}
