import 'dart:typed_data';

import 'package:sentc/sentc.dart';

import 'sym_key.dart' as sym_key;

class SymKeyToEncryptResult {
  final String id;
  final String key;

  SymKeyToEncryptResult(this.id, this.key);
}

abstract class AbstractSymCrypto {
  final String baseUrl;
  final String appToken;

  AbstractSymCrypto(this.baseUrl, this.appToken);

  Future<SymKeyToEncryptResult> getSymKeyToEncrypt();

  SymKeyToEncryptResult getSymKeyToEncryptSync();

  Future<String> getSymKeyById(String keyId);

  String getSymKeyByIdSync(String keyId);

  Future<String> getSignKey();

  String getSignKeySync();

  Future<String> getJwt();

  Future<CryptoRawOutput> encryptRaw(Uint8List data, [bool sign = false]) async {
    final key = await getSymKeyToEncrypt();

    String? signKey;

    if (sign) {
      signKey = await getSignKey();
    }

    return Sentc.getApi().encryptRawSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<CryptoRawOutput> encryptRawSync(Uint8List data, [bool sign = false]) {
    final key = getSymKeyToEncryptSync();

    String? signKey;

    if (sign) {
      signKey = getSignKeySync();
    }

    return Sentc.getApi().encryptRawSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<Uint8List> decryptRaw(String head, Uint8List encryptedData, [String? verifyKey]) async {
    final deHead = await Sentc.getApi().deserializeHeadFromString(head: head);

    final key = await getSymKeyById(deHead.id);

    return Sentc.getApi().decryptRawSymmetric(
      key: key,
      encryptedData: encryptedData,
      head: head,
      verifyKeyData: verifyKey,
    );
  }

  Future<Uint8List> decryptRawSync(String head, Uint8List encryptedData, [String? verifyKey]) async {
    final deHead = await Sentc.getApi().deserializeHeadFromString(head: head);

    final key = getSymKeyByIdSync(deHead.id);

    return Sentc.getApi().decryptRawSymmetric(
      key: key,
      encryptedData: encryptedData,
      head: head,
      verifyKeyData: verifyKey,
    );
  }

  //____________________________________________________________________________________________________________________

  Future<Uint8List> encrypt(Uint8List data, [bool sign = false]) async {
    final key = await getSymKeyToEncrypt();

    String? signKey;

    if (sign) {
      signKey = await getSignKey();
    }

    return Sentc.getApi().encryptSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<Uint8List> encryptSync(Uint8List data, [bool sign = false]) {
    final key = getSymKeyToEncryptSync();

    String? signKey;

    if (sign) {
      signKey = getSignKeySync();
    }

    return Sentc.getApi().encryptSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<Uint8List> decrypt(Uint8List data, [bool verify = false, String? userId]) async {
    final head = await Sentc.getApi().splitHeadAndEncryptedData(data: data);

    final key = await getSymKeyById(head.id);

    if (head.sign == null || !verify || userId == null) {
      return Sentc.getApi().decryptSymmetric(key: key, encryptedData: data);
    }

    final verifyKey = await Sentc.getUserVerifyKey(userId, head.sign!.id);

    return Sentc.getApi().decryptSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }

  Future<Uint8List> decryptSync(Uint8List data, [String? verifyKey]) async {
    final head = await Sentc.getApi().splitHeadAndEncryptedData(data: data);

    final key = getSymKeyByIdSync(head.id);

    return Sentc.getApi().decryptSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }

  Future<String> encryptString(String data, [bool sign = false]) async {
    final key = await getSymKeyToEncrypt();

    String? signKey;

    if (sign) {
      signKey = await getSignKey();
    }

    return Sentc.getApi().encryptStringSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<String> encryptStringSync(String data, [bool sign = false]) {
    final key = getSymKeyToEncryptSync();

    String? signKey;

    if (sign) {
      signKey = getSignKeySync();
    }

    return Sentc.getApi().encryptStringSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<String> decryptString(String data, [bool verify = false, String? userId]) async {
    final head = await Sentc.getApi().splitHeadAndEncryptedString(data: data);

    final key = await getSymKeyById(head.id);

    if (head.sign == null || !verify || userId == null) {
      return Sentc.getApi().decryptStringSymmetric(key: key, encryptedData: data);
    }

    final verifyKey = await Sentc.getUserVerifyKey(userId, head.sign!.id);

    return Sentc.getApi().decryptStringSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }

  Future<String> decryptStringSync(String data, [String? verifyKey]) async {
    final head = await Sentc.getApi().splitHeadAndEncryptedString(data: data);

    final key = getSymKeyByIdSync(head.id);

    return Sentc.getApi().decryptStringSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }

  //____________________________________________________________________________________________________________________

  Future<SymKey> registerKey() async {
    final keyData = await getSymKeyToEncrypt();

    final jwt = await getJwt();

    final out = await Sentc.getApi().generateAndRegisterSymKey(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      masterKey: keyData.key,
    );

    return SymKey(baseUrl, appToken, out.key, out.keyId, keyData.id, await getSignKey());
  }

  Future<NonRegisteredKeyOut> generateNonRegisteredKey() async {
    final keyData = await getSymKeyToEncrypt();

    final out = await Sentc.getApi().generateNonRegisterSymKey(masterKey: keyData.key);

    return NonRegisteredKeyOut(
      SymKey(
        baseUrl,
        appToken,
        out.key,
        "non_register",
        keyData.id,
        await getSignKey(),
      ),
      out.encryptedKey,
    );
  }

  Future<SymKey> fetchKey(String keyId, String masterKeyId) async {
    final key = await getSymKeyById(masterKeyId);

    return fetchSymKey(baseUrl, appToken, keyId, key, masterKeyId, await getSignKey());
  }

  Future<SymKey> getNonRegisteredKey(String masterKeyId, String key) async {
    final masterKey = await getSymKeyById(masterKeyId);

    return sym_key.getNonRegisteredKey(masterKey, key, masterKeyId, await getSignKey());
  }
}
