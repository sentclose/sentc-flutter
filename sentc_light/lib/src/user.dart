import 'dart:convert';

import 'package:sentc_light/sentc_light.dart';
import 'package:sentc_light/src/group.dart' as group;

Future<User> getUser(String deviceIdentifier, UserDataExport data, bool mfa) async {
  final refreshToken = (Sentc.refreshEndpoint != RefreshOption.api) ? "" : data.refreshToken;

  final user = User._(
    Sentc.baseUrl,
    Sentc.appToken,
    deviceIdentifier,
    data.jwt,
    refreshToken,
    data.userId,
    data.deviceId,
    mfa,
    data.deviceKeys.privateKey,
    data.deviceKeys.publicKey,
    data.deviceKeys.signKey,
    data.deviceKeys.verifyKey,
    data.deviceKeys.exportedPublicKey,
    data.deviceKeys.exportedVerifyKey,
    [],
  );

  final storage = Sentc.getStorage();

  Future.wait([
    storage.set("user_data_$deviceIdentifier", jsonEncode(user)),
    storage.set("actual_user", deviceIdentifier),
  ]);

  return user;
}

class User {
  final String baseUrl;
  final String appToken;
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

  late List<GroupInviteReqList> groupInvites;

  User._(
    this.baseUrl,
    this.appToken,
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
    this.groupInvites,
  );

  User.fromJson(Map<String, dynamic> json, this.baseUrl, this.appToken)
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
        _userIdentifier = json["userIdentifier"];

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
    };
  }

  bool enabledMfa() {
    return mfa;
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

  Future<void> registerDevice(String serverOutput) async {
    final jwt = await getJwt();

    return Sentc.getApi().registerDevice(
      baseUrl: baseUrl,
      authToken: appToken,
      jwt: jwt,
      serverOutput: serverOutput,
    );
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

  Future<String> createGroup() async {
    final jwt = await getJwt();

    return Sentc.getApi().groupCreateGroup(baseUrl: baseUrl, authToken: appToken, jwt: jwt);
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

    return Sentc.getApi().groupAcceptInvite(baseUrl: baseUrl, authToken: appToken, jwt: jwt, id: groupIdToAccept);
  }

  Future<void> rejectGroupInvite(String groupIdToReject) async {
    final jwt = await getJwt();

    return Sentc.getApi().groupRejectInvite(baseUrl: baseUrl, authToken: appToken, jwt: jwt, id: groupIdToReject);
  }

  Future<void> groupJoinRequest(String groupId) async {
    final jwt = await getJwt();

    return Sentc.getApi().groupJoinReq(baseUrl: baseUrl, authToken: appToken, jwt: jwt, id: groupId, groupId: "");
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
}
