import 'dart:convert';

import 'package:sentc_light/sentc_light.dart';

Future<Group> getGroup(
  String groupId,
  String baseUrl,
  String appToken,
  User user, [
  bool parent = false,
  String? groupAsMember,
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
    final group = Group.fromJson(jsonDecode(groupJson), baseUrl, appToken, user);

    if (group.lastCheckTime + 60000 * 5 < DateTime.now().millisecondsSinceEpoch) {
      //load the group from json data and just look for group updates
      final update = await Sentc.getApi().groupGetGroupUpdates(
        baseUrl: baseUrl,
        authToken: appToken,
        jwt: jwt,
        id: groupId,
        groupAsMember: groupAsMember,
      );

      group.rank = update;
      group.lastCheckTime = DateTime.now().millisecondsSinceEpoch;

      //update the group data in the storage
      await storage.set(groupKey, jsonEncode(group));
    }

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

  final accessByGroupAsMember = out.accessByGroupAsMember;

  if (accessByGroupAsMember != null && accessByGroupAsMember != "" && !rek) {
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

    await getGroup(out.parentGroupId!, baseUrl, appToken, user, false, groupAsMember, true);
  }

  final groupObj = Group._(
    baseUrl,
    appToken,
    user,
    groupId,
    out.parentGroupId,
    out.rank,
    out.createdTime,
    out.joinedTime,
    out.accessByParentGroup,
    accessByGroupAsMember,
    DateTime.now().millisecondsSinceEpoch,
  );

  await storage.set(groupKey, jsonEncode(groupObj));

  return groupObj;
}

class Group {
  final User _user;

  final String baseUrl;
  final String appToken;

  final String groupId;
  final String? parentGroupId;
  int rank;
  int lastCheckTime;
  final String createdTime;
  final String joinedTime;

  final String? accessByParentGroup;
  final String? accessByGroupAsMember;

  Group._(
    this.baseUrl,
    this.appToken,
    this._user,
    this.groupId,
    this.parentGroupId,
    this.rank,
    this.createdTime,
    this.joinedTime,
    this.accessByParentGroup,
    this.accessByGroupAsMember,
    this.lastCheckTime,
  );

  Group.fromJson(
    Map<String, dynamic> json,
    this.baseUrl,
    this.appToken,
    this._user,
  )   : groupId = json["groupId"],
        lastCheckTime = json["lastCheckTime"],
        parentGroupId = json["parentGroupId"],
        createdTime = json["createdTime"],
        joinedTime = json["joinedTime"],
        rank = json["rank"],
        accessByParentGroup = json["accessByParentGroup"],
        accessByGroupAsMember = json["accessByGroupAsMember"];

  Map<String, dynamic> toJson() {
    return {
      "groupId": groupId,
      "parentGroupId": parentGroupId,
      "createdTime": createdTime,
      "joinedTime": joinedTime,
      "rank": rank,
      "accessByParentGroup": accessByParentGroup,
      "accessByGroupAsMember": accessByGroupAsMember,
      "lastCheckTime": lastCheckTime,
    };
  }

  Future<String> getJwt() {
    return _user.getJwt();
  }

  //____________________________________________________________________________________________________________________

  deleteGroup() async {
    final jwt = await getJwt();

    return Sentc.getApi().groupDeleteGroup(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      adminRank: rank,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<Group> getChildGroup(String groupId) {
    return getGroup(groupId, baseUrl, appToken, _user, true, accessByGroupAsMember);
  }

  Future<Group> getConnectedGroup(String groupId) {
    return getGroup(groupId, baseUrl, appToken, _user, false, this.groupId);
  }

  Future<List<GroupChildrenList>> getChildren([GroupChildrenList? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time ?? "0";
    final lastFetchedGroupId = lastFetchedItem?.groupId ?? "none";

    return Sentc.getApi().groupGetAllFirstLevelChildren(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      lastFetchedTime: lastFetchedTime,
      lastFetchedGroupId: lastFetchedGroupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<String> createChildGroup() async {
    final jwt = await getJwt();

    return Sentc.getApi().groupCreateChildGroup(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      parentId: groupId,
      adminRank: rank,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<String> createConnectedGroup() async {
    final jwt = await getJwt();

    return Sentc.getApi().groupCreateConnectedGroup(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      connectedGroupId: groupId,
      adminRank: rank,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<void> groupUpdateCheck() async {
    final jwt = await getJwt();

    final update = await Sentc.getApi().groupGetGroupUpdates(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      groupAsMember: accessByGroupAsMember,
    );

    rank = update;
    lastCheckTime = DateTime.now().millisecondsSinceEpoch;
  }

  Future<List<GroupUserListItem>> getMember([GroupUserListItem? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.joinedTime ?? "0";
    final lastFetchedId = lastFetchedItem?.userId ?? "none";

    return Sentc.getApi().groupGetMember(
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
  //admin fn for user management

  Future<String> prepareUpdateRank(String userId, int newRank) {
    return Sentc.getApi().groupPrepareUpdateRank(userId: userId, rank: rank, adminRank: rank);
  }

  Future<void> updateRank(String userId, int newRank) async {
    final jwt = await getJwt();

    await Sentc.getApi().groupUpdateRank(
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

    return Sentc.getApi().groupKickUser(
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

    return Sentc.getApi().leaveGroup(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  //____________________________________________________________________________________________________________________
  //group as member

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
      groupId: groupId,
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
      groupId: groupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<void> acceptGroupInvite(String groupIdToAccept) async {
    final jwt = await getJwt();

    return Sentc.getApi().groupAcceptInvite(
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

    return Sentc.getApi().groupRejectInvite(
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

    return Sentc.getApi().groupJoinReq(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupIdToJoin,
      groupId: groupId,
      groupAsMember: accessByGroupAsMember,
    );
  }

  Future<List<GroupInviteReqList>> sentJoinReq([GroupInviteReqList? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time.toString() ?? "0";
    final lastFetchedGroupId = lastFetchedItem?.groupId ?? "none";

    return Sentc.getApi().groupGetSentJoinReq(
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

    return Sentc.getApi().groupDeleteSentJoinReq(
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

    return Sentc.getApi().groupStopGroupInvites(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      adminRank: rank,
      groupAsMember: accessByGroupAsMember,
    );
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

  Future<void> _inviteUserInternally(
    String userId,
    int? rank, [
    bool auto = false,
    bool group = false,
  ]) async {
    final jwt = await getJwt();
    final api = Sentc.getApi();

    return api.groupInviteUser(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      userId: userId,
      rank: rank,
      adminRank: this.rank,
      autoInvite: auto,
      groupInvite: group,
      groupAsMember: accessByGroupAsMember,
    );
  }

  //____________________________________________________________________________________________________________________
  //join req

  Future<List<GroupJoinReqList>> getJoinRequests([GroupJoinReqList? lastFetchedItem]) async {
    final jwt = await getJwt();

    final lastFetchedTime = lastFetchedItem?.time ?? "0";
    final lastFetchedId = lastFetchedItem?.userId ?? "none";

    return Sentc.getApi().groupGetJoinReqs(
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

    return Sentc.getApi().groupRejectJoinReq(
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
    final api = Sentc.getApi();

    return api.groupAcceptJoinReq(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      id: groupId,
      userId: userId,
      rank: rank,
      adminRank: this.rank,
      groupAsMember: accessByGroupAsMember,
    );
  }
}
