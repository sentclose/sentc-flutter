import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentc/sentc.dart';

void main() {
  const username0 = "test0";
  const username1 = "test1";
  const username2 = "test2";

  const pw = "12345";

  late User user0, user1, user2;
  late Group sentcGroup, group1, group2, connectedGroup, childGroupConnectedGroup;

  setUpAll(() async {
    final init = await Sentc.init(
      appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      baseUrl: dotenv.env["SENTC_TEST_URL"],
    );

    expect(init, null);

    await Sentc.register(username0, pw);
    user0 = await Sentc.loginForced(username0, pw);

    await Sentc.register(username1, pw);
    user1 = await Sentc.loginForced(username1, pw);

    await Sentc.register(username2, pw);
    user2 = await Sentc.loginForced(username2, pw);

    final groupId = await user0.createGroup();
    sentcGroup = await user0.getGroup(groupId);

    final groupId1 = await user1.createGroup();
    group1 = await user1.getGroup(groupId1);

    final groupId2 = await user2.createGroup();
    group2 = await user2.getGroup(groupId2);
  });

  testWidgets("create a connected group", (widgetTester) async {
    final id = await sentcGroup.createConnectedGroup();

    connectedGroup = await sentcGroup.getConnectedGroup(id);

    expect(connectedGroup.groupId, id);
    expect(connectedGroup.accessByGroupAsMember, sentcGroup.groupId);
  });

  testWidgets("do a key rotation in the connected group", (widgetTester) async {
    final storage = Sentc.getStorage();
    final oldUserJson = await storage.getItem("group_data_user_${sentcGroup.groupId}_id_${connectedGroup.groupId}");
    final oldNewestKey = jsonDecode(oldUserJson!)["newestKeyId"];

    await connectedGroup.keyRotation();

    final newUser1Json = await storage.getItem("group_data_user_${sentcGroup.groupId}_id_${connectedGroup.groupId}");
    final newNewKey = jsonDecode(newUser1Json!)["newestKeyId"];

    expect((oldNewestKey == newNewKey), false);
  });

  testWidgets("not access the connected group directly when user don't got direct access", (widgetTester) async {
    try {
      await user0.getGroup(connectedGroup.groupId);
    } catch (e) {
      final err = SentcError.fromError(e);

      expect(err.status, "server_310");
    }
  });

  testWidgets("access the connected group over the user class", (widgetTester) async {
    final groupC = await user0.getGroup(connectedGroup.groupId, sentcGroup.groupId);

    expect(groupC.accessByGroupAsMember, connectedGroup.accessByGroupAsMember);
  });

  testWidgets("not get the group as member when suer got no access to the connected group", (widgetTester) async {
    try {
      await user1.getGroup(connectedGroup.groupId, sentcGroup.groupId);
    } catch (e) {
      final err = SentcError.fromError(e);

      expect(err.status, "server_310");
    }
  });

  testWidgets("create a child group from the connected group", (widgetTester) async {
    final id = await connectedGroup.createChildGroup();

    childGroupConnectedGroup = await connectedGroup.getChildGroup(id);

    expect(childGroupConnectedGroup.groupId, id);
    expect(childGroupConnectedGroup.accessByGroupAsMember, sentcGroup.groupId);
  });

  testWidgets("invite a user to the other group to check access to connected group", (widgetTester) async {
    await sentcGroup.inviteAuto(user1.userId);

    //delete the old caches to check access without caches
    final storage = Sentc.getStorage();
    final key = "group_data_user_${sentcGroup.groupId}_id_${childGroupConnectedGroup.groupId}";
    final key1 = "group_data_user_${sentcGroup.groupId}_id_${connectedGroup.groupId}";

    await storage.delete(key);
    await storage.delete(key1);
  });

  testWidgets(
    "access the child group of the connected group without loading the other group before",
    (widgetTester) async {
      final groupCC = await user1.getGroup(childGroupConnectedGroup.groupId, sentcGroup.groupId);

      expect(groupCC.accessByGroupAsMember, sentcGroup.groupId);
    },
  );

  testWidgets("invite a group as member", (widgetTester) async {
    await connectedGroup.inviteGroupAuto(group2.groupId);
  });

  testWidgets("re invite a group as member", (widgetTester) async {
    await connectedGroup.reInviteGroup(group2.groupId);
  });

  testWidgets("access the group after invite", (widgetTester) async {
    final groupC = await group2.getConnectedGroup(connectedGroup.groupId);

    expect(groupC.accessByGroupAsMember, group2.groupId);
  });

  testWidgets("send join req from group 2 to the new group", (widgetTester) async {
    await group1.groupJoinRequest(connectedGroup.groupId);

    final joins = await group1.sentJoinReq();

    expect(joins.length, 1);
    expect(joins[0].groupId, connectedGroup.groupId);
  });

  testWidgets("get the join req in the list", (widgetTester) async {
    final joins = await connectedGroup.getJoinRequests();

    expect(joins.length, 1);
    expect(joins[0].userId, group1.groupId);
    expect(joins[0].userType, 2);
  });

  testWidgets("reject the group join req", (widgetTester) async {
    await connectedGroup.rejectJoinRequest(group1.groupId);
  });

  testWidgets("send join again to accept it", (widgetTester) async {
    await group1.groupJoinRequest(connectedGroup.groupId);
  });

  testWidgets("accept join req", (widgetTester) async {
    await connectedGroup.acceptJoinRequest(group1.groupId, 2);
  });

  testWidgets("access the group after accepting group join req", (widgetTester) async {
    final groupC = await group1.getConnectedGroup(connectedGroup.groupId);

    expect(groupC.accessByGroupAsMember, group1.groupId);
  });

  testWidgets("get all connected groups where the group is member", (widgetTester) async {
    final list = await group1.getGroups();

    expect(list.length, 1);

    final pageTwo = await group1.getGroups(list[0]);

    expect(pageTwo.length, 0);
  });

  tearDownAll(() async {
    await connectedGroup.deleteGroup();

    await sentcGroup.deleteGroup();
    await group1.deleteGroup();
    await group2.deleteGroup();

    await user0.deleteUser(pw);
    await user1.deleteUser(pw);
    await user2.deleteUser(pw);
  });
}
