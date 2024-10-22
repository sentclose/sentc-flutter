import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentc/sentc.dart';
import 'package:http/http.dart' as http;

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
      baseUrl: dotenv.env["SENTC_TEST_URL"],
    );

    expect(init, null);

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
    final groupId = await user0.createGroup(true);

    sentcGroup = await user0.getGroup(groupId);

    expect(sentcGroup.groupId, groupId);
  });

  testWidgets("get all groups for the user", (widgetTester) async {
    final out = await user0.getGroups();

    expect(out.length, 1);
  });

  testWidgets("not get the group when user is not in the group", (widgetTester) async {
    try {
      await user1.getGroup(sentcGroup.groupId, null, 2);
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

    groupForUser1 = await user1.getGroup(out[0].groupId, null, 2);

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

  late String encryptedStringByUser0,
      encryptedStringByUser0AfterKr,
      encryptedStringByUser0WithSign,
      encryptedStringByUser0AfterKr1;

  group("basic encryption", () {
    testWidgets("encrypt a string for the group", (widgetTester) async {
      encryptedStringByUser0 = await sentcGroup.encryptString("hello there £ Я a a 👍");
    });

    testWidgets("decrypt string", (widgetTester) async {
      final decrypted = await sentcGroup.decryptString(encryptedStringByUser0);

      expect(decrypted, "hello there £ Я a a 👍");
    });

    testWidgets("test sync encrypt and decrypt", (widgetTester) async {
      final en = await sentcGroup.encryptStringSync("hello there £ Я a a 👍");

      final de = await sentcGroup.decryptStringSync(en);

      expect(de, "hello there £ Я a a 👍");

      final decrypted = await sentcGroup.decryptStringSync(encryptedStringByUser0);

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

      await Future.delayed(const Duration(milliseconds: 200));

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

    testWidgets("decrypt the strings with the new user", (widgetTester) async {
      final decrypt = await groupForUser2.decryptString(encryptedStringByUser0WithSign);
      expect(decrypt, "hello there £ Я a a 👍");

      //now verify
      final decrypt1 = await groupForUser2.decryptString(encryptedStringByUser0WithSign, true, user0.userId);
      expect(decrypt1, "hello there £ Я a a 👍");
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
      final group = await groupForUser1.getChildGroup(childGroup.groupId);

      final storage = Sentc.getStorage();
      final newUserJson = await storage.getItem("group_data_user_${user0.userId}_id_${childGroup.groupId}");
      final newNewestKey = jsonDecode(newUserJson!)["newestKeyId"];

      final newUser1Json = await storage.getItem("group_data_user_${user1.userId}_id_${group.groupId}");
      final newNewestKey1 = jsonDecode(newUser1Json!)["newestKeyId"];

      expect(newNewestKey, newNewestKey1);
    });

    testWidgets("invite user manually with prepare to child group", (widgetTester) async {
      final invite = await childGroup.prepareKeysForNewMember(user2.userId, 2);

      final url = "${dotenv.env["SENTC_TEST_URL"]}/api/v1/group/${childGroup.groupId}/invite_auto/${user2.userId}";

      final jwt = await childGroup.getJwt();

      final res = await http.put(
        Uri.parse(url),
        body: invite,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwt",
          "x-sentc-app-token": "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi"
        },
      );

      final body = json.decode(res.body);
      final sessionRes = body["result"];

      expect(sessionRes.containsKey("session_id"), false);
    });

    testWidgets("fetch the child group for the direct member", (widgetTester) async {
      childGroupForUser2 = await user2.getGroup(childGroup.groupId);
      expect(childGroupForUser2.rank, 2);
    });

    testWidgets("re invite the user", (widgetTester) async {
      await childGroup.reInviteUser(user2.userId);
    });

    testWidgets("get the child group by direct access", (widgetTester) async {
      //access the child group by user not by parent group -> the parent should be loaded too

      //auto invite the user to the parent but do not fetch the parent keys!
      await sentcGroup.inviteAuto(user3.userId);

      childGroupForUser3 = await user3.getGroup(childGroup.groupId);

      final storage = Sentc.getStorage();
      final newUserJson = await storage.getItem("group_data_user_${user0.userId}_id_${childGroup.groupId}");
      final newNewestKey = jsonDecode(newUserJson!)["newestKeyId"];

      final newUser1Json = await storage.getItem("group_data_user_${user3.userId}_id_${childGroupForUser3.groupId}");
      final newNewestKey1 = jsonDecode(newUser1Json!)["newestKeyId"];

      expect(newNewestKey, newNewestKey1);
    });

    testWidgets("test encrypt in child group", (widgetTester) async {
      const string = "hello there £ Я a a";

      final encrypt = await childGroup.encryptString(string);

      //user 1 should decrypt it because he got access by the parent group
      final child1 = await groupForUser1.getChildGroup(childGroup.groupId);
      final decrypt1 = await child1.decryptString(encrypt);

      //user 2 got direct access to the child group
      final decrypt2 = await childGroupForUser2.decryptString(encrypt);

      //user3 fetched the child directly but has access from the parent too
      final decrypt3 = await childGroupForUser3.decryptString(encrypt);

      expect(decrypt1, string);
      expect(decrypt2, string);
      expect(decrypt3, string);
    });
  });

  group("key rotation in child group", () {
    late String newKey;

    testWidgets("start key rotation in child group", (widgetTester) async {
      final storage = Sentc.getStorage();
      final oldUserJson = await storage.getItem("group_data_user_${user0.userId}_id_${childGroup.groupId}");
      final oldNewestKey = jsonDecode(oldUserJson!)["newestKeyId"];

      await childGroup.keyRotation();

      final newUser1Json = await storage.getItem("group_data_user_${user0.userId}_id_${childGroup.groupId}");
      newKey = jsonDecode(newUser1Json!)["newestKeyId"];

      await Future.delayed(const Duration(milliseconds: 200));

      expect((oldNewestKey == newKey), false);
    });

    testWidgets("finish key rotation for direct member", (widgetTester) async {
      final storage = Sentc.getStorage();
      final oldUserJson = await storage.getItem("group_data_user_${user2.userId}_id_${childGroupForUser2.groupId}");
      final oldNewestKey = jsonDecode(oldUserJson!)["newestKeyId"];

      await childGroupForUser2.finishKeyRotation();

      final newUser1Json = await storage.getItem("group_data_user_${user2.userId}_id_${childGroupForUser2.groupId}");
      final newNewKey = jsonDecode(newUser1Json!)["newestKeyId"];

      expect((oldNewestKey == newNewKey), false);
      expect(newNewKey, newKey);
    });

    testWidgets("not get an error when try to finish an already finished rotation", (widgetTester) async {
      //finished because of parent group
      await childGroupForUser3.finishKeyRotation();
    });

    testWidgets("encrypt with the new key for child group", (widgetTester) async {
      const string = "hello there £ Я a a";

      final encrypt = await childGroup.encryptString(string);

      final child1 = await groupForUser1.getChildGroup(childGroup.groupId);
      final decrypt1 = await child1.decryptString(encrypt);

      //user 2 got direct access to the child group
      final decrypt2 = await childGroupForUser2.decryptString(encrypt);

      expect(decrypt1, string);
      expect(decrypt2, string);
    });
  });

  group("key rotation with sign", () {
    testWidgets("start key rotation with signed key", (widgetTester) async {
      final storage = Sentc.getStorage();
      final oldUserJson = await storage.getItem("group_data_user_${user0.userId}_id_${sentcGroup.groupId}");
      final oldNewestKey = jsonDecode(oldUserJson!)["newestKeyId"];

      await sentcGroup.keyRotation(true);

      final newUser1Json = await storage.getItem("group_data_user_${user0.userId}_id_${sentcGroup.groupId}");
      final newNewKey = jsonDecode(newUser1Json!)["newestKeyId"];

      await Future.delayed(const Duration(milliseconds: 200));

      expect((oldNewestKey == newNewKey), false);

      final pKey = await Sentc.getGroupPublicKeyData(sentcGroup.groupId);

      //should be the newest key
      expect(pKey.id, newNewKey);

      //test the key
      encryptedStringByUser0AfterKr1 = await sentcGroup.encryptString("hello there £ Я a a 👍 1");
    });

    testWidgets("finish the key rotation for the 2nd user without verify", (widgetTester) async {
      final storage = Sentc.getStorage();
      final oldUserJson = await storage.getItem("group_data_user_${user1.userId}_id_${groupForUser1.groupId}");
      final oldNewestKey = jsonDecode(oldUserJson!)["newestKeyId"];

      await groupForUser1.finishKeyRotation();

      final newUser1Json = await storage.getItem("group_data_user_${user1.userId}_id_${groupForUser1.groupId}");
      final newNewKey = jsonDecode(newUser1Json!)["newestKeyId"];

      expect((oldNewestKey == newNewKey), false);

      //test with old key
      final decrypt = await groupForUser1.decryptString(encryptedStringByUser0);

      expect(decrypt, "hello there £ Я a a 👍");

      final decrypt1 = await groupForUser1.decryptString(encryptedStringByUser0AfterKr1);

      expect(decrypt1, "hello there £ Я a a 👍 1");
    });

    testWidgets("start key rotation again with signed key", (widgetTester) async {
      final storage = Sentc.getStorage();
      final oldUserJson = await storage.getItem("group_data_user_${user0.userId}_id_${sentcGroup.groupId}");
      final oldNewestKey = jsonDecode(oldUserJson!)["newestKeyId"];

      await sentcGroup.keyRotation(true);

      final newUser1Json = await storage.getItem("group_data_user_${user0.userId}_id_${sentcGroup.groupId}");
      final newNewKey = jsonDecode(newUser1Json!)["newestKeyId"];

      await Future.delayed(const Duration(milliseconds: 200));

      expect((oldNewestKey == newNewKey), false);

      final pKey = await Sentc.getGroupPublicKeyData(sentcGroup.groupId);

      //should be the newest key
      expect(pKey.id, newNewKey);

      //test the key
      encryptedStringByUser0AfterKr1 = await sentcGroup.encryptString("hello there £ Я a a 👍 1");
    });

    testWidgets("finish the key rotation for the 2nd user with verify", (widgetTester) async {
      final storage = Sentc.getStorage();
      final oldUserJson = await storage.getItem("group_data_user_${user1.userId}_id_${groupForUser1.groupId}");
      final oldNewestKey = jsonDecode(oldUserJson!)["newestKeyId"];

      await groupForUser1.finishKeyRotation(2);

      final newUser1Json = await storage.getItem("group_data_user_${user1.userId}_id_${groupForUser1.groupId}");
      final newNewKey = jsonDecode(newUser1Json!)["newestKeyId"];

      expect((oldNewestKey == newNewKey), false);

      final decrypt = await groupForUser1.decryptString(encryptedStringByUser0);

      expect(decrypt, "hello there £ Я a a 👍");

      final decrypt1 = await groupForUser1.decryptString(encryptedStringByUser0AfterKr1);

      expect(decrypt1, "hello there £ Я a a 👍 1");
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
