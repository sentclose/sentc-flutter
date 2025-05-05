import 'dart:typed_data';

import 'package:sentc/sentc.dart';
import 'package:sentc/src/rust/api/crypto.dart' as api_crypto;

abstract class AbstractAsymCrypto {
  final String baseUrl;
  final String appToken;

  AbstractAsymCrypto(this.baseUrl, this.appToken);

  Future<PublicKeyData> getPublicKey(String replyId);

  Future<String> getPrivateKey(String keyId);

  String getPrivateKeySync(String keyId);

  Future<String> getSignKey();

  String getSignKeySync();

  Future<String> getJwt();

  Future<api_crypto.CryptoRawOutput> encryptRaw(Uint8List data, String replyId, [bool sign = false]) async {
    final key = await getPublicKey(replyId);

    final signKey = sign ? await getSignKey() : null;

    return api_crypto.encryptRawAsymmetric(
      replyPublicKeyData: key.publicKey,
      data: data,
      signKey: signKey,
    );
  }

  Future<api_crypto.CryptoRawOutput> encryptRawSync(Uint8List data, String replyKey, [bool sign = false]) {
    final signKey = sign ? getSignKeySync() : null;

    return api_crypto.encryptRawAsymmetric(
      replyPublicKeyData: replyKey,
      data: data,
      signKey: signKey,
    );
  }

  Future<Uint8List> decryptRaw(String head, Uint8List encryptedData, String? verifyKey) async {
    final deHead = await api_crypto.deserializeHeadFromString(head: head);

    final key = await getPrivateKey(deHead.id);

    return api_crypto.decryptRawAsymmetric(privateKey: key, encryptedData: encryptedData, head: head);
  }

  Future<Uint8List> decryptRawSync(String head, Uint8List encryptedData, String? verifyKey) async {
    final deHead = await api_crypto.deserializeHeadFromString(head: head);

    final key = getPrivateKeySync(deHead.id);

    return api_crypto.decryptRawAsymmetric(privateKey: key, encryptedData: encryptedData, head: head);
  }

  //____________________________________________________________________________________________________________________

  Future<Uint8List> encrypt(Uint8List data, String replyId, [bool sign = false]) async {
    final key = await getPublicKey(replyId);

    final signKey = sign ? await getSignKey() : null;

    return api_crypto.encryptAsymmetric(replyPublicKeyData: key.publicKey, data: data, signKey: signKey);
  }

  Future<Uint8List> encryptSync(Uint8List data, String replyKey, [bool sign = false]) {
    final signKey = sign ? getSignKeySync() : null;

    return api_crypto.encryptAsymmetric(replyPublicKeyData: replyKey, data: data, signKey: signKey);
  }

  Future<Uint8List> decrypt(Uint8List encryptedData, [bool verify = false, String? userId]) async {
    final head = await api_crypto.splitHeadAndEncryptedData(data: encryptedData);
    final key = await getPrivateKey(head.id);

    if (head.signId == null || !verify || userId == null) {
      return api_crypto.decryptAsymmetric(privateKey: key, encryptedData: encryptedData);
    }

    final verifyKey = await Sentc.getUserVerifyKey(userId, head.signId!);

    return api_crypto.decryptAsymmetric(privateKey: key, encryptedData: encryptedData, verifyKeyData: verifyKey);
  }

  Future<Uint8List> decryptSync(Uint8List encryptedData, String? verifyKey) async {
    final head = await api_crypto.splitHeadAndEncryptedData(data: encryptedData);
    final key = getPrivateKeySync(head.id);

    return api_crypto.decryptAsymmetric(privateKey: key, encryptedData: encryptedData, verifyKeyData: verifyKey);
  }

  //____________________________________________________________________________________________________________________

  Future<String> encryptString(String data, String replyId, [bool sign = false]) async {
    final key = await getPublicKey(replyId);
    final signKey = sign ? await getSignKey() : null;

    return api_crypto.encryptStringAsymmetric(replyPublicKeyData: key.publicKey, data: data, signKey: signKey);
  }

  Future<String> encryptStringSync(String data, String replyKey, [bool sign = false]) {
    final signKey = sign ? getSignKeySync() : null;

    return api_crypto.encryptStringAsymmetric(replyPublicKeyData: replyKey, data: data, signKey: signKey);
  }

  Future<String> decryptString(String encryptedData, [bool verify = false, String? userId]) async {
    final head = await api_crypto.splitHeadAndEncryptedString(data: encryptedData);
    final key = await getPrivateKey(head.id);

    if (head.signId == null || !verify || userId == null) {
      return api_crypto.decryptStringAsymmetric(privateKey: key, encryptedData: encryptedData);
    }

    final verifyKey = await Sentc.getUserVerifyKey(userId, head.signId!);

    return api_crypto.decryptStringAsymmetric(privateKey: key, encryptedData: encryptedData, verifyKeyData: verifyKey);
  }

  Future<String> decryptStringSync(String encryptedData, String? verifyKey) async {
    final head = await api_crypto.splitHeadAndEncryptedString(data: encryptedData);
    final key = getPrivateKeySync(head.id);

    return api_crypto.decryptStringAsymmetric(privateKey: key, encryptedData: encryptedData, verifyKeyData: verifyKey);
  }

  //____________________________________________________________________________________________________________________

  Future<NonRegisteredKeyOut> generateNonRegisteredKey(String replyId) async {
    final key = await getPublicKey(replyId);

    final out = await api_crypto.generateNonRegisterSymKeyByPublicKey(replyPublicKey: key.publicKey);

    return NonRegisteredKeyOut(
      SymKey(
        baseUrl,
        appToken,
        out.key,
        "non_register",
        key.publicKeyId,
        await getSignKey(),
      ),
      out.encryptedKey,
    );
  }

  Future<SymKey> getNonRegisteredKey(String masterKeyId, String key) async {
    final privateKey = await getPrivateKey(masterKeyId);

    return getNonRegisteredKeyByPrivateKey(privateKey, key, masterKeyId, await getSignKey());
  }
}
