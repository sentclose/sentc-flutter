import 'dart:convert';
import 'dart:io';

import 'package:sentc/src/crypto/abstract_sym_crypto.dart';
import 'package:sentc/sentc.dart';
import 'package:sentc/src/rust/api/user.dart' as api_user;
import 'package:sentc/src/rust/api/group.dart' as api_group;
import 'package:sentc/src/rust/api/file.dart' as api_file;
import 'package:sentc/src/rust/api/crypto.dart' as api_crypto;

PrepareKeysResult prepareKeys(List<GroupKey> keys, int page) {
  final offset = page * 50;
  int end = offset + 50;

  if (end > keys.length) {
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
Future<Group> getGroup(
  String groupId,
  String baseUrl,
  String appToken,
  User user, [
  bool parent = false,
  String? groupAsMember,
  int verify = 0,
  bool rek = false,
]) async {
  final storage = Sentc.getStorage();

  String userId;

  if (groupAsMember == null || groupAsMember == "") {
    userId = user.userId;
  } else {
    userId = groupAsMember;
  }

  final groupKey = "group_data_user_${userId}_id_$groupId";

  final groupJson = await storage.getItem(groupKey);

  final jwt = await user.getJwt();

  if (groupJson != null) {
    final group = Group.fromJson(jsonDecode(groupJson), baseUrl, appToken, user, parent);

    if (group.lastCheckTime + 60000 * 5 < DateTime.now().millisecondsSinceEpoch) {
      //load the group from json data and just look for group updates
      final update = await api_group.groupGetGroupUpdates(
        baseUrl: baseUrl,
        authToken: appToken,
        jwt: jwt,
        id: groupId,
        groupAsMember: groupAsMember,
      );

      group.rank = update.rank;
      group.keyUpdate = update.keyUpdate;
      group.lastCheckTime = DateTime.now().millisecondsSinceEpoch;

      //update the group data in the storage
      await storage.set(groupKey, jsonEncode(group));
    }

    return group;
  }

  //group data was not in the cache
  final out = await api_group.groupGetGroupData(
    baseUrl: baseUrl,
    authToken: appToken,
    jwt: jwt,
    id: groupId,
    groupAsMember: groupAsMember,
  );

  final accessByGroupAsMember = out.accessByGroupAsMember;

  if (accessByGroupAsMember != null && accessByGroupAsMember != "" && !rek) {
    //only load the group once even for rek. calls.
    //if group as member set. load this group first to get the keys
    //no group as member flag
    await getGroup(accessByGroupAsMember, baseUrl, appToken, user, false, null, verify);
  }

  if (out.accessByParentGroup != null) {
    parent = true;
    //check if the parent group is fetched
    //rec here because the user might be in a parent of the parent group or so
    //check the tree until we found the group where the user access by user

    await getGroup(out.parentGroupId!, baseUrl, appToken, user, false, groupAsMember, verify, true);
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
    [],
    [],
    DateTime.now().millisecondsSinceEpoch,
  );

  final keys = await groupObj.decryptKey(out.keys, verify);
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
    await groupObj.fetchKeys(jwt, verify);
  }

  //now decrypt the hmac key for searchable encryption, the right key must be fetched before
  final decryptedHmacKeys = await groupObj.decryptHmacKeys(out.hmacKeys);
  groupObj._hmacKeys = decryptedHmacKeys;

  final decryptedSortableKeys = await groupObj.decryptSortableKeys(out.sortableKeys);
  groupObj._sortableKeys = decryptedSortableKeys;

  await Future.wait([
    //store the group data
    storage.set(groupKey, jsonEncode(groupObj)),
    //save always the newest public key
    storage.set(
      "group_public_key_$groupId",
      jsonEncode(PublicGroupKeyData(keys[0].groupKeyId, keys[0].exportedPublicKey)),
    ),
  ]);

  return groupObj;
}

//______________________________________________________________________________________________________________________

class GroupKey extends api_group.GroupKeyData {
  GroupKey({
    required super.privateGroupKey,
    required super.publicGroupKey,
    required super.groupKey,
    required super.time,
    required super.groupKeyId,
    required super.exportedPublicKey,
  });

  factory GroupKey.fromJson(Map<String, dynamic> json) => GroupKey(
        privateGroupKey: json['privateGroupKey'] as String,
        publicGroupKey: json['publicGroupKey'] as String,
        groupKey: json['groupKey'] as String,
        time: json['time'] as String,
        groupKeyId: json['groupKeyId'] as String,
        exportedPublicKey: json["exportedPublicKey"] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'privateGroupKey': privateGroupKey,
        'publicGroupKey': publicGroupKey,
        'groupKey': groupKey,
        'time': time,
        'groupKeyId': groupKeyId,
        'exportedPublicKey': exportedPublicKey
      };

  factory GroupKey.fromServer(api_group.GroupKeyData key) => GroupKey(
        privateGroupKey: key.privateGroupKey,
        publicGroupKey: key.publicGroupKey,
        groupKey: key.groupKey,
        time: key.time,
        groupKeyId: key.groupKeyId,
        exportedPublicKey: key.exportedPublicKey,
      );
}

//______________________________________________________________________________________________________________________

class Group extends AbstractSymCrypto {
  final User _user;

  final String groupId;
  final String? parentGroupId;
  final bool _fromParent;
  int rank;
  int lastCheckTime;
  bool keyUpdate;
  final String createdTime;
  final String joinedTime;

  List<GroupKey> _keys;
  List<String> _hmacKeys;
  List<String> _sortableKeys;
  Map<String, int> _keyMap;
  String _newestKeyId;
  final String? accessByParentGroup;
  final String? accessByGroupAsMember;

  Group._(
    super.baseUrl,
    super.appToken,
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
    this._hmacKeys,
    this._sortableKeys,
    this.lastCheckTime,
  );

  Group.fromJson(
    Map<String, dynamic> json,
    super.baseUrl,
    super.appToken,
    this._user,
    this._fromParent,
  )   : groupId = json["groupId"],
        lastCheckTime = json["lastCheckTime"],
        keyUpdate = json["keyUpdate"],
        parentGroupId = json["parentGroupId"],
        createdTime = json["createdTime"],
        joinedTime = json["joinedTime"],
        rank = json["rank"],
        _keyMap = Map<String, int>.from(jsonDecode(json["keyMap"]) as Map<String, dynamic>),
        _newestKeyId = json["newestKeyId"],
        accessByParentGroup = json["accessByParentGroup"],
        accessByGroupAsMember = json["accessByGroupAsMember"],
        _keys = (jsonDecode(json["keys"]) as List).map((e) => GroupKey.fromJson(e)).toList(),
        _hmacKeys = (jsonDecode(json["hmacKeys"]) as List<dynamic>).map((e) => e as String).toList(),
        _sortableKeys = (jsonDecode(json["sortableKeys"]) as List<dynamic>).map((e) => e as String).toList();

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
      "hmacKeys": jsonEncode(_hmacKeys),
      "sortableKeys": jsonEncode(_sortableKeys),
      "lastCheckTime": lastCheckTime,
      "keyUpdate": keyUpdate,
    };
  }

  @override
  Future<String> getJwt() {
    return _user.getJwt();
  }

  @override
  Future<String> getSignKey() {
    //always use the users sign key
    return _user.getSignKey();
  }

  @override
  String getSignKeySync() {
    //always use the users sign key
    return _user.getSignKeySync();
  }

  @override
  Future<String> getSymKeyById(String keyId) async {
    final key = await getGroupKey(keyId);

    return key.groupKey;
  }

  @override
  String getSymKeyByIdSync(String keyId) {
    final key = getGroupKeySync(keyId);

    return key.groupKey;
  }

  @override
  Future<SymKeyToEncryptResult> getSymKeyToEncrypt() {
    final latestKey = _getNewestKey()!;

    return Future.value(SymKeyToEncryptResult(latestKey.groupKeyId, latestKey.groupKey));
  }

  @override
  SymKeyToEncryptResult getSymKeyToEncryptSync() {
    final latestKey = _getNewestKey()!;

    return SymKeyToEncryptResult(latestKey.groupKeyId, latestKey.groupKey);
  }

  String getNewestHmacKey() {
    return _hmacKeys[0];
  }

  String getNewestSortableKey() {
    return _sortableKeys[0];
  }

  //____________________________________________________________________________________________________________________

  GroupKey getGroupKeySync(String keyId) {
    var keyIndex = _keyMap[keyId];

    if (keyIndex == null) {
      throw Exception("Group key not found. Maybe done key rotation will help");
    }

    try {
      return _keys[keyIndex];
    } catch (e) {
      throw Exception("Group key not found. Maybe done key rotation will help");
    }
  }

  Future<GroupKey> getGroupKey(String keyId, [bool newKeys = false, int verify = 0]) async {
    var keyIndex = _keyMap[keyId];

    if (keyIndex == null) {
      final jwt = await getJwt();

      final fetchedKey = await api_group.groupGetGroupKey(
        baseUrl: baseUrl,
        authToken: appToken,
        jwt: jwt,
        id: groupId,
        keyId: keyId,
        groupAsMember: accessByGroupAsMember,
      );

      final decryptedKey = await decryptKey([fetchedKey], verify);

      final lastIndex = _keys.length;
      _keys.add(decryptedKey[0]);
      _keyMap[decryptedKey[0].groupKeyId] = lastIndex;

      final storage = Sentc.getStorage();

      if (newKeys) {
        _newestKeyId = decryptedKey[0].groupKeyId;

        //save also the newest key in the cache
        storage.set(
          "group_public_key_$groupId",
          jsonEncode(PublicGroupKeyData(_newestKeyId, decryptedKey[0].exportedPublicKey)),
        );
      }

      String actualUserId;
      if (accessByGroupAsMember == null) {
        actualUserId = _user.userId;
      } else {
        actualUserId = accessByGroupAsMember!;
      }

      final groupKey = "group_data_user_${actualUserId}_id_$groupId";

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

  GroupKey? _getNewestKey() {
    final index = _keyMap[_newestKeyId] ?? 0;

    try {
      return _keys[index];
    } catch (e) {
      return null;
    }
  }

  Future<Group> _getGroupRefFromParent() async {
    String userId;
    if (accessByGroupAsMember == null) {
      userId = _user.userId;
    } else {
      userId = accessByGroupAsMember!;
    }

    final storage = Sentc.getStorage();
    final groupKey = "group_data_user_${userId}_id_$parentGroupId";
    final groupJson = await storage.getItem(groupKey);

    if (groupJson == null) {
      throw Exception(
        "Parent group not found. THis group was access from parent group but the parent group data is gone",
      );
    }

    return Group.fromJson(
      jsonDecode(groupJson),
      baseUrl,
      appToken,
      _user,
      false,
    );
  }

  Future<Group> _getGroupRefFromGroupAsMember() async {
    //access over group as member
    final storage = Sentc.getStorage();
    final groupKey = "group_data_user_${_user.userId}_id_$accessByGroupAsMember";
    final groupJson = await storage.getItem(groupKey);

    if (groupJson == null) {
      throw Exception(
        "Connected group not found. This group was access from a connected group but the group data is gone.",
      );
    }

    return Group.fromJson(
      jsonDecode(groupJson),
      baseUrl,
      appToken,
      _user,
      false,
    );
  }

  Future<String> _getPublicKey() async {
    if (!_fromParent && accessByGroupAsMember == null) {
      return _user.getNewestPublicKey();
    }

    if (_fromParent) {
      final parentGroup = await _getGroupRefFromParent();

      //get the newest key from parent
      final newestKey = parentGroup._getNewestKey();

      if (newestKey == null) {
        throw Exception(
          "Parent group not found. This group was access from parent group but the parent group data is gone.",
        );
      }

      return newestKey.publicGroupKey;
    }

    final connectedGroup = await _getGroupRefFromGroupAsMember();

    final newestKey = connectedGroup._getNewestKey();

    if (newestKey == null) {
      throw Exception(
        "Connected group not found. This group was access from a connected group but the group data is gone.",
      );
    }

    return newestKey.publicGroupKey;
  }

  Future<String> _getPrivateKey(String keyId) async {
    if (!_fromParent && accessByGroupAsMember == null) {
      return _user.getPrivateKey(keyId);
    }

    if (_fromParent) {
      final parentGroup = await _getGroupRefFromParent();

      final parentGroupKey = await parentGroup.getGroupKey(keyId);

      return parentGroupKey.privateGroupKey;
    }

    //access over group as member
    final connectedGroup = await _getGroupRefFromGroupAsMember();

    final connectedGroupKey = await connectedGroup.getGroupKey(keyId);

    return connectedGroupKey.privateGroupKey;
  }

  Future<List<GroupKey>> decryptKey(List<api_group.GroupOutDataKeys> keys, [int verify = 0]) async {
    List<GroupKey> list = [];

    for (var i = 0; i < keys.length; ++i) {
      var key = keys[i];
      final privateKey = await _getPrivateKey(key.privateKeyId);

      String? verifyKey;

      if (verify > 0 && key.signedByUserId != null && key.signedByUserSignKeyId != null) {
        try {
          verifyKey = await Sentc.getUserVerifyKey(key.signedByUserId!, key.signedByUserSignKeyId!);
        } catch (e) {
          //for verify = 1 ignore error and just decrypt the key
          if (verify == 2) {
            //check if code === 100 -> user not found. if so ignore this error and use no verify key
            final err = SentcError.fromError(e);
            if (err.status != "server_100") {
              rethrow;
            }
          }
        }
      }

      final decryptedKeys =
          await api_group.groupDecryptKey(privateKey: privateKey, serverKeyData: key.keyData, verifyKey: verifyKey);

      list.add(GroupKey.fromServer(decryptedKeys));
    }

    return list;
  }

  Future<List<String>> decryptHmacKeys(List<api_group.GroupOutDataHmacKeys> keys) async {
    List<String> list = [];

    for (var i = 0; i < keys.length; ++i) {
      var key = keys[i];

      final groupKey = await getSymKeyById(key.groupKeyId);

      final decryptedHmacKey = await api_group.groupDecryptHmacKey(groupKey: groupKey, serverKeyData: key.keyData);

      list.add(decryptedHmacKey);
    }

    return list;
  }

  Future<List<String>> decryptSortableKeys(List<api_group.GroupOutDataSortableKeys> keys) async {
    List<String> list = [];

    for (var i = 0; i < keys.length; ++i) {
      var key = keys[i];

      final groupKey = await getSymKeyById(key.groupKeyId);

      final decryptedKey = await api_group.groupDecryptSortableKey(groupKey: groupKey, serverKeyData: key.keyData);

      list.add(decryptedKey);
    }

    return list;
  }

  Future<void> fetchKeys(String jwt, [int verify = 0]) async {
    var lastItem = _keys[_keys.length - 1];

    bool nextFetch = true;

    final List<GroupKey> keys = [];

    while (nextFetch) {
      final fetchedKeys = await api_group.groupGetGroupKeys(
        baseUrl: baseUrl,
        authToken: appToken,
        jwt: jwt,
        id: groupId,
        lastFetchedTime: lastItem.time,
        lastFetchedKeyId: lastItem.groupKeyId,
        groupAsMember: accessByGroupAsMember,
      );

      final decryptedKeys = await decryptKey(fetchedKeys, verify);

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
    final jwt = await getJwt();

    return api_group.groupDeleteGroup(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      adminRank: rank,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<Group> getChildGroup(String groupId, [int verify = 0]) {
    return getGroup(groupId, baseUrl, appToken, _user, true, accessByGroupAsMember, verify);
  }

  Future<Group> getConnectedGroup(String groupId, [int verify = 0]) {
    return getGroup(groupId, baseUrl, appToken, _user, false, this.groupId, verify);
  }

  Future<List<api_group.GroupChildrenList>> getChildren([api_group.GroupChildrenList? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time ?? "0";
    final lastFetchedGroupId = lastFetchedItem?.groupId ?? "none";

    return api_group.groupGetAllFirstLevelChildren(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      lastFetchedTime: lastFetchedTime,
      lastFetchedGroupId: lastFetchedGroupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<String> prepareCreateChildGroup([bool sign = false]) {
    final lastKey = _getNewestKey()!.publicGroupKey;

    String? signKey;

    if (sign) {
      signKey = _user.getNewestSignKey();
    }

    return api_group.groupPrepareCreateGroup(creatorsPublicKey: lastKey, starter: _user.userId, signKey: signKey);
  }

  Future<String> createChildGroup([bool sign = false]) async {
    final jwt = await getJwt();
    final lastKey = _getNewestKey()!.publicGroupKey;

    String? signKey;

    if (sign) {
      signKey = _user.getNewestSignKey();
    }

    return api_group.groupCreateChildGroup(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      parentPublicKey: lastKey,
      parentId: groupId,
      adminRank: rank,
      groupAsMember: accessByGroupAsMember,
      starter: _user.userId,
      signKey: signKey,
    );
  }

  Future<String> createConnectedGroup([bool sign = false]) async {
    final jwt = await getJwt();
    final lastKey = _getNewestKey()!.publicGroupKey;

    String? signKey;

    if (sign) {
      signKey = _user.getNewestSignKey();
    }

    return api_group.groupCreateConnectedGroup(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      connectedGroupId: groupId,
      adminRank: rank,
      parentPublicKey: lastKey,
      groupAsMember: accessByGroupAsMember,
      starter: _user.userId,
      signKey: signKey,
    );
  }

  Future<void> groupUpdateCheck() async {
    final jwt = await getJwt();

    final update = await api_group.groupGetGroupUpdates(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      groupAsMember: accessByGroupAsMember,
    );

    rank = update.rank;
    lastCheckTime = DateTime.now().millisecondsSinceEpoch;
  }

  Future<List<api_group.GroupUserListItem>> getMember([api_group.GroupUserListItem? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.joinedTime ?? "0";
    final lastFetchedId = lastFetchedItem?.userId ?? "none";

    return api_group.groupGetMember(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      lastFetchedTime: lastFetchedTime,
      lastFetchedId: lastFetchedId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  //____________________________________________________________________________________________________________________
  //key rotation

  Future<String> prepareKeyRotation([bool sign = false]) async {
    final publicKey = await _getPublicKey();

    String? signKey;

    if (sign) {
      signKey = await getSignKey();
    }

    return api_group.groupPrepareKeyRotation(
      preGroupKey: _getNewestKey()!.groupKey,
      publicKey: publicKey,
      signKey: signKey,
      starter: _user.userId,
    );
  }

  Future<GroupKey> keyRotation([bool sign = false]) async {
    final jwt = await getJwt();
    final publicKey = await _getPublicKey();

    String? signKey;

    if (sign) {
      signKey = await getSignKey();
    }

    final keyId = await api_group.groupKeyRotation(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      publicKey: publicKey,
      preGroupKey: _getNewestKey()!.groupKey,
      signKey: signKey,
      starter: _user.userId,
      groupAsMember: accessByGroupAsMember,
    );

    return getGroupKey(keyId, true);
  }

  Future<void> finishKeyRotation([int verify = 0]) async {
    final jwt = await getJwt();

    var keys = await api_group.groupPreDoneKeyRotation(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      groupAsMember: accessByGroupAsMember,
    );

    if (keys.isEmpty) {
      return;
    }

    bool nextRound = false;
    int roundsLeft = 10;

    final publicKey = await _getPublicKey();

    do {
      List<api_user.KeyRotationGetOut> leftKeys = [];

      for (var i = 0; i < keys.length; ++i) {
        var key = keys[i];

        GroupKey preKey;

        try {
          preKey = await getGroupKey(key.preGroupKeyId, false, verify);
        } catch (e) {
          leftKeys.add(key);
          continue;
        }

        //get the right used private key for each key
        final privateKey = await _getPrivateKey(key.encryptedEphKeyKeyId);

        await api_group.groupFinishKeyRotation(
          baseUrl: baseUrl,
          authToken: appToken,
          jwt: jwt,
          id: groupId,
          serverOutput: key.serverOutput,
          preGroupKey: preKey.groupKey,
          publicKey: publicKey,
          privateKey: privateKey,
          groupAsMember: accessByGroupAsMember,
        );

        //now get the new key and safe it
        await getGroupKey(key.newGroupKeyId, true, verify);
      }

      roundsLeft--;

      if (leftKeys.isNotEmpty) {
        keys = [];
        keys.addAll(leftKeys);

        nextRound = true;
      } else {
        nextRound = false;
      }
    } while (nextRound && roundsLeft > 0);

    String userId;
    if (accessByGroupAsMember == null) {
      userId = _user.userId;
    } else {
      userId = accessByGroupAsMember!;
    }

    //after a key rotation -> save the new group data in the store
    final groupKey = "group_data_user_${userId}_id_$groupId";

    final storage = Sentc.getStorage();
    await storage.set(groupKey, jsonEncode(this));
  }

  //____________________________________________________________________________________________________________________
  //admin fn for user management

  String prepareUpdateRank(String userId, int newRank) {
    return api_group.groupPrepareUpdateRank(userId: userId, rank: rank, adminRank: rank);
  }

  Future<void> updateRank(String userId, int newRank) async {
    final jwt = await getJwt();

    await api_group.groupUpdateRank(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      userId: userId,
      rank: newRank,
      adminRank: rank,
      groupAsMember: accessByGroupAsMember,
    );

    String actualUserId;
    if (accessByGroupAsMember == null) {
      actualUserId = _user.userId;
    } else {
      actualUserId = accessByGroupAsMember!;
    }

    //check if the updated user is the actual user -> then update the group store

    if (actualUserId == userId) {
      final groupKey = "group_data_user_${actualUserId}_id_$groupId";

      final storage = Sentc.getStorage();

      rank = newRank;

      await storage.set(groupKey, jsonEncode(this));
    }
  }

  Future<void> kickUser(String userId) async {
    final jwt = await getJwt();

    return api_group.groupKickUser(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      userId: userId,
      adminRank: rank,
      groupAsMember: accessByGroupAsMember,
    );
  }

  //____________________________________________________________________________________________________________________

  Future<void> leave() async {
    final jwt = await getJwt();

    return api_group.leaveGroup(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  //____________________________________________________________________________________________________________________
  //group as member

  Future<List<api_group.ListGroups>> getGroups([api_group.ListGroups? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time.toString() ?? "0";
    final lastFetchedGroupId = lastFetchedItem?.groupId ?? "none";

    return api_group.groupGetGroupsForUser(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      lastFetchedTime: lastFetchedTime,
      lastFetchedGroupId: lastFetchedGroupId,
      groupId: groupId,
    );
  }

  Future<List<api_group.GroupInviteReqList>> getGroupInvites([api_group.GroupInviteReqList? lastItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastItem?.time.toString() ?? "0";
    final lastFetchedGroupId = lastItem?.groupId ?? "none";

    return api_group.groupGetInvitesForUser(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      lastFetchedTime: lastFetchedTime,
      lastFetchedGroupId: lastFetchedGroupId,
      groupId: groupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<void> acceptGroupInvite(String groupIdToAccept) async {
    final jwt = await getJwt();

    return api_group.groupAcceptInvite(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupIdToAccept,
      groupId: groupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<void> rejectGroupInvite(groupIdToReject) async {
    final jwt = await getJwt();

    return api_group.groupRejectInvite(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupIdToReject,
      groupId: groupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  //join req to another group
  Future<void> groupJoinRequest(String groupIdToJoin) async {
    final jwt = await getJwt();

    return api_group.groupJoinReq(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupIdToJoin,
      groupId: groupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<List<api_group.GroupInviteReqList>> sentJoinReq([api_group.GroupInviteReqList? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time.toString() ?? "0";
    final lastFetchedGroupId = lastFetchedItem?.groupId ?? "none";

    return api_group.groupGetSentJoinReq(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      adminRank: rank,
      lastFetchedTime: lastFetchedTime,
      lastFetchedGroupId: lastFetchedGroupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<void> deleteJoinReq(String id) async {
    final jwt = await getJwt();

    return api_group.groupDeleteSentJoinReq(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      adminRank: rank,
      joinReqGroupId: id,
      groupAsMember: accessByGroupAsMember,
    );
  }

  //____________________________________________________________________________________________________________________
  //send invite to user

  Future<void> stopInvites() async {
    final jwt = await getJwt();

    return api_group.groupStopGroupInvites(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      adminRank: rank,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<String> prepareKeysForNewMember(String userId, int? rank, [int page = 0, bool group = false]) async {
    final keyCount = _keys.length;

    String publicKey;

    if (group) {
      final k = await Sentc.getGroupPublicKeyData(userId);
      publicKey = k.key;
    } else {
      final k = await Sentc.getUserPublicKey(userId);
      publicKey = k.publicKey;
    }

    final keyString = prepareKeys(_keys, page).str;

    return api_group.groupPrepareKeysForNewMember(
      userPublicKey: publicKey,
      groupKeys: keyString,
      keyCount: keyCount,
      adminRank: this.rank,
      rank: rank,
    );
  }

  handleInviteSessionKeysForNewMember(String sessionId, String userId, [bool auto = false, bool group = false]) async {
    if (sessionId == "") {
      return;
    }

    String publicKey;

    if (group) {
      final k = await Sentc.getGroupPublicKeyData(userId);
      publicKey = k.key;
    } else {
      final k = await Sentc.getUserPublicKey(userId);
      publicKey = k.publicKey;
    }

    final jwt = await getJwt();

    bool nextPage = true;
    int i = 1;
    final p = <Future>[];

    while (nextPage) {
      final nextKeys = prepareKeys(_keys, i);
      nextPage = nextKeys.end;

      p.add(api_group.groupInviteUserSession(
        baseUrl: baseUrl,
        authToken: appToken,
        jwt: jwt,
        id: groupId,
        autoInvite: auto,
        sessionId: sessionId,
        userPublicKey: publicKey,
        groupKeys: nextKeys.str,
        groupAsMember: accessByGroupAsMember,
      ));

      i++;
    }

    await Future.wait(p);
  }

  Future<void> invite(String userId, [int? rank]) {
    return _inviteUserInternally(userId, rank);
  }

  Future<void> inviteAuto(String userId, [int? rank]) {
    return _inviteUserInternally(userId, rank, true);
  }

  Future<void> inviteGroup(String groupId, [int? rank]) {
    return _inviteUserInternally(groupId, rank, false, true);
  }

  Future<void> inviteGroupAuto(String groupId, [int? rank]) {
    return _inviteUserInternally(groupId, rank, true, true);
  }

  Future<void> reInviteUser(String userId) {
    return _inviteUserInternally(userId, null, false, false, true);
  }

  Future<void> reInviteGroup(String groupId) {
    return _inviteUserInternally(groupId, null, false, true, true);
  }

  Future<void> _inviteUserInternally(
    String userId,
    int? rank, [
    bool auto = false,
    bool group = false,
    bool reInvite = false,
  ]) async {
    String publicKey;

    if (group) {
      final k = await Sentc.getGroupPublicKeyData(userId);
      publicKey = k.key;
    } else {
      final k = await Sentc.getUserPublicKey(userId);
      publicKey = k.publicKey;
    }

    final keyCount = _keys.length;
    final keyString = prepareKeys(_keys, 0).str;

    final jwt = await getJwt();

    final sessionId = await api_group.groupInviteUser(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      userId: userId,
      keyCount: keyCount,
      rank: rank,
      adminRank: this.rank,
      autoInvite: auto,
      groupInvite: group,
      userPublicKey: publicKey,
      groupKeys: keyString,
      groupAsMember: accessByGroupAsMember,
      reInvite: reInvite,
    );

    if (sessionId == "") {
      return;
    }

    bool nextPage = true;
    int i = 1;
    final p = <Future>[];

    while (nextPage) {
      final nextKeys = prepareKeys(_keys, i);
      nextPage = nextKeys.end;

      p.add(api_group.groupInviteUserSession(
        baseUrl: baseUrl,
        authToken: appToken,
        jwt: jwt,
        id: groupId,
        autoInvite: auto,
        sessionId: sessionId,
        userPublicKey: publicKey,
        groupKeys: nextKeys.str,
        groupAsMember: accessByGroupAsMember,
      ));

      i++;
    }

    await Future.wait(p);
  }

  //____________________________________________________________________________________________________________________
  //join req

  Future<List<api_group.GroupJoinReqList>> getJoinRequests([api_group.GroupJoinReqList? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time ?? "0";
    final lastFetchedId = lastFetchedItem?.userId ?? "none";

    return api_group.groupGetJoinReqs(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      adminRank: rank,
      lastFetchedTime: lastFetchedTime,
      lastFetchedId: lastFetchedId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<void> rejectJoinRequest(String userId) async {
    final jwt = await getJwt();

    return api_group.groupRejectJoinReq(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      adminRank: rank,
      rejectedUserId: userId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<void> acceptJoinRequest(String userId, [int userType = 0, int? rank]) async {
    final jwt = await getJwt();

    final keyCount = _keys.length;
    final keyString = prepareKeys(_keys, 0).str;

    String publicKey;

    if (userType == 2) {
      final k = await Sentc.getGroupPublicKeyData(userId);
      publicKey = k.key;
    } else {
      final k = await Sentc.getUserPublicKey(userId);
      publicKey = k.publicKey;
    }

    final sessionId = await api_group.groupAcceptJoinReq(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      userId: userId,
      keyCount: keyCount,
      rank: rank,
      adminRank: this.rank,
      userPublicKey: publicKey,
      groupKeys: keyString,
      groupAsMember: accessByGroupAsMember,
    );

    if (sessionId == "") {
      return;
    }

    bool nextPage = true;
    int i = 1;
    final p = <Future>[];

    while (nextPage) {
      final nextKeys = prepareKeys(_keys, i);
      nextPage = nextKeys.end;

      p.add(api_group.groupJoinUserSession(
        baseUrl: baseUrl,
        authToken: appToken,
        jwt: jwt,
        id: groupId,
        sessionId: sessionId,
        userPublicKey: publicKey,
        groupKeys: nextKeys.str,
        groupAsMember: accessByGroupAsMember,
      ));

      i++;
    }

    await Future.wait(p);
  }

  //____________________________________________________________________________________________________________________
  //file handling

  /// Prepare the register of a file, The server input could be passed to the sentc api from your backend
  ///
  /// encrypted file name, key and master key id are only for the frontend to encrypt more date if necessary
  Future<FilePrepareCreateOutput> prepareRegisterFile(File file) async {
    final keyOut = await generateNonRegisteredKey();
    final key = keyOut.key;

    final uploader = Uploader(baseUrl, appToken, _user, groupId, null, null, accessByGroupAsMember);

    final out = await uploader.prepareFileRegister(file, key.key, keyOut.encryptedKey, key.masterKeyId);

    return FilePrepareCreateOutput(
      encryptedFileName: out.encryptedFileName,
      key: key,
      masterKeyId: key.masterKeyId,
      serverInput: out.serverInput,
    );
  }

  /// Validates the sentc file register output
  /// Returns the file id
  Future<api_file.FileDoneRegister> doneFileRegister(String serverOutput) {
    final uploader = Uploader(baseUrl, appToken, _user, groupId, null, null, accessByGroupAsMember);

    return uploader.doneFileRegister(serverOutput);
  }

  /// Upload a registered file.
  ///
  /// Session id is returned from the sentc api. The rest from @prepareRegisterFile
  ///
  /// upload the chunks signed by the creators sign key
  ///
  /// Show the upload progress of how many chunks are already uploaded with the uploadCallback
  Future<void> uploadFile({
    required File file,
    required SymKey contentKey,
    required String sessionId,
    bool sign = false,
    void Function(double progress)? uploadCallback,
  }) {
    final uploader = Uploader(baseUrl, appToken, _user, groupId, null, uploadCallback, accessByGroupAsMember);

    return uploader.checkFileUpload(file, contentKey.key, sessionId, sign);
  }

  //____________________________________________________________________________________________________________________

  Future<FileCreateOutput> createFileWithPath({
    required String path,
    bool sign = false,
    void Function(double progress)? uploadCallback,
  }) {
    final file = File(path);

    return createFile(file: file, sign: sign, uploadCallback: uploadCallback);
  }

  Future<FileCreateOutput> createFile({
    required File file,
    bool sign = false,
    void Function(double progress)? uploadCallback,
  }) async {
    final keyOut = await generateNonRegisteredKey();
    final key = keyOut.key;

    final uploader = Uploader(baseUrl, appToken, _user, groupId, null, uploadCallback, accessByGroupAsMember);

    final out = await uploader.uploadFile(file, key.key, keyOut.encryptedKey, key.masterKeyId, sign);

    return FileCreateOutput(out.fileId, key.masterKeyId, out.encryptedFileName);
  }

  Future<DownloadResult> _getFileMetaInfo(
    String fileId,
    Downloader downloader, [
    String? verifyKey,
  ]) async {
    final fileMeta = await downloader.downloadFileMetaInformation(fileId);

    final key = await this.getNonRegisteredKey(fileMeta.masterKeyId, fileMeta.encryptedKey);

    if (fileMeta.encryptedFileName != null && fileMeta.encryptedFileName != "") {
      fileMeta.fileName = await key.decryptString(fileMeta.encryptedFileName!, verifyKey);
    }

    return DownloadResult(fileMeta, key);
  }

  /// Get and encrypt file meta information like the real file name
  /// This wont download the file.
  ///
  /// This is usefully if the user wants to show information about the file (e.g. the file name) but not download the file
  /// The meta info is also needed for the download file functions
  Future<DownloadResult> downloadFileMetaInfo(String fileId, [String? verifyKey]) {
    final downloader = Downloader(baseUrl, appToken, _user, groupId, accessByGroupAsMember);

    return _getFileMetaInfo(fileId, downloader, verifyKey);
  }

  /// Download a file but with already downloaded file information and the file key to not fetch the info and the key again.
  ///
  /// This function can be used after the downloadFileMetaInfo function
  /// Keep in mind that you must use a file which doesn't exists yet.
  /// otherwise the decrypted bytes will be attached to the file
  Future<void> downloadFileWithMetaInfo({
    required File file,
    required SymKey key,
    required FileMetaInformation fileMeta,
    String? verifyKey,
    void Function(double progress)? updateProgressCb,
  }) {
    final downloader = Downloader(baseUrl, appToken, _user, groupId, accessByGroupAsMember);

    return downloader.downloadFileParts(file, fileMeta.partList, key.key, updateProgressCb, verifyKey);
  }

  //____________________________________________________________________________________________________________________

  /// Downloads a file.
  ///
  /// This can be used if the user wants a specific file.
  /// Need to obtain a file object
  /// This will not check if the file exists
  Future<DownloadResult> downloadFileWithFile({
    required File file,
    required String fileId,
    String? verifyKey,
    void Function(double progress)? updateProgressCb,
  }) async {
    final downloader = Downloader(baseUrl, appToken, _user, groupId, accessByGroupAsMember);

    final fileMeta = await _getFileMetaInfo(fileId, downloader, verifyKey);

    await downloader.downloadFileParts(file, fileMeta.meta.partList, fileMeta.key.key, updateProgressCb, verifyKey);

    return fileMeta;
  }

  /// Downloads a file
  ///
  /// to the given path. The path must be an directory
  /// This functions uses the real file name.
  /// An available file name will be selected based on the real file name
  Future<DownloadResult> downloadFile({
    required String path,
    required String fileId,
    String? verifyKey,
    void Function(double progress)? updateProgressCb,
  }) async {
    final downloader = Downloader(baseUrl, appToken, _user, groupId, accessByGroupAsMember);

    final fileMeta = await _getFileMetaInfo(fileId, downloader, verifyKey);

    final fileName = fileMeta.meta.fileName ?? "unnamed";
    File file = File("$path${Platform.pathSeparator}$fileName");

    if (await file.exists()) {
      final availableFileName = await findAvailableFileName(file.path);

      file = File(availableFileName);
    }

    await downloader.downloadFileParts(file, fileMeta.meta.partList, fileMeta.key.key, updateProgressCb, verifyKey);

    return fileMeta;
  }

  Future<void> deleteFile(String fileId) async {
    final jwt = await getJwt();

    return api_file.fileDeleteFile(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      fileId: fileId,
      groupId: groupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  //____________________________________________________________________________________________________________________
  //searchable encryption

  Future<List<String>> createSearchRaw(String data, [bool? full, int? limit]) {
    final key = getNewestHmacKey();

    return api_crypto.createSearchableRaw(key: key, data: data, full: full ?? false, limit: limit);
  }

  Future<api_crypto.SearchableCreateOutput> createSearch(String data, [bool? full, int? limit]) {
    final key = getNewestHmacKey();

    return api_crypto.createSearchable(key: key, data: data, full: full ?? false, limit: limit);
  }

  Future<String> search(String data) {
    final key = getNewestHmacKey();

    return api_crypto.search(key: key, data: data);
  }

  //____________________________________________________________________________________________________________________
  //sortable

  Future<int> encryptSortableRawNumber(int number) async {
    final key = getNewestSortableKey();

    final out = await api_crypto.sortableEncryptRawNumber(key: key, data: BigInt.from(number));

    return out.toInt();
  }

  Future<api_crypto.SortableEncryptOutput> encryptSortableNumber(int number) {
    final key = getNewestSortableKey();

    return api_crypto.sortableEncryptNumber(key: key, data: BigInt.from(number));
  }

  Future<int> encryptSortableRawString(String data) async {
    final key = getNewestSortableKey();

    final out = await api_crypto.sortableEncryptRawString(key: key, data: data);

    return out.toInt();
  }

  Future<api_crypto.SortableEncryptOutput> encryptSortableString(String data) {
    final key = getNewestSortableKey();

    return api_crypto.sortableEncryptString(key: key, data: data);
  }
}
