import 'dart:convert';
import 'dart:typed_data';

import 'package:sentc/sentc.dart';

Future<SymKey> fetchSymKey(
  String baseUrl,
  String appToken,
  String keyId,
  String masterKey,
  String masterKeyId,
  String signKey,
) async {
  final storage = Sentc.getStorage();

  final cacheKey = "sym_key_id_$keyId";

  final symKeyRawString = await storage.getItem(cacheKey);

  if (symKeyRawString != null) {
    return SymKey.fromJson(jsonDecode(symKeyRawString), signKey, baseUrl, appToken);
  }

  final out = await Sentc.getApi().getSymKeyById(
    baseUrl: baseUrl,
    authToken: appToken,
    keyId: keyId,
    masterKey: masterKey,
  );

  final symKey = SymKey(baseUrl, appToken, out, keyId, masterKeyId, signKey);

  await storage.set(cacheKey, jsonEncode(symKey));

  return symKey;
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
