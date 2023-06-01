import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sentc/sentc.dart';

void main() {
  const username0 = "test0";
  const username1 = "test1";
  const username2 = "test2";
  const username3 = "test3";

  const pw = "12345";

  late User user0, user1, user2, user3;

  late Group sentcGroup, groupForUser1, groupForUser2, childGroup, childGroupForUser2, childGroupForUser3;

  setUpAll(() async {
    final init = await Sentc.init(
      appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      baseUrl: "http://192.168.178.21:3002",
    );

    expect(init, null);

    await Sentc.register(username0, pw);
    user0 = await Sentc.login(username0, pw);

    await Sentc.register(username1, pw);
    user1 = await Sentc.login(username1, pw);

    await Sentc.register(username2, pw);
    user2 = await Sentc.login(username2, pw);

    await Sentc.register(username3, pw);
    user3 = await Sentc.login(username3, pw);
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

  late String encryptedStringByUser0, encryptedStringByUser0AfterKr, encryptedStringByUser0WithSign;

  group("basic encryption", () {
    testWidgets("encrypt a string for the group", (widgetTester) async {
      encryptedStringByUser0 = await sentcGroup.encryptString("hello there £ Я a a 👍");
    });

    testWidgets("decrypt string", (widgetTester) async {
      final decrypted = await sentcGroup.decryptString(encryptedStringByUser0);

      expect(decrypted, "hello there £ Я a a 👍");
    });
  });

  group("key rotation", () {
    testWidgets("start key rotation", (widgetTester) async {
      final storage = Sentc.getStorage();

      final oldUserJson = await storage.getItem("group_data_user_${user0.userId}_id_${sentcGroup.groupId}");
      final oldNewestKey = jsonDecode(oldUserJson!)["newestKeyId"];

      await sentcGroup.keyRotation();

      final newUserJson = await storage.getItem("group_data_user_${user0.userId}_id_${sentcGroup.groupId}");
      final newNewestKey = jsonDecode(newUserJson!)["newestKeyId"];

      expect((oldNewestKey == newNewestKey), false);
    });

    testWidgets("get the group public key", (widgetTester) async {
      final key = await Sentc.getGroupPublicKeyData(sentcGroup.groupId);

      //should be the newest key
      final storage = Sentc.getStorage();
      final newUserJson = await storage.getItem("group_data_user_${user0.userId}_id_${sentcGroup.groupId}");
      final newNewestKey = jsonDecode(newUserJson!)["newestKeyId"];

      expect(key.id, newNewestKey);
    });

    testWidgets("test encrypt after key rotation", (widgetTester) async {
      encryptedStringByUser0AfterKr = await sentcGroup.encryptString("hello there £ Я a a 👍 1");
    });

    testWidgets("not encrypt the string before finish key rotation", (widgetTester) async {
      try {
        await groupForUser1.decryptString(encryptedStringByUser0AfterKr);
      } catch (e) {
        final err = SentcError.fromError(e);

        expect(err.status, "server_304");
      }
    });

    testWidgets("finish the key rotation for the 2nd user", (widgetTester) async {
      final storage = Sentc.getStorage();

      final oldUserJson = await storage.getItem("group_data_user_${user1.userId}_id_${groupForUser1.groupId}");
      final oldNewestKey = jsonDecode(oldUserJson!)["newestKeyId"];

      await groupForUser1.finishKeyRotation();

      final newUserJson = await storage.getItem("group_data_user_${user1.userId}_id_${groupForUser1.groupId}");
      final newNewestKey = jsonDecode(newUserJson!)["newestKeyId"];

      expect((oldNewestKey == newNewestKey), false);
    });
  });

  testWidgets("encrypt both strings after kr", (widgetTester) async {
    final decrypted = await groupForUser1.decryptString(encryptedStringByUser0);

    expect(decrypted, "hello there £ Я a a 👍");

    final decrypted1 = await groupForUser1.decryptString(encryptedStringByUser0AfterKr);

    expect(decrypted1, "hello there £ Я a a 👍 1");
  });

  group("encrypt with sign", () {
    testWidgets("encrypt a string with signing", (widgetTester) async {
      encryptedStringByUser0WithSign = await sentcGroup.encryptString("hello there £ Я a a 👍", true);

      //should decrypt without verify
      final decrypt = await sentcGroup.decryptString(encryptedStringByUser0WithSign);
      expect(decrypt, "hello there £ Я a a 👍");

      //now decrypt with verify
      final decrypt1 = await sentcGroup.decryptString(encryptedStringByUser0WithSign, true, user0.userId);

      expect(decrypt1, "hello there £ Я a a 👍");
    });

    testWidgets("decrypt the string with verify for other user", (widgetTester) async {
      final decrypt = await groupForUser1.decryptString(encryptedStringByUser0WithSign);
      expect(decrypt, "hello there £ Я a a 👍");

      //now decrypt
      final decrypt1 = await groupForUser1.decryptString(encryptedStringByUser0WithSign, true, user0.userId);
      expect(decrypt1, "hello there £ Я a a 👍");
    });
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
  });

  tearDownAll(() async {
    await sentcGroup.deleteGroup();

    await user0.deleteUser(pw);
    await user1.deleteUser(pw);
    await user2.deleteUser(pw);
    await user3.deleteUser(pw);
  });
}
