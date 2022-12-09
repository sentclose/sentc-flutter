import 'dart:convert';

import 'package:sentc/generated.dart';
import 'package:sentc/sentc.dart';
import 'package:sentc/user.dart';

PrepareKeysResult prepareKeys(List<GroupKey> keys, int page) {
  final offset = page * 50;
  int end = offset + 50;

  if (end < keys.length) {
    end = keys.length;
  }

  final keySlice = keys.sublist(offset, end);

  String str = "[";

  for (var i = 0; i < keySlice.length; ++i) {
    var key = keySlice[i].groupKey;

    str += "$key,";
  }

  //remove the trailing comma
  str = str.substring(0, str.length - 1);

  str += "]";

  return PrepareKeysResult(str, end < keys.length - 1);
}

class PrepareKeysResult {
  final String str;
  final bool end;

  PrepareKeysResult(this.str, this.end);
}

//______________________________________________________________________________________________________________________
Future<Group> getGroup(String groupId, String baseUrl, String appToken, User user,
    [bool parent = false, String groupAsMember = "", bool rek = false]) async {
  //
  final storage = Sentc.getStorage();

  String userId;

  if (groupAsMember == "") {
    userId = user.userId;
  } else {
    userId = groupAsMember;
  }

  final groupKey = "group_data_user_${userId}_id_$groupId";

  final groupJson = await storage.getItem(groupKey);

  final jwt = await user.getJwt();

  if (groupJson != null) {
    //load the group from json data and just look for group updates
    final update = await Sentc.getApi().groupGetGroupUpdates(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      groupAsMember: groupAsMember,
    );

    final group = Group.fromJson(jsonDecode(groupJson), baseUrl, appToken, user, parent, update.keyUpdate);

    group.rank = update.rank;

    return group;
  }

  //group data was not in the cache
  final out = await Sentc.getApi().groupGetGroupData(
    baseUrl: baseUrl,
    authToken: appToken,
    jwt: jwt,
    id: groupId,
    groupAsMember: groupAsMember,
  );

  final accessByGroupAsMember = out.accessByGroupAsMember ?? "";

  if (accessByGroupAsMember != "" && rek) {
    //only load the group once even for rek. calls.
    //if group as member set. load this group first to get the keys
    //no group as member flag
    await getGroup(accessByGroupAsMember, baseUrl, appToken, user);
  }

  if (out.accessByParentGroup != null) {
    parent = true;
    //check if the parent group is fetched
    //rec here because the user might be in a parent of the parent group or so
    //check the tree until we found the group where the user access by user

    await getGroup(out.parentGroupId, baseUrl, appToken, user, false, groupAsMember, true);
  }

  final groupObj = Group._(
    baseUrl,
    appToken,
    user,
    groupId,
    out.parentGroupId,
    parent,
    out.rank,
    out.keyUpdate,
    out.createdTime,
    out.joinedTime,
    [],
    {},
    "_newestKeyId",
    out.accessByParentGroup,
    accessByGroupAsMember,
  );

  final keys = await groupObj.decryptKey(out.keys);
  Map<String, int> keyMap = {};

  for (var i = 0; i < keys.length; ++i) {
    var key = keys[i];
    keyMap[key.groupKeyId] = i;
  }

  groupObj._keys = keys;
  groupObj._keyMap = keyMap;
  groupObj._newestKeyId = keys[0].groupKeyId;

  if (keys.length >= 50) {
    //fetch the rest of the keys
    await groupObj.fetchKeys();
  }

  await storage.set(groupKey, jsonEncode(groupObj));

  return groupObj;
}

//______________________________________________________________________________________________________________________

class GroupInviteListItem {
  final String groupId;
  final String time;

  GroupInviteListItem(this.groupId, this.time);
}

class GroupKey {
  final String privateKey;
  final String publicKey;
  final String groupKey;
  final String time;
  final String groupKeyId;

  GroupKey(this.privateKey, this.publicKey, this.groupKey, this.time, this.groupKeyId);

  GroupKey.fromJson(Map<String, dynamic> json)
      : privateKey = json["privateKey"],
        publicKey = json["publicKey"],
        groupKey = json["groupKey"],
        time = json["time"],
        groupKeyId = json["groupKeyId"];

  Map<String, dynamic> toJson() {
    return {
      "privateKey": privateKey,
      "publicKey": publicKey,
      "groupKey": groupKey,
      "time": time,
      "groupKeyId": groupKeyId,
    };
  }
}

//______________________________________________________________________________________________________________________

class Group {
  final String _baseUrl;
  final String _appToken;

  final User _user;

  final String groupId;
  final String parentGroupId;
  final bool _fromParent;
  int rank;
  bool keyUpdate;
  final String createdTime;
  final String joinedTime;

  List<GroupKey> _keys;
  Map<String, int> _keyMap;
  String _newestKeyId;
  final String? accessByParentGroup;
  final String accessByGroupAsMember;

  Group._(
    this._baseUrl,
    this._appToken,
    this._user,
    this.groupId,
    this.parentGroupId,
    this._fromParent,
    this.rank,
    this.keyUpdate,
    this.createdTime,
    this.joinedTime,
    this._keys,
    this._keyMap,
    this._newestKeyId,
    this.accessByParentGroup,
    this.accessByGroupAsMember,
  );

  Group.fromJson(
    Map<String, dynamic> json,
    String baseUrl,
    String appToken,
    User user,
    bool fromParent,
    this.keyUpdate,
  )   : _baseUrl = baseUrl,
        _appToken = appToken,
        _user = user,
        _fromParent = fromParent,
        groupId = json["groupId"],
        parentGroupId = json["parentGroupId"],
        createdTime = json["createdTime"],
        joinedTime = json["joinedTime"],
        rank = json["rank"],
        _keyMap = jsonDecode(json["keyMap"]),
        _newestKeyId = json["newestKeyId"],
        accessByParentGroup = json["accessByParentGroup"],
        accessByGroupAsMember = json["accessByGroupAsMember"],
        _keys = (jsonDecode(json["keys"]) as List).map((e) => GroupKey.fromJson(e)).toList();

  Map<String, dynamic> toJson() {
    return {
      "groupId": groupId,
      "parentGroupId": parentGroupId,
      "createdTime": createdTime,
      "joinedTime": joinedTime,
      "rank": rank,
      "keyMap": jsonEncode(_keyMap),
      "newestKeyId": _newestKeyId,
      "keys": jsonEncode(_keys),
      "accessByParentGroup": accessByParentGroup,
      "accessByGroupAsMember": accessByGroupAsMember,
    };
  }

  Future<GroupKey> getGroupKey(String keyId, [bool newKeys = false]) async {
    var keyIndex = _keyMap[keyId];

    if (keyIndex == null) {
      final jwt = await _user.getJwt();

      final fetchedKey = await Sentc.getApi().groupGetGroupKey(
        baseUrl: _baseUrl,
        authToken: _appToken,
        jwt: jwt,
        id: groupId,
        keyId: keyId,
        groupAsMember: accessByGroupAsMember,
      );

      final decryptedKey = await decryptKey([fetchedKey]);

      final lastIndex = _keys.length;
      _keys.add(decryptedKey[0]);
      _keyMap[decryptedKey[0].groupKeyId] = lastIndex;

      if (newKeys) {
        _newestKeyId = decryptedKey[0].groupKeyId;
      }

      String actualUserId;
      if (accessByGroupAsMember == "") {
        actualUserId = _user.userId;
      } else {
        actualUserId = accessByGroupAsMember;
      }

      final groupKey = "group_data_user_${actualUserId}_id_$groupId";

      final storage = Sentc.getStorage();
      await storage.set(groupKey, jsonEncode(this));

      keyIndex = _keyMap[keyId];
      if (keyIndex == null) {
        throw Exception("Group key not found. Maybe done key rotation will help");
      }
    }

    try {
      return _keys[keyIndex];
    } catch (e) {
      throw Exception("Group key not found. Maybe done key rotation will help");
    }
  }

  Future<String> _getPrivateKey(String keyId) async {
    if (!_fromParent && (accessByGroupAsMember == "")) {
      return _user.getPrivateKey(keyId);
    }

    if (_fromParent) {
      String userId;
      if (accessByGroupAsMember == "") {
        userId = _user.userId;
      } else {
        userId = accessByGroupAsMember;
      }

      final storage = Sentc.getStorage();
      final groupKey = "group_data_user_${userId}_id_$parentGroupId";
      final groupJson = await storage.getItem(groupKey);

      if (groupJson == null) {
        throw Exception(
          "Parent group not found. THis group was access from parent group but the parent group data is gone",
        );
      }

      final parentGroup = Group.fromJson(
        jsonDecode(groupJson),
        _baseUrl,
        _appToken,
        _user,
        false,
        false,
      );

      final parentGroupKey = await parentGroup.getGroupKey(keyId);

      return parentGroupKey.privateKey;
    }

    //access over group as member
    final storage = Sentc.getStorage();
    final groupKey = "group_data_user_${_user.userId}_id_$accessByGroupAsMember";
    final groupJson = await storage.getItem(groupKey);

    if (groupJson == null) {
      throw Exception(
        "Connected group not found. This group was access from a connected group but the group data is gone.",
      );
    }

    final connectedGroup = Group.fromJson(
      jsonDecode(groupJson),
      _baseUrl,
      _appToken,
      _user,
      false,
      false,
    );

    final connectedGroupKey = await connectedGroup.getGroupKey(keyId);

    return connectedGroupKey.privateKey;
  }

  Future<List<GroupKey>> decryptKey(List<GroupOutDataKeys> keys) async {
    List<GroupKey> list = [];

    for (var i = 0; i < keys.length; ++i) {
      var key = keys[i];
      final privateKey = await _getPrivateKey(key.privateKeyId);

      final decryptedKeys = await Sentc.getApi().groupDecryptKey(privateKey: privateKey, serverKeyData: key.keyData);

      list.add(GroupKey(
        decryptedKeys.privateGroupKey,
        decryptedKeys.publicGroupKey,
        decryptedKeys.groupKey,
        decryptedKeys.time,
        decryptedKeys.groupKeyId,
      ));
    }

    return list;
  }

  Future<void> fetchKeys() async {
    final jwt = await _user.getJwt();

    var lastItem = _keys[_keys.length - 1];

    bool nextFetch = true;

    final List<GroupKey> keys = [];

    while (nextFetch) {
      final fetchedKeys = await Sentc.getApi().groupGetGroupKeys(
        baseUrl: _baseUrl,
        authToken: _appToken,
        jwt: jwt,
        id: groupId,
        lastFetchedTime: lastItem.time,
        lastFetchedKeyId: lastItem.groupKeyId,
        groupAsMember: accessByGroupAsMember,
      );

      final decryptedKeys = await decryptKey(fetchedKeys);

      keys.addAll(decryptedKeys);

      nextFetch = fetchedKeys.length >= 50;

      lastItem = decryptedKeys[decryptedKeys.length - 1];
    }

    final lastInsertedIndex = _keys.length;

    for (var i = 0; i < keys.length; ++i) {
      var key = keys[i];

      _keyMap[key.groupKeyId] = i + lastInsertedIndex;
    }

    _keys.addAll(keys);
  }

  //____________________________________________________________________________________________________________________

  deleteGroup() async {
    final jwt = await _user.getJwt();

    return Sentc.getApi().groupDeleteGroup(
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      id: groupId,
      adminRank: rank,
      groupAsMember: accessByGroupAsMember,
    );
  }

  //____________________________________________________________________________________________________________________
}
