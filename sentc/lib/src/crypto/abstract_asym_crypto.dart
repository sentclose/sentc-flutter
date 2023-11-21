import 'dart:typed_data';

import 'package:sentc/sentc.dart';

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

  Future<CryptoRawOutput> encryptRaw(Uint8List data, String replyId, [bool sign = false]) async {
    final key = await getPublicKey(replyId);

    final signKey = sign ? await getSignKey() : null;

    return Sentc.getApi().encryptRawAsymmetric(
      replyPublicKeyData: key.publicKey,
      data: data,
      signKey: signKey,
    );
  }

  Future<CryptoRawOutput> encryptRawSync(Uint8List data, String replyKey, [bool sign = false]) {
    final signKey = sign ? getSignKeySync() : null;

    return Sentc.getApi().encryptRawAsymmetric(
      replyPublicKeyData: replyKey,
      data: data,
      signKey: signKey,
    );
  }

  Future<Uint8List> decryptRaw(String head, Uint8List encryptedData, String? verifyKey) async {
    final api = Sentc.getApi();

    final deHead = await api.deserializeHeadFromString(head: head);

    final key = await getPrivateKey(deHead.id);

    return api.decryptRawAsymmetric(privateKey: key, encryptedData: encryptedData, head: head);
  }

  Future<Uint8List> decryptRawSync(String head, Uint8List encryptedData, String? verifyKey) async {
    final api = Sentc.getApi();

    final deHead = await api.deserializeHeadFromString(head: head);

    final key = getPrivateKeySync(deHead.id);

    return api.decryptRawAsymmetric(privateKey: key, encryptedData: encryptedData, head: head);
  }

  //____________________________________________________________________________________________________________________

  Future<Uint8List> encrypt(Uint8List data, String replyId, [bool sign = false]) async {
    final key = await getPublicKey(replyId);

    final signKey = sign ? await getSignKey() : null;

    return Sentc.getApi().encryptAsymmetric(replyPublicKeyData: key.publicKey, data: data, signKey: signKey);
  }

  Future<Uint8List> encryptSync(Uint8List data, String replyKey, [bool sign = false]) {
    final signKey = sign ? getSignKeySync() : null;

    return Sentc.getApi().encryptAsymmetric(replyPublicKeyData: replyKey, data: data, signKey: signKey);
  }

  Future<Uint8List> decrypt(Uint8List encryptedData, [bool verify = false, String? userId]) async {
    final api = Sentc.getApi();

    final head = await api.splitHeadAndEncryptedData(data: encryptedData);
    final key = await getPrivateKey(head.id);

    if (head.sign == null || !verify || userId == null) {
      return api.decryptAsymmetric(privateKey: key, encryptedData: encryptedData);
    }

    final verifyKey = await Sentc.getUserVerifyKey(userId, head.sign!.id);

    return api.decryptAsymmetric(privateKey: key, encryptedData: encryptedData, verifyKeyData: verifyKey);
  }

  Future<Uint8List> decryptSync(Uint8List encryptedData, String? verifyKey) async {
    final api = Sentc.getApi();

    final head = await api.splitHeadAndEncryptedData(data: encryptedData);
    final key = getPrivateKeySync(head.id);

    return api.decryptAsymmetric(privateKey: key, encryptedData: encryptedData, verifyKeyData: verifyKey);
  }

  //____________________________________________________________________________________________________________________

  Future<String> encryptString(String data, String replyId, [bool sign = false]) async {
    final key = await getPublicKey(replyId);
    final signKey = sign ? await getSignKey() : null;

    return Sentc.getApi().encryptStringAsymmetric(replyPublicKeyData: key.publicKey, data: data, signKey: signKey);
  }

  Future<String> encryptStringSync(String data, String replyKey, [bool sign = false]) {
    final signKey = sign ? getSignKeySync() : null;

    return Sentc.getApi().encryptStringAsymmetric(replyPublicKeyData: replyKey, data: data, signKey: signKey);
  }

  Future<String> decryptString(String encryptedData, [bool verify = false, String? userId]) async {
    final api = Sentc.getApi();

    final head = await api.splitHeadAndEncryptedString(data: encryptedData);
    final key = await getPrivateKey(head.id);

    if (head.sign == null || !verify || userId == null) {
      return api.decryptStringAsymmetric(privateKey: key, encryptedData: encryptedData);
    }

    final verifyKey = await Sentc.getUserVerifyKey(userId, head.sign!.id);

    return api.decryptStringAsymmetric(privateKey: key, encryptedData: encryptedData, verifyKeyData: verifyKey);
  }

  Future<String> decryptStringSync(String encryptedData, String? verifyKey) async {
    final api = Sentc.getApi();

    final head = await api.splitHeadAndEncryptedString(data: encryptedData);
    final key = getPrivateKeySync(head.id);

    return api.decryptStringAsymmetric(privateKey: key, encryptedData: encryptedData, verifyKeyData: verifyKey);
  }

  //____________________________________________________________________________________________________________________

  Future<SymKey> registerKey(String replyId) async {
    final key = await getPublicKey(replyId);
    final jwt = await getJwt();

    final out = await Sentc.getApi().generateAndRegisterSymKeyByPublicKey(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      publicKey: key.publicKey,
    );

    return SymKey(baseUrl, appToken, out.key, out.keyId, key.publicKeyId, await getSignKey());
  }

  Future<NonRegisteredKeyOut> generateNonRegisteredKey(String replyId) async {
    final key = await getPublicKey(replyId);

    final out = await Sentc.getApi().generateNonRegisterSymKeyByPublicKey(replyPublicKey: key.publicKey);

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

  Future<SymKey> fetchGeneratedKey(String keyId, String masterKeyId) async {
    final key = await getPrivateKey(masterKeyId);

    return fetchSymKeyByPrivateKey(baseUrl, appToken, keyId, key, masterKeyId, await getSignKey());
  }

  Future<SymKey> getNonRegisteredKey(String masterKeyId, String key) async {
    final privateKey = await getPrivateKey(masterKeyId);

    return getNonRegisteredKeyByPrivateKey(privateKey, key, masterKeyId, await getSignKey());
  }
}
