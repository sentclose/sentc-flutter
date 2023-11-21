import 'dart:convert';

import 'package:sentc/src/crypto/abstract_asym_crypto.dart';
import 'package:sentc/src/group.dart' as group;
import 'package:sentc/sentc.dart';
import '../src/generated.dart' as plugin;

Future<User> getUser(String deviceIdentifier, UserData data, bool mfa) async {
  final Map<String, int> keyMap = {};

  final List<UserKey> userKeys = [];

  for (var i = 0; i < data.userKeys.length; ++i) {
    var key = data.userKeys[i];

    keyMap[key.groupKeyId] = i;

    userKeys.add(UserKey.fromServer(key));
  }

  final refreshToken = (Sentc.refreshEndpoint != RefreshOption.api) ? "" : data.refreshToken;

  //when getting the user the first time this is always the newest key id
  final newestKeyId = data.userKeys[0].groupKeyId;

  final user = User._(
    Sentc.baseUrl,
    Sentc.appToken,
    deviceIdentifier,
    data.jwt,
    refreshToken,
    data.userId,
    data.deviceId,
    mfa,
    data.keys.privateKey,
    data.keys.publicKey,
    data.keys.signKey,
    data.keys.verifyKey,
    data.keys.exportedPublicKey,
    data.keys.exportedVerifyKey,
    userKeys,
    [],
    keyMap,
    newestKeyId,
    [],
  );

  //decrypt the hmac key
  user._hmacKeys = await user.decryptHmacKeys(data.hmacKeys);

  final storage = Sentc.getStorage();

  Future.wait([
    storage.set("user_data_$deviceIdentifier", jsonEncode(user)),
    storage.set("actual_user", deviceIdentifier),
    //save always the newest public key
    storage.set(
      "user_public_key_${user.userId}",
      jsonEncode(
        PublicKeyData(
          userKeys[0].groupKeyId,
          userKeys[0].exportedPublicKey,
          userKeys[0].exportedPublicKeySigKeyId,
          false,
        ),
      ),
    ),
    storage.set("user_verify_key_${user.userId}_${userKeys[0].groupKeyId}", userKeys[0].exportedVerifyKey),
  ]);

  return user;
}

/// Keys from the user group
class UserKey extends group.GroupKey {
  final String signKey;
  final String verifyKey;
  final String exportedVerifyKey;
  final String? exportedPublicKeySigKeyId;

  UserKey({
    required super.privateGroupKey,
    required super.publicGroupKey,
    required super.groupKey,
    required super.time,
    required super.groupKeyId,
    required this.signKey,
    required this.verifyKey,
    required super.exportedPublicKey,
    required this.exportedVerifyKey,
    required this.exportedPublicKeySigKeyId,
  });

  factory UserKey.fromJson(Map<String, dynamic> json) => UserKey(
      privateGroupKey: json['privateGroupKey'] as String,
      publicGroupKey: json['publicGroupKey'] as String,
      groupKey: json['groupKey'] as String,
      time: json['time'] as String,
      groupKeyId: json['groupKeyId'] as String,
      signKey: json['signKey'] as String,
      verifyKey: json['verifyKey'] as String,
      exportedPublicKey: json['exportedPublicKey'] as String,
      exportedVerifyKey: json['exportedVerifyKey'] as String,
      exportedPublicKeySigKeyId: json["exportedPublicKeySigKeyId"] as String?);

  factory UserKey.fromServer(plugin.UserKeyData key) => UserKey(
        privateGroupKey: key.privateKey,
        publicGroupKey: key.publicKey,
        groupKey: key.groupKey,
        time: key.time,
        groupKeyId: key.groupKeyId,
        signKey: key.signKey,
        verifyKey: key.verifyKey,
        exportedPublicKey: key.exportedPublicKey,
        exportedVerifyKey: key.exportedVerifyKey,
        exportedPublicKeySigKeyId: key.exportedPublicKeySigKeyId,
      );

  @override
  Map<String, dynamic> toJson() {
    return {
      "privateGroupKey": privateGroupKey,
      "publicGroupKey": publicGroupKey,
      "groupKey": groupKey,
      "time": time,
      "groupKeyId": groupKeyId,
      "signKey": signKey,
      "verifyKey": verifyKey,
      "exportedPublicKey": exportedPublicKey,
      "exportedVerifyKey": exportedVerifyKey,
      "exportedPublicKeySigKeyId": exportedPublicKeySigKeyId,
    };
  }
}

class UserVerifyKeyCompareInfo {
  final String userId;
  final String verifyKeyId;

  UserVerifyKeyCompareInfo(this.userId, this.verifyKeyId);
}

class User extends AbstractAsymCrypto {
  final String _userIdentifier;
  late String jwt;
  final String refreshToken;
  final String userId;
  final String deviceId;
  bool mfa;

  //device keys
  final String _privateDeviceKey;
  final String _publicDeviceKey;
  final String _signDeviceKey;
  final String _verifyDeviceKey;
  final String _exportedPublicDeviceKey;
  final String _exportedVerifyDeviceKey;

  //user keys
  final List<UserKey> _userKeys;
  final Map<String, int> _keyMap;
  String _newestKeyId;
  List<String> _hmacKeys;

  late List<GroupInviteReqList> groupInvites;

  User._(
    super.baseUrl,
    super.appToken,
    this._userIdentifier,
    this.jwt,
    this.refreshToken,
    this.userId,
    this.deviceId,
    this.mfa,
    this._privateDeviceKey,
    this._publicDeviceKey,
    this._signDeviceKey,
    this._verifyDeviceKey,
    this._exportedPublicDeviceKey,
    this._exportedVerifyDeviceKey,
    this._userKeys,
    this.groupInvites,
    this._keyMap,
    this._newestKeyId,
    this._hmacKeys,
  );

  User.fromJson(Map<String, dynamic> json, super.baseUrl, super.appToken)
      : jwt = json["jwt"],
        refreshToken = json["refreshToken"],
        userId = json["userId"],
        deviceId = json["deviceId"],
        mfa = json["mfa"],
        _privateDeviceKey = json["privateDeviceKey"],
        _publicDeviceKey = json["publicDeviceKey"],
        _signDeviceKey = json["signDeviceKey"],
        _verifyDeviceKey = json["verifyDeviceKey"],
        _exportedPublicDeviceKey = json["exportedPublicDeviceKey"],
        _exportedVerifyDeviceKey = json["exportedVerifyDeviceKey"],
        groupInvites = [],
        _userIdentifier = json["userIdentifier"],
        _keyMap = Map<String, int>.from(jsonDecode(json["keyMap"]) as Map<String, dynamic>),
        _newestKeyId = json["newestKeyId"],
        _userKeys = (jsonDecode(json["userKeys"]) as List).map((e) => UserKey.fromJson(e)).toList(),
        _hmacKeys = (jsonDecode(json["hmacKeys"]) as List<dynamic>).map((e) => e as String).toList();

  Map<String, dynamic> toJson() {
    return {
      "jwt": jwt,
      "refreshToken": refreshToken,
      "userId": userId,
      "deviceId": deviceId,
      "mfa": mfa,
      "privateDeviceKey": _privateDeviceKey,
      "publicDeviceKey": _publicDeviceKey,
      "signDeviceKey": _signDeviceKey,
      "verifyDeviceKey": _verifyDeviceKey,
      "exportedPublicDeviceKey": _exportedPublicDeviceKey,
      "exportedVerifyDeviceKey": _exportedVerifyDeviceKey,
      "userIdentifier": _userIdentifier,
      "keyMap": jsonEncode(_keyMap),
      "userKeys": jsonEncode(_userKeys),
      "newestKeyId": _newestKeyId,
      "hmacKeys": jsonEncode(_hmacKeys),
    };
  }

  bool enabledMfa() {
    return mfa;
  }

  @override
  Future<String> getJwt() async {
    final jwtData = await Sentc.getApi().decodeJwt(jwt: jwt);

    if (jwtData.exp <= DateTime.now().millisecondsSinceEpoch / 1000 + 30) {
      jwt = await Sentc.refreshJwt(jwt, refreshToken);

      final storage = Sentc.getStorage();

      await storage.set("user_data_$_userIdentifier", jsonEncode(this));
    }

    return jwt;
  }

  Future<String> getFreshJwt(String userIdentifier, String password, [String? mfaToken, bool? mfaRecovery]) {
    return Sentc.getApi().getFreshJwt(
      baseUrl: baseUrl,
      authToken: appToken,
      userIdentifier: userIdentifier,
      password: password,
      mfaToken: mfaToken,
      mfaRecovery: mfaRecovery,
    );
  }

  /// Fetch key for the actual user group
  Future<UserKey> _getUserKeys(String keyId, [bool first = false]) async {
    var index = _keyMap[keyId];

    if (index == null) {
      //try to fetch the key
      await fetchUserKey(keyId, first);

      index = _keyMap[keyId];

      if (index == null) {
        //key not found
        throw Exception("Key not found");
      }
    }

    try {
      return _userKeys[index];
    } catch (e) {
      throw Exception("Key not found");
    }
  }

  UserKey _getUserKeysSync(String keyId) {
    var index = _keyMap[keyId];

    if (index == null) {
      //key not found
      throw Exception("Key not found");
    }

    try {
      return _userKeys[index];
    } catch (e) {
      throw Exception("Key not found");
    }
  }

  fetchUserKey(String keyId, [bool first = false]) async {
    final jwt = await getJwt();

    final userKeys = await Sentc.getApi().fetchUserKey(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      keyId: keyId,
      privateKey: _privateDeviceKey,
    );

    final index = _userKeys.length;
    _userKeys.add(UserKey.fromServer(userKeys));
    _keyMap[userKeys.groupKeyId] = index;

    if (first) {
      _newestKeyId = userKeys.groupKeyId;
    }

    final storage = Sentc.getStorage();

    await storage.set("user_data_$_userIdentifier", jsonEncode(this));
  }

  Future<void> doneFetchUserKey(String serverOutput) async {
    final key = await Sentc.getApi().doneFetchUserKey(
      privateKey: _privateDeviceKey,
      serverOutput: serverOutput,
    );

    final lastIndex = _userKeys.length;

    _userKeys.add(UserKey.fromServer(key));

    _keyMap[key.groupKeyId] = lastIndex;
  }

  Future<List<String>> decryptHmacKeys(List<GroupOutDataHmacKeys> fetchedKeys) async {
    final List<String> list = [];

    for (var i = 0; i < fetchedKeys.length; ++i) {
      var key = fetchedKeys[i];

      final groupKey = await _getUserSymKey(key.groupKeyId);

      final decryptedHmacKey = await Sentc.getApi().groupDecryptHmacKey(groupKey: groupKey, serverKeyData: key.keyData);

      list.add(decryptedHmacKey);
    }

    return list;
  }

  @override
  Future<String> getPrivateKey(String keyId) async {
    final key = await _getUserKeys(keyId);

    return key.privateGroupKey;
  }

  @override
  String getPrivateKeySync(String keyId) {
    final key = _getUserKeysSync(keyId);

    return key.privateGroupKey;
  }

  @override
  Future<PublicKeyData> getPublicKey(String replyId) {
    return Sentc.getUserPublicKey(replyId);
  }

  UserKey _getNewestKey() {
    final index = _keyMap[_newestKeyId] ??= 0;

    return _userKeys[index];
  }

  String getNewestPublicKey() {
    return _getNewestKey().publicGroupKey;
  }

  String getNewestSignKey() {
    return _getNewestKey().signKey;
  }

  @override
  Future<String> getSignKey() {
    return Future.value(getNewestSignKey());
  }

  @override
  String getSignKeySync() {
    return getNewestSignKey();
  }

  Future<String> _getUserSymKey(String keyId) async {
    final key = await _getUserKeys(keyId);

    return key.groupKey;
  }

  String getNewestHmacKey() {
    return _hmacKeys[0];
  }

  //____________________________________________________________________________________________________________________

  Future<void> updateUser(String newIdentifier) {
    return Sentc.getApi().updateUser(baseUrl: baseUrl, authToken: appToken, jwt: jwt, userIdentifier: newIdentifier);
  }

  Future<OtpRegister> registerRawOtp(String password, [String? mfaToken, bool? mfaRecovery]) async {
    final jwt = await getFreshJwt(_userIdentifier, password, mfaToken, mfaRecovery);

    final out = await Sentc.getApi().registerRawOtp(baseUrl: baseUrl, authToken: appToken, jwt: jwt);

    mfa = true;

    final storage = Sentc.getStorage();

    await storage.set("user_data_$_userIdentifier", jsonEncode(this));

    return out;
  }

  Future<(String, List<String>)> registerOtp(
    String issuer,
    String audience,
    String password, [
    String? mfaToken,
    bool? mfaRecovery,
  ]) async {
    final jwt = await getFreshJwt(_userIdentifier, password, mfaToken, mfaRecovery);

    final out = await Sentc.getApi().registerOtp(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      issuer: issuer,
      audience: audience,
    );

    mfa = true;

    final storage = Sentc.getStorage();

    await storage.set("user_data_$_userIdentifier", jsonEncode(this));

    return (out.url, out.recover);
  }

  Future<List<String>> getOtpRecoverKeys(
    String password, [
    String? mfaToken,
    bool? mfaRecovery,
  ]) async {
    final jwt = await getFreshJwt(_userIdentifier, password, mfaToken, mfaRecovery);

    final out = await Sentc.getApi().getOtpRecoverKeys(baseUrl: baseUrl, authToken: appToken, jwt: jwt);

    return out.keys;
  }

  Future<OtpRegister> resetRawOtp(
    String password, [
    String? mfaToken,
    bool? mfaRecovery,
  ]) async {
    final jwt = await getFreshJwt(_userIdentifier, password, mfaToken, mfaRecovery);

    return Sentc.getApi().resetRawOtp(baseUrl: baseUrl, authToken: appToken, jwt: jwt);
  }

  Future<(String, List<String>)> resetOtp(
    String issuer,
    String audience,
    String password, [
    String? mfaToken,
    bool? mfaRecovery,
  ]) async {
    final jwt = await getFreshJwt(_userIdentifier, password, mfaToken, mfaRecovery);

    final out = await Sentc.getApi().resetOtp(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      issuer: issuer,
      audience: audience,
    );

    return (out.url, out.recover);
  }

  Future<void> disableOtp(
    String password, [
    String? mfaToken,
    bool? mfaRecovery,
  ]) async {
    final jwt = await getFreshJwt(_userIdentifier, password, mfaToken, mfaRecovery);

    await Sentc.getApi().disableOtp(baseUrl: baseUrl, authToken: appToken, jwt: jwt);

    mfa = true;

    final storage = Sentc.getStorage();

    await storage.set("user_data_$_userIdentifier", jsonEncode(this));
  }

  Future<void> resetPassword(String newPassword) async {
    final jwt = await getJwt();

    final decryptedPrivateKey = _privateDeviceKey;
    final decryptedSignKey = _signDeviceKey;

    return Sentc.getApi().resetPassword(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      newPassword: newPassword,
      decryptedPrivateKey: decryptedPrivateKey,
      decryptedSignKey: decryptedSignKey,
    );
  }

  Future<void> changePassword(String oldPassword, String newPassword, [String? mfaToken, bool? mfaRecovery]) {
    return Sentc.getApi().changePassword(
      baseUrl: baseUrl,
      authToken: appToken,
      userIdentifier: _userIdentifier,
      oldPassword: oldPassword,
      newPassword: newPassword,
      mfaToken: mfaToken,
      mfaRecovery: mfaRecovery,
    );
  }

  Future<void> logOut() {
    final storage = Sentc.getStorage();

    return storage.delete("user_data_$_userIdentifier");
  }

  Future<void> deleteUser(String password, [String? mfaToken, bool? mfaRecovery]) async {
    final jwt = await getFreshJwt(_userIdentifier, password, mfaToken, mfaRecovery);

    await Sentc.getApi().deleteUser(baseUrl: baseUrl, authToken: appToken, freshJwt: jwt);

    return logOut();
  }

  Future<void> deleteDevice(String password, String deviceId, [String? mfaToken, bool? mfaRecovery]) async {
    final jwt = await getFreshJwt(_userIdentifier, password, mfaToken, mfaRecovery);

    await Sentc.getApi().deleteDevice(baseUrl: baseUrl, authToken: appToken, freshJwt: jwt, deviceId: deviceId);

    if (deviceId == this.deviceId) {
      //only log the device out if it is the actual used device
      return logOut();
    }
  }

  //____________________________________________________________________________________________________________________

  Future<PreRegisterDeviceData> prepareRegisterDevice(String serverOutput, int page) async {
    final keyCount = _userKeys.length;

    final keyString = group.prepareKeys(_userKeys, page).str;

    return Sentc.getApi().prepareRegisterDevice(serverOutput: serverOutput, userKeys: keyString, keyCount: keyCount);
  }

  Future<void> registerDevice(String serverOutput) async {
    final keyCount = _userKeys.length;

    final keyString = group.prepareKeys(_userKeys, 0).str;

    final jwt = await getJwt();

    final out = await Sentc.getApi().registerDevice(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      serverOutput: serverOutput,
      keyCount: keyCount,
      userKeys: keyString,
    );

    final sessionId = out.sessionId;
    final publicKey = out.exportedPublicKey;

    if (sessionId == "") {
      return;
    }

    bool nextPage = true;
    int i = 1;
    final List<Future<void>> p = [];

    while (nextPage) {
      final nextKeys = group.prepareKeys(_userKeys, i);

      nextPage = nextKeys.end;

      p.add(Sentc.getApi().userDeviceKeySessionUpload(
        baseUrl: baseUrl,
        authToken: appToken,
        jwt: jwt,
        sessionId: sessionId,
        userPublicKey: publicKey,
        groupKeys: nextKeys.str,
      ));

      i++;
    }

    await Future.wait(p);
  }

  Future<List<UserDeviceList>> getDevices([UserDeviceList? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time ?? "0";
    final lastId = lastFetchedItem?.deviceId ?? "none";

    return Sentc.getApi().getUserDevices(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      lastFetchedTime: lastFetchedTime,
      lastFetchedId: lastId,
    );
  }

  Future<String> createSafetyNumber([UserVerifyKeyCompareInfo? userToCompare]) async {
    String? verifyKey2;

    if (userToCompare != null) {
      verifyKey2 = await Sentc.getUserVerifyKey(userToCompare.userId, userToCompare.verifyKeyId);
    }

    return Sentc.getApi().userCreateSafetyNumber(
      verifyKey1: _getNewestKey().exportedVerifyKey,
      userId1: userId,
      verifyKey2: verifyKey2,
      userId2: userToCompare?.userId,
    );
  }

  //____________________________________________________________________________________________________________________

  Future<void> keyRotation() async {
    final jwt = await getJwt();

    final keyId = await Sentc.getApi().userKeyRotation(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      publicDeviceKey: _publicDeviceKey,
      preUserKey: _getNewestKey().groupKey,
    );

    return fetchUserKey(keyId, true);
  }

  Future<void> finishKeyRotation() async {
    final jwt = await getJwt();

    List<KeyRotationGetOut> keys =
        await Sentc.getApi().userPreDoneKeyRotation(baseUrl: baseUrl, authToken: appToken, jwt: jwt);

    bool nextRound = false;
    int roundsLeft = 10;

    final publicKey = _publicDeviceKey;
    final privateKey = _privateDeviceKey;

    do {
      final List<KeyRotationGetOut> leftKeys = [];

      for (var i = 0; i < keys.length; ++i) {
        var key = keys[i];

        UserKey preKey;

        try {
          preKey = await _getUserKeys(key.preGroupKeyId);
        } catch (e) {
          //key not found -> try next round
          leftKeys.add(key);
          continue;
        }

        await Sentc.getApi().userFinishKeyRotation(
          baseUrl: baseUrl,
          authToken: appToken,
          jwt: jwt,
          serverOutput: key.serverOutput,
          preGroupKey: preKey.groupKey,
          publicKey: publicKey,
          privateKey: privateKey,
        );

        await _getUserKeys(key.newGroupKeyId, true);
      }

      roundsLeft--;

      if (leftKeys.isNotEmpty) {
        keys = [];
        //push the not found keys into the key array, maybe the pre group keys are in the next round
        keys.addAll(leftKeys);

        nextRound = true;
      } else {
        nextRound = false;
      }
    } while (nextRound && roundsLeft > 0);
  }

  //____________________________________________________________________________________________________________________

  Future<String> prepareGroupCreate() {
    return Sentc.getApi().groupPrepareCreateGroup(creatorsPublicKey: getNewestPublicKey());
  }

  Future<String> createGroup() async {
    final jwt = await getJwt();

    return Sentc.getApi().groupCreateGroup(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      creatorsPublicKey: getNewestPublicKey(),
    );
  }

  Future<group.Group> getGroup(String groupId, [String? groupAsMember]) {
    return group.getGroup(groupId, baseUrl, appToken, this, false, groupAsMember);
  }

  Future<List<ListGroups>> getGroups([ListGroups? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time.toString() ?? "0";
    final lastFetchedGroupId = lastFetchedItem?.groupId ?? "none";

    return Sentc.getApi().groupGetGroupsForUser(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      lastFetchedTime: lastFetchedTime,
      lastFetchedGroupId: lastFetchedGroupId,
    );
  }

  Future<List<GroupInviteReqList>> getGroupInvites([GroupInviteReqList? lastItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastItem?.time.toString() ?? "0";
    final lastFetchedGroupId = lastItem?.groupId ?? "none";

    return Sentc.getApi().groupGetInvitesForUser(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      lastFetchedTime: lastFetchedTime,
      lastFetchedGroupId: lastFetchedGroupId,
    );
  }

  Future<void> acceptGroupInvites(String groupIdToAccept) async {
    final jwt = await getJwt();

    return Sentc.getApi().groupAcceptInvite(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupIdToAccept,
    );
  }

  Future<void> rejectGroupInvite(String groupIdToReject) async {
    final jwt = await getJwt();

    return Sentc.getApi().groupRejectInvite(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupIdToReject,
    );
  }

  Future<void> groupJoinRequest(String groupId) async {
    final jwt = await getJwt();

    return Sentc.getApi().groupJoinReq(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      groupId: "",
    );
  }

  Future<List<GroupInviteReqList>> sentJoinReq([GroupInviteReqList? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time ?? "0";
    final lastFetchedId = lastFetchedItem?.groupId ?? "none";

    return Sentc.getApi().groupGetSentJoinReqUser(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      lastFetchedTime: lastFetchedTime,
      lastFetchedGroupId: lastFetchedId,
    );
  }

  Future<void> deleteJoinReq(String id) async {
    final jwt = await getJwt();

    return Sentc.getApi().groupDeleteSentJoinReqUser(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      joinReqGroupId: id,
    );
  }

  //____________________________________________________________________________________________________________________

  Future<void> updateFileName(String fileId, SymKey contentKey, String? fileName) async {
    final jwt = await getJwt();

    return Sentc.getApi().fileFileNameUpdate(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      fileId: fileId,
      contentKey: contentKey.key,
    );
  }
}
