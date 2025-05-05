import 'dart:typed_data';

import 'package:sentc/sentc.dart';
import 'package:sentc/src/rust/api/crypto.dart' as api_crypto;

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

  Future<api_crypto.CryptoRawOutput> encryptRaw(Uint8List data, [bool sign = false]) async {
    final key = await getSymKeyToEncrypt();

    String? signKey;

    if (sign) {
      signKey = await getSignKey();
    }

    return api_crypto.encryptRawSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<api_crypto.CryptoRawOutput> encryptRawSync(Uint8List data, [bool sign = false]) {
    final key = getSymKeyToEncryptSync();

    String? signKey;

    if (sign) {
      signKey = getSignKeySync();
    }

    return api_crypto.encryptRawSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<Uint8List> decryptRaw(String head, Uint8List encryptedData, [String? verifyKey]) async {
    final deHead = await api_crypto.deserializeHeadFromString(head: head);

    final key = await getSymKeyById(deHead.id);

    return api_crypto.decryptRawSymmetric(
      key: key,
      encryptedData: encryptedData,
      head: head,
      verifyKeyData: verifyKey,
    );
  }

  Future<Uint8List> decryptRawSync(String head, Uint8List encryptedData, [String? verifyKey]) async {
    final deHead = await api_crypto.deserializeHeadFromString(head: head);

    final key = getSymKeyByIdSync(deHead.id);

    return api_crypto.decryptRawSymmetric(
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

    return api_crypto.encryptSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<Uint8List> encryptSync(Uint8List data, [bool sign = false]) {
    final key = getSymKeyToEncryptSync();

    String? signKey;

    if (sign) {
      signKey = getSignKeySync();
    }

    return api_crypto.encryptSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<Uint8List> decrypt(Uint8List data, [bool verify = false, String? userId]) async {
    final head = await api_crypto.splitHeadAndEncryptedData(data: data);

    final key = await getSymKeyById(head.id);

    if (head.signId == null || !verify || userId == null) {
      return api_crypto.decryptSymmetric(key: key, encryptedData: data);
    }

    final verifyKey = await Sentc.getUserVerifyKey(userId, head.signId!);

    return api_crypto.decryptSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }

  Future<Uint8List> decryptSync(Uint8List data, [String? verifyKey]) async {
    final head = await api_crypto.splitHeadAndEncryptedData(data: data);

    final key = getSymKeyByIdSync(head.id);

    return api_crypto.decryptSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }

  Future<String> encryptString(String data, [bool sign = false]) async {
    final key = await getSymKeyToEncrypt();

    String? signKey;

    if (sign) {
      signKey = await getSignKey();
    }

    return api_crypto.encryptStringSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<String> encryptStringSync(String data, [bool sign = false]) {
    final key = getSymKeyToEncryptSync();

    String? signKey;

    if (sign) {
      signKey = getSignKeySync();
    }

    return api_crypto.encryptStringSymmetric(key: key.key, data: data, signKey: signKey);
  }

  Future<String> decryptString(String data, [bool verify = false, String? userId]) async {
    final head = await api_crypto.splitHeadAndEncryptedString(data: data);

    final key = await getSymKeyById(head.id);

    if (head.signId == null || !verify || userId == null) {
      return api_crypto.decryptStringSymmetric(key: key, encryptedData: data);
    }

    final verifyKey = await Sentc.getUserVerifyKey(userId, head.signId!);

    return api_crypto.decryptStringSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }

  Future<String> decryptStringSync(String data, [String? verifyKey]) async {
    final head = await api_crypto.splitHeadAndEncryptedString(data: data);

    final key = getSymKeyByIdSync(head.id);

    return api_crypto.decryptStringSymmetric(key: key, encryptedData: data, verifyKeyData: verifyKey);
  }

  //____________________________________________________________________________________________________________________

  Future<NonRegisteredKeyOut> generateNonRegisteredKey() async {
    final keyData = await getSymKeyToEncrypt();

    final out = await api_crypto.generateNonRegisterSymKey(masterKey: keyData.key);

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

  Future<SymKey> getNonRegisteredKey(String masterKeyId, String key) async {
    final masterKey = await getSymKeyById(masterKeyId);

    return sym_key.getNonRegisteredKey(masterKey, key, masterKeyId, await getSignKey());
  }
}
