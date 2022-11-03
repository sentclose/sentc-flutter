import 'dart:convert';

import 'package:sentc/generated.dart';
import 'package:sentc/group.dart';
import 'package:sentc/sentc.dart';

Future<User> getUser(String deviceIdentifier, UserData data) async {
  final Map<String, int> keyMap = {};

  final List<_UserKeyData> userKeys = [];

  for (var i = 0; i < data.userKeys.length; ++i) {
    var key = data.userKeys[i];

    keyMap[key.groupKeyId] = i;

    userKeys.add(_UserKeyData._(
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
  );

  final storage = Sentc.getStorage();

  await storage.set("user_data_$deviceIdentifier", jsonEncode(user));

  return user;
}

/// Keys from the user group
class _UserKeyData {
  final String privateKey;
  final String publicKey;
  final String groupKey;
  final String time;
  final String groupKeyId;
  final String signKey;
  final String verifyKey;
  final String exportedPublicKey;
  final String exportedVerifyKey;

  const _UserKeyData._(
    this.privateKey,
    this.publicKey,
    this.groupKey,
    this.time,
    this.groupKeyId,
    this.signKey,
    this.verifyKey,
    this.exportedPublicKey,
    this.exportedVerifyKey,
  );

  _UserKeyData.fromJson(Map<String, dynamic> json)
      : privateKey = json["privateKey"],
        publicKey = json["publicKey"],
        groupKey = json["groupKey"],
        time = json["time"],
        groupKeyId = json["groupKeyId"],
        signKey = json["signKey"],
        verifyKey = json["verifyKey"],
        exportedPublicKey = json["exportedPublicKey"],
        exportedVerifyKey = json["exportedVerifyKey"];

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
  final String _userId;
  final String _deviceId;

  //device keys
  final String _privateDeviceKey;
  final String _publicDeviceKey;
  final String _signDeviceKey;
  final String _verifyDeviceKey;
  final String _exportedPublicDeviceKey;
  final String _exportedVerifyDeviceKey;

  //user keys
  final List<_UserKeyData> _userKeys;
  final Map<String, int> _keyMap;

  late List<GroupInviteListItem> _groupInvites;

  void setGroupInvites(List<GroupInviteReqList> invites) {
    final List<GroupInviteListItem> list = [];

    for (var i = 0; i < invites.length; ++i) {
      var invite = invites[i];

      list.add(GroupInviteListItem(invite.groupId, invite.time));
    }

    _groupInvites = list;
  }

  User._(
    this._baseUrl,
    this._appToken,
    this._userIdentifier,
    this.jwt,
    this.refreshToken,
    this._userId,
    this._deviceId,
    this._privateDeviceKey,
    this._publicDeviceKey,
    this._signDeviceKey,
    this._verifyDeviceKey,
    this._exportedPublicDeviceKey,
    this._exportedVerifyDeviceKey,
    this._userKeys,
    this._groupInvites,
    this._keyMap,
  );

  User.fromJson(Map<String, dynamic> json, String baseUrl, String appToken)
      : _baseUrl = baseUrl,
        _appToken = appToken,
        jwt = json["jwt"],
        refreshToken = json["refreshToken"],
        _userId = json["userId"],
        _deviceId = json["deviceId"],
        _privateDeviceKey = json["privateDeviceKey"],
        _publicDeviceKey = json["publicDeviceKey"],
        _signDeviceKey = json["signDeviceKey"],
        _verifyDeviceKey = json["verifyDeviceKey"],
        _exportedPublicDeviceKey = json["exportedPublicDeviceKey"],
        _exportedVerifyDeviceKey = json["exportedVerifyDeviceKey"],
        _groupInvites = [],
        _userIdentifier = json["userIdentifier"],
        _keyMap = jsonDecode(json["keyMap"]),
        _userKeys =
            (jsonDecode(json["userKeys"]) as List).map((e) => _UserKeyData.fromJson(e)).toList();

  Map<String, dynamic> toJson() {
    return {
      "jwt": jwt,
      "refreshToken": refreshToken,
      "userId": _userId,
      "deviceId": _deviceId,
      "privateDeviceKey": _privateDeviceKey,
      "publicDeviceKey": _publicDeviceKey,
      "signDeviceKey": _signDeviceKey,
      "verifyDeviceKey": _verifyDeviceKey,
      "exportedPublicDeviceKey": _exportedPublicDeviceKey,
      "exportedVerifyDeviceKey": _exportedVerifyDeviceKey,
      "userIdentifier": _userIdentifier,
      "keyMap": jsonEncode(_keyMap),
      "userKeys": jsonEncode(_userKeys)
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

  //________________________________________________________________________________________________
}
