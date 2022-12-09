import 'dart:convert';

import 'package:sentc/group.dart' as group;
import 'package:sentc/sentc.dart';

Future<User> getUser(String deviceIdentifier, UserData data) async {
  final Map<String, int> keyMap = {};

  final List<UserKeyData> userKeys = [];

  for (var i = 0; i < data.userKeys.length; ++i) {
    var key = data.userKeys[i];

    keyMap[key.groupKeyId] = i;

    userKeys.add(UserKeyData._(
      key.privateKey,
      key.publicKey,
      key.groupKey,
      key.time,
      key.groupKeyId,
      key.signKey,
      key.verifyKey,
      key.exportedPublicKey,
      key.exportedVerifyKey,
    ));
  }

  final refreshToken = (Sentc.refresh_endpoint != REFRESH_OPTIONS.api) ? "" : data.refreshToken;

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
  );

  final storage = Sentc.getStorage();

  await storage.set("user_data_$deviceIdentifier", jsonEncode(user));

  return user;
}

/// Keys from the user group
class UserKeyData extends group.GroupKey {
  final String signKey;
  final String verifyKey;
  final String exportedPublicKey;
  final String exportedVerifyKey;

  UserKeyData._(
    String privateKey,
    String publicKey,
    String groupKey,
    String time,
    String groupKeyId,
    this.signKey,
    this.verifyKey,
    this.exportedPublicKey,
    this.exportedVerifyKey,
  ) : super(privateKey, publicKey, groupKey, time, groupKeyId);

  UserKeyData.fromJson(Map<String, dynamic> json)
      : signKey = json["signKey"],
        verifyKey = json["verifyKey"],
        exportedPublicKey = json["exportedPublicKey"],
        exportedVerifyKey = json["exportedVerifyKey"],
        super(
          json["privateKey"],
          json["publicKey"],
          json["groupKey"],
          json["time"],
          json["groupKeyId"],
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      "privateKey": privateKey,
      "publicKey": publicKey,
      "groupKey": groupKey,
      "time": time,
      "groupKeyId": groupKeyId,
      "signKey": signKey,
      "verifyKey": verifyKey,
      "exportedPublicKey": exportedPublicKey,
      "exportedVerifyKey": exportedVerifyKey
    };
  }
}

class User {
  final String _baseUrl;
  final String _appToken;
  final String _userIdentifier;
  late String jwt;
  final String refreshToken;
  final String userId;
  final String _deviceId;

  //device keys
  final String _privateDeviceKey;
  final String _publicDeviceKey;
  final String _signDeviceKey;
  final String _verifyDeviceKey;
  final String _exportedPublicDeviceKey;
  final String _exportedVerifyDeviceKey;

  //user keys
  final List<UserKeyData> _userKeys;
  final Map<String, int> _keyMap;
  String _newestKeyId;

  late List<group.GroupInviteListItem> groupInvites;

  void setGroupInvites(List<GroupInviteReqList> invites) {
    final List<group.GroupInviteListItem> list = [];

    for (var i = 0; i < invites.length; ++i) {
      var invite = invites[i];

      list.add(group.GroupInviteListItem(invite.groupId, invite.time));
    }

    groupInvites = list;
  }

  User._(
    this._baseUrl,
    this._appToken,
    this._userIdentifier,
    this.jwt,
    this.refreshToken,
    this.userId,
    this._deviceId,
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
  );

  User.fromJson(Map<String, dynamic> json, String baseUrl, String appToken)
      : _baseUrl = baseUrl,
        _appToken = appToken,
        jwt = json["jwt"],
        refreshToken = json["refreshToken"],
        userId = json["userId"],
        _deviceId = json["deviceId"],
        _privateDeviceKey = json["privateDeviceKey"],
        _publicDeviceKey = json["publicDeviceKey"],
        _signDeviceKey = json["signDeviceKey"],
        _verifyDeviceKey = json["verifyDeviceKey"],
        _exportedPublicDeviceKey = json["exportedPublicDeviceKey"],
        _exportedVerifyDeviceKey = json["exportedVerifyDeviceKey"],
        groupInvites = [],
        _userIdentifier = json["userIdentifier"],
        _keyMap = jsonDecode(json["keyMap"]),
        _newestKeyId = json["newestKeyId"],
        _userKeys = (jsonDecode(json["userKeys"]) as List).map((e) => UserKeyData.fromJson(e)).toList();

  Map<String, dynamic> toJson() {
    return {
      "jwt": jwt,
      "refreshToken": refreshToken,
      "userId": userId,
      "deviceId": _deviceId,
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
    };
  }

  Future<String> getJwt() async {
    final jwtData = await Sentc.getApi().decodeJwt(jwt: jwt);

    if (jwtData.exp <= DateTime.now().millisecondsSinceEpoch / 1000 + 30) {
      jwt = await Sentc.refreshJwt(jwt, refreshToken);

      final storage = Sentc.getStorage();

      await storage.set("user_data_$_userIdentifier", jsonEncode(this));
    }

    return jwt;
  }

  /// Fetch key for the actual user group
  Future<UserKeyData> _getUserKeys(String keyId, [bool? first]) async {
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

  fetchUserKey(String keyId, [bool? first]) async {
    final jwt = await getJwt();

    final userKeys = await Sentc.getApi().fetchUserKey(
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      keyId: keyId,
      privateKey: _privateDeviceKey,
    );

    _userKeys.add(UserKeyData._(
      userKeys.privateKey,
      userKeys.publicKey,
      userKeys.groupKey,
      userKeys.time,
      userKeys.groupKeyId,
      userKeys.signKey,
      userKeys.verifyKey,
      userKeys.exportedPublicKey,
      userKeys.exportedVerifyKey,
    ));

    if (first != null && first) {
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

    _userKeys.add(UserKeyData._(
      key.privateKey,
      key.publicKey,
      key.groupKey,
      key.time,
      key.groupKeyId,
      key.signKey,
      key.verifyKey,
      key.exportedPublicKey,
      key.exportedVerifyKey,
    ));

    _keyMap[key.groupKeyId] = lastIndex;
  }

  Future<String> getPrivateKey(String keyId) async {
    final key = await _getUserKeys(keyId);

    return key.privateKey;
  }

  Future<UserPublicKey> getPublicKey(String replyId) {
    return Sentc.getUserPublicKey(replyId);
  }

  UserKeyData _getNewestKey() {
    final index = _keyMap[_newestKeyId] ??= 0;

    return _userKeys[index];
  }

  String getNewestPublicKey() {
    return _getNewestKey().publicKey;
  }

  String getNewestSignKey() {
    return _getNewestKey().signKey;
  }

  Future<String> getSignKey() async {
    return getNewestSignKey();
  }

  //____________________________________________________________________________________________________________________

  Future<void> updateUser(String newIdentifier) {
    return Sentc.getApi().updateUser(baseUrl: _baseUrl, authToken: _appToken, jwt: jwt, userIdentifier: newIdentifier);
  }

  Future<void> resetPassword(String newPassword) async {
    final jwt = await getJwt();

    final decryptedPrivateKey = _privateDeviceKey;
    final decryptedSignKey = _signDeviceKey;

    return Sentc.getApi().resetPassword(
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      newPassword: newPassword,
      decryptedPrivateKey: decryptedPrivateKey,
      decryptedSignKey: decryptedSignKey,
    );
  }

  Future<void> changePassword(String oldPassword, String newPassword) {
    return Sentc.getApi().changePassword(
      baseUrl: _baseUrl,
      authToken: _appToken,
      userIdentifier: _userIdentifier,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logOut() {
    final storage = Sentc.getStorage();

    return storage.delete("user_data_$_userIdentifier");
  }

  Future<void> deleteUser(String password) async {
    await Sentc.getApi().deleteUser(
      baseUrl: _baseUrl,
      authToken: _appToken,
      userIdentifier: _userIdentifier,
      password: password,
    );

    return logOut();
  }

  Future<void> deleteDevice(String password, String deviceId) async {
    await Sentc.getApi().deleteDevice(
      baseUrl: _baseUrl,
      authToken: _appToken,
      deviceIdentifier: _userIdentifier,
      password: password,
      deviceId: deviceId,
    );

    if (deviceId == _deviceId) {
      //only log the device out if it is the actual used device
      return logOut();
    }
  }

  //____________________________________________________________________________________________________________________

  Future<PreRegisterDeviceData> prepareRegisterDevice(String serverOutput, int page) async {
    final keyCount = _userKeys.length;

    final keyString = group.prepareKeys(_userKeys, page).str;

    final out = await Sentc.getApi().prepareRegisterDevice(
      serverOutput: serverOutput,
      userKeys: keyString,
      keyCount: keyCount,
    );

    return PreRegisterDeviceData(input: out.input, exportedPublicKey: out.exportedPublicKey);
  }

  Future<void> registerDevice(String serverOutput) async {
    final keyCount = _userKeys.length;

    final keyString = group.prepareKeys(_userKeys, 0).str;

    final jwt = await getJwt();

    final out = await Sentc.getApi().registerDevice(
      baseUrl: _baseUrl,
      authToken: _appToken,
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
        baseUrl: _baseUrl,
        authToken: _appToken,
        jwt: jwt,
        sessionId: sessionId,
        userPublicKey: publicKey,
        groupKeys: nextKeys.str,
      ));

      i++;
    }

    await Future.wait(p);
  }

  Future<List<UserDeviceList>> getDevices(UserDeviceList? lastFetchedItem) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time ?? "0";
    final lastId = lastFetchedItem?.deviceId ?? "none";

    final out = await Sentc.getApi().getUserDevices(
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      lastFetchedTime: lastFetchedTime,
      lastFetchedId: lastId,
    );

    final List<UserDeviceList> devices = [];

    for (var i = 0; i < out.length; ++i) {
      var device = out[i];

      devices.add(UserDeviceList(device.time, device.deviceId, device.deviceIdentifier));
    }

    return devices;
  }

  //____________________________________________________________________________________________________________________

  Future<void> keyRotation() async {
    final jwt = await getJwt();

    final keyId = await Sentc.getApi().userKeyRotation(
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      publicDeviceKey: _publicDeviceKey,
      preUserKey: _getNewestKey().groupKey,
    );

    return fetchUserKey(keyId, true);
  }

  Future<void> finishKeyRotation() async {
    final jwt = await getJwt();

    List<KeyRotationGetOut> keys =
        await Sentc.getApi().userPreDoneKeyRotation(baseUrl: _baseUrl, authToken: _appToken, jwt: jwt);

    bool nextRound = false;
    int roundsLeft = 10;

    final publicKey = _publicDeviceKey;
    final privateKey = _privateDeviceKey;

    do {
      final List<KeyRotationGetOut> leftKeys = [];

      for (var i = 0; i < keys.length; ++i) {
        var key = keys[i];

        UserKeyData preKey;

        try {
          preKey = await _getUserKeys(key.preGroupKeyId);
        } catch (e) {
          //key not found -> try next round
          leftKeys.add(key);
          continue;
        }

        await Sentc.getApi().userFinishKeyRotation(
          baseUrl: _baseUrl,
          authToken: _appToken,
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
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      creatorsPublicKey: getNewestPublicKey(),
      groupAsMember: "",
    );
  }

  Future<group.Group> getGroup(String groupId, [String groupAsMember = ""]) {
    return group.getGroup(groupId, _baseUrl, _appToken, this, false, groupAsMember);
  }

  Future<List<ListGroups>> getGroups(ListGroups? lastFetchedItem) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time.toString() ?? "0";
    final lastFetchedGroupId = lastFetchedItem?.groupId ?? "none";

    return Sentc.getApi().groupGetGroupsForUser(
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      lastFetchedTime: lastFetchedTime,
      lastFetchedGroupId: lastFetchedGroupId,
      groupId: "",
    );
  }

  Future<List<GroupInviteReqList>> getGroupInvites(GroupInviteReqList? lastItem) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastItem?.time.toString() ?? "0";
    final lastFetchedGroupId = lastItem?.groupId ?? "none";

    return Sentc.getApi().groupGetInvitesForUser(
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      lastFetchedTime: lastFetchedTime,
      lastFetchedGroupId: lastFetchedGroupId,
      groupId: "",
      groupAsMember: "",
    );
  }

  Future<void> acceptGroupInvites(String groupIdToAccept) async {
    final jwt = await getJwt();

    return Sentc.getApi().groupAcceptInvite(
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      id: groupIdToAccept,
      groupId: "",
      groupAsMember: "",
    );
  }

  Future<void> rejectGroupInvite(groupIdToReject) async {
    final jwt = await getJwt();

    return Sentc.getApi().groupRejectInvite(
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      id: groupIdToReject,
      groupId: "",
      groupAsMember: "",
    );
  }
}

//______________________________________________________________________________________________________________________

class PreRegisterDeviceData {
  final String input;
  final String exportedPublicKey;

  PreRegisterDeviceData({
    required this.input,
    required this.exportedPublicKey,
  });
}

class UserDeviceList {
  final String deviceId;
  final String time;
  final String deviceIdentifier;

  UserDeviceList(this.time, this.deviceId, this.deviceIdentifier);
}
