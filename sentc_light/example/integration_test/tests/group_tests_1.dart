import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentc_light/sentc_light.dart';

void main() {
  const username0 = "test0";
  const username1 = "test1";
  const username2 = "test2";
  const username3 = "test3";

  const pw = "12345";

  late User user0, user1, user2, user3;
  late Group sentcGroup, groupForUser1, groupForUser2, childGroup, childGroupForUser2;

  setUpAll(() async {
    await Sentc.init(
      appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      baseUrl: dotenv.env["SENTC_TEST_URL"],
    );

    await Sentc.register(username0, pw);
    user0 = await Sentc.loginForced(username0, pw);

    await Sentc.register(username1, pw);
    user1 = await Sentc.loginForced(username1, pw);

    await Sentc.register(username2, pw);
    user2 = await Sentc.loginForced(username2, pw);

    await Sentc.register(username3, pw);
    user3 = await Sentc.loginForced(username3, pw);
  });

  testWidgets("create a group", (widgetTester) async {
    final groupId = await user0.createGroup();

    sentcGroup = await user0.getGroup(groupId);

    expect(sentcGroup.groupId, groupId);
  });

  testWidgets("get all groups for the user", (widgetTester) async {
    final out = await user0.getGroups();

    expect(out.length, 1);
  });

  testWidgets("not get the group when user is not in the group", (widgetTester) async {
    try {
      await user1.getGroup(sentcGroup.groupId);
    } catch (e) {
      final err = SentcError.fromError(e);

      expect(err.status, "server_310");
    }
  });

  testWidgets("invite the 2nd user", (widgetTester) async {
    await sentcGroup.invite(user1.userId);
  });

  testWidgets("get the invite for the 2nd user", (widgetTester) async {
    final list = await user1.getGroupInvites();

    expect(list.length, 1);
    expect(list[0].groupId, sentcGroup.groupId);

    //2nd page
    final list2 = await user1.getGroupInvites(list[0]);

    expect(list2.length, 0);
  });

  testWidgets("reject the invite", (widgetTester) async {
    await user1.rejectGroupInvite(sentcGroup.groupId);

    final list = await user1.getGroupInvites();
    expect(list.length, 0);
  });

  testWidgets("invite the user again to accept the invite", (widgetTester) async {
    await sentcGroup.invite(user1.userId);
  });

  testWidgets("accept the invite", (widgetTester) async {
    final list = await user1.getGroupInvites();
    expect(list.length, 1);

    await user1.acceptGroupInvites(list[0].groupId);
  });

  testWidgets("fetch the group for the 2nd user", (widgetTester) async {
    final out = await user1.getGroups();

    expect(out.length, 1);

    groupForUser1 = await user1.getGroup(out[0].groupId);

    expect(groupForUser1.groupId, sentcGroup.groupId);
  });

  testWidgets("leave the group", (widgetTester) async {
    await groupForUser1.leave();

    final out = await user1.getGroups();

    expect(out.length, 0);
  });

  testWidgets("auto invite the 2nd user", (widgetTester) async {
    await sentcGroup.inviteAuto(user1.userId);
  });

  testWidgets("fetch the group after auto invite", (widgetTester) async {
    final out = await user1.getGroups();

    expect(out.length, 1);

    groupForUser1 = await user1.getGroup(out[0].groupId);

    expect(groupForUser1.groupId, sentcGroup.groupId);
  });

  group("join req", () {
    testWidgets("send join req to the group", (widgetTester) async {
      await user2.groupJoinRequest(sentcGroup.groupId);
    });

    testWidgets("get the sent join req for the group", (widgetTester) async {
      final list = await sentcGroup.getJoinRequests();

      expect(list.length, 1);
      expect(list[0].userId, user2.userId);

      //pagination
      final list1 = await sentcGroup.getJoinRequests(list[0]);

      expect(list1.length, 0);
    });

    testWidgets("get the sent join req for the user", (widgetTester) async {
      final list = await user2.sentJoinReq();

      expect(list.length, 1);
      expect(list[0].groupId, sentcGroup.groupId);

      //pagination
      final list1 = await user2.sentJoinReq(list[0]);

      expect(list1.length, 0);
    });

    testWidgets("not reject join req without rights", (widgetTester) async {
      try {
        await groupForUser1.rejectJoinRequest(user2.userId);
      } catch (e) {
        final err = SentcError.fromError(e);

        expect(err.status, "client_201");
      }
    });

    testWidgets("reject join req", (widgetTester) async {
      await sentcGroup.rejectJoinRequest(user2.userId);
    });

    testWidgets("send join req again", (widgetTester) async {
      await user2.groupJoinRequest(sentcGroup.groupId);
    });

    testWidgets("not accept the join req without the rights", (widgetTester) async {
      try {
        await groupForUser1.acceptJoinRequest(user2.userId);
      } catch (e) {
        final err = SentcError.fromError(e);

        expect(err.status, "client_201");
      }
    });

    testWidgets("accept the join req", (widgetTester) async {
      final list = await sentcGroup.getJoinRequests();

      expect(list.length, 1);
      expect(list[0].userId, user2.userId);

      await sentcGroup.acceptJoinRequest(list[0].userId);
    });

    testWidgets("get the group data for the 3rd user", (widgetTester) async {
      groupForUser2 = await user2.getGroup(sentcGroup.groupId);
    });
  });

  group("group admin", () {
    testWidgets("not kick a user without the rights", (widgetTester) async {
      try {
        await groupForUser1.kickUser(user2.userId);
      } catch (e) {
        final err = SentcError.fromError(e);

        expect(err.status, "client_201");
      }
    });

    testWidgets("increase the rank for user 1", (widgetTester) async {
      await sentcGroup.updateRank(user1.userId, 1);

      //get the new group data for the user
      await groupForUser1.groupUpdateCheck();

      await sentcGroup.updateRank(user2.userId, 2);

      await groupForUser2.groupUpdateCheck();
    });

    testWidgets("not kick a user with a higher rank", (widgetTester) async {
      try {
        await groupForUser2.kickUser(user1.userId);
      } catch (e) {
        final err = SentcError.fromError(e);

        expect(err.status, "server_316");
      }
    });

    testWidgets("kick a user", (widgetTester) async {
      await groupForUser1.kickUser(user2.userId);
    });

    testWidgets("not get the group data after user was kicked", (widgetTester) async {
      try {
        await user2.getGroup(sentcGroup.groupId);
      } catch (e) {
        final err = SentcError.fromError(e);

        expect(err.status, "server_310");
      }
    });
  });

  group("child group", () {
    testWidgets("create a child group", (widgetTester) async {
      final id = await sentcGroup.createChildGroup();

      //get the child group in the list
      final list = await sentcGroup.getChildren();

      expect(list.length, 1);
      expect(list[0].groupId, id);
      expect(list[0].parent, sentcGroup.groupId);

      final page2 = await sentcGroup.getChildren(list[0]);

      expect(page2.length, 0);

      childGroup = await sentcGroup.getChildGroup(id);
    });

    testWidgets("get the child group as member of the parent group", (widgetTester) async {
      await groupForUser1.getChildGroup(childGroup.groupId);
    });

    testWidgets("invite a user to the child group", (widgetTester) async {
      await childGroup.inviteAuto(user2.userId, 2);

      childGroupForUser2 = await user2.getGroup(childGroup.groupId);
      expect(childGroupForUser2.rank, 2);
    });

    testWidgets("get the child group by direct access", (widgetTester) async {
      //access the child group by user not by parent group -> the parent should be loaded too

      //auto invite the user to the parent but do not fetch the parent!
      await sentcGroup.inviteAuto(user3.userId);

      await user3.getGroup(childGroup.groupId);
    });
  });

  tearDownAll(() async {
    await sentcGroup.deleteGroup();

    await user0.deleteUser(pw);
    await user1.deleteUser(pw);
    await user2.deleteUser(pw);
    await user3.deleteUser(pw);
  });
}
