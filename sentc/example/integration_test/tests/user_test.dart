import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentc/sentc.dart';

void main() {
  late User user;
  late String userId;

  setUpAll(() async {
    final init = await Sentc.init(
      appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      baseUrl: dotenv.env["SENTC_TEST_URL"],
    );

    expect(init, null);
  });

  testWidgets("check if username exists", (widgetTester) async {
    final check = await Sentc.checkUserIdentifierAvailable("userIdentifier1");

    expect(check, true);
  });

  testWidgets("user register", (widgetTester) async {
    userId = await Sentc.register("userIdentifier1", "password");
  });

  testWidgets("login user", (widgetTester) async {
    final userLogin = await Sentc.login("userIdentifier1", "password");

    if (userLogin is MfaLogin) {
      throw Exception("Wrong user obj, no mfa excepted here.");
    } else if (userLogin is UserLogin) {
      user = userLogin.u;
    }

    expect(user.userId, userId);
  });

  testWidgets("change password", (widgetTester) async {
    await user.changePassword("password", "newPassword");

    await user.logOut();
  });

  testWidgets("not login with the old password", (widgetTester) async {
    try {
      await Sentc.login("userIdentifier1", "password");
    } catch (e) {
      final error = SentcError.fromError(e);

      expect(error.status, "server_112");
    }
  });

  testWidgets("should login with the new password", (widgetTester) async {
    user = await Sentc.loginForced("userIdentifier1", "newPassword");
  });

  testWidgets("reset password", (widgetTester) async {
    await user.resetPassword("password");
    await user.logOut();
  });

  testWidgets("not login with the old new password after reset", (widgetTester) async {
    try {
      await Sentc.login("userIdentifier1", "newPassword");
    } catch (e) {
      final error = SentcError.fromError(e);

      expect(error.status, "server_112");
    }
  });

  testWidgets("login with the new password after reset", (widgetTester) async {
    user = await Sentc.loginForced("userIdentifier1", "password");
  });

  group("device tests", () {
    late User newDevice, newDevice1;
    late String deviceRegisterResult;
    late String deviceIdentifier, devicePw, deviceIdentifier1, devicePw1;

    testWidgets("register device", (widgetTester) async {
      final res = await Sentc.generateRegisterData();
      deviceIdentifier = res.identifier;
      devicePw = res.password;

      deviceRegisterResult = await Sentc.registerDeviceStart(deviceIdentifier, devicePw);
    });

    testWidgets("not login with a not fully registered device", (widgetTester) async {
      try {
        await Sentc.login(deviceIdentifier, devicePw);
      } catch (e) {
        final error = SentcError.fromError(e);

        expect(error.status, "server_100");
      }
    });

    testWidgets("end the device register", (widgetTester) async {
      await user.registerDevice(deviceRegisterResult);
    });

    testWidgets("login the new device", (widgetTester) async {
      newDevice = await Sentc.loginForced(deviceIdentifier, devicePw);
    });

    //key rotation
    testWidgets("start key rotation", (widgetTester) async {
      await user.keyRotation();
    });

    testWidgets("finish the key rotation on the other device", (widgetTester) async {
      final storage = Sentc.getStorage();

      final oldUserJson = await storage.getItem("user_data_$deviceIdentifier");
      final oldNewestKey = jsonDecode(oldUserJson!)["newestKeyId"];

      await newDevice.finishKeyRotation();

      final newUserJson = await storage.getItem("user_data_$deviceIdentifier");
      final newNewestKey = jsonDecode(newUserJson!)["newestKeyId"];

      expect((oldNewestKey == newNewestKey), false);
    });

    testWidgets("register a new device after key rotation (with multiple keys)", (widgetTester) async {
      final res = await Sentc.generateRegisterData();
      deviceIdentifier1 = res.identifier;
      devicePw1 = res.password;

      deviceRegisterResult = await Sentc.registerDeviceStart(deviceIdentifier1, devicePw1);

      //and now end register
      await user.registerDevice(deviceRegisterResult);

      newDevice1 = await Sentc.loginForced(deviceIdentifier1, devicePw1);
    });

    testWidgets("get the same key id for all devices", (widgetTester) async {
      final storage = Sentc.getStorage();

      final newestKeyJson = await storage.getItem("user_data_userIdentifier1");
      final newestKey = jsonDecode(newestKeyJson!)["newestKeyId"];

      final newestKey1Json = await storage.getItem("user_data_$deviceIdentifier");
      final newestKey1 = jsonDecode(newestKey1Json!)["newestKeyId"];

      final newestKey2Json = await storage.getItem("user_data_$deviceIdentifier1");
      final newestKey2 = jsonDecode(newestKey2Json!)["newestKeyId"];

      expect(newestKey, newestKey1);
      expect(newestKey, newestKey2);
    });

    testWidgets("list all devices", (widgetTester) async {
      final list = await user.getDevices();

      expect(list.length, 3);

      final listPagination = await user.getDevices(list[0]);

      //order by time
      expect(listPagination.length, 2);
    });

    testWidgets("delete device", (widgetTester) async {
      await user.deleteDevice("password", newDevice1.deviceId);
    });

    testWidgets("not login with deleted device", (widgetTester) async {
      try {
        await Sentc.login(deviceIdentifier, devicePw);
      } catch (e) {
        final error = SentcError.fromError(e);

        expect(error.status, "server_100");
      }
    });
  });

  late User user2, user3;

  group("safety number", () {
    testWidgets("create a safety number", (widgetTester) async {
      await user.createSafetyNumber();
    });

    testWidgets("create a combined safety number", (widgetTester) async {
      //first register new user
      await Sentc.register("userIdentifier2", "password");
      user2 = await Sentc.loginForced("userIdentifier2", "password");

      final storage = Sentc.getStorage();

      final newestKeyJson = await storage.getItem("user_data_userIdentifier1");
      final newestKey = jsonDecode(newestKeyJson!)["newestKeyId"];

      final newestKey1Json = await storage.getItem("user_data_userIdentifier2");
      final newestKey1 = jsonDecode(newestKey1Json!)["newestKeyId"];

      final number = await user.createSafetyNumber(UserVerifyKeyCompareInfo(user2.userId, newestKey1));

      final number2 = await user2.createSafetyNumber(UserVerifyKeyCompareInfo(user.userId, newestKey));

      expect(number, number2);
    });

    testWidgets("not create the same number with different users", (widgetTester) async {
      await Sentc.register("userIdentifier3", "password");
      user3 = await Sentc.loginForced("userIdentifier3", "password");

      final storage = Sentc.getStorage();

      final newestKeyJson = await storage.getItem("user_data_userIdentifier1");
      final newestKey = jsonDecode(newestKeyJson!)["newestKeyId"];

      final newestKey1Json = await storage.getItem("user_data_userIdentifier2");
      final newestKey1 = jsonDecode(newestKey1Json!)["newestKeyId"];

      final newestKey2Json = await storage.getItem("user_data_userIdentifier3");
      final newestKey2 = jsonDecode(newestKey2Json!)["newestKeyId"];

      final number = await user.createSafetyNumber(UserVerifyKeyCompareInfo(user2.userId, newestKey1));

      final number2 = await user2.createSafetyNumber(UserVerifyKeyCompareInfo(user.userId, newestKey));

      expect(number, number2);

      final number3 = await user3.createSafetyNumber(UserVerifyKeyCompareInfo(user.userId, newestKey));

      expect((number != number3), true);

      final number4 = await user.createSafetyNumber(UserVerifyKeyCompareInfo(user3.userId, newestKey2));

      expect(number3, number4);
    });
  });

  testWidgets("verify public key", (widgetTester) async {
    final userId = user2.userId;

    //first remove the cached public key from the store of user 2 because after login the public key will be set as verified true
    final storage = Sentc.getStorage();
    await storage.delete("user_public_key_id_$userId");

    final publicKey = await Sentc.getUserPublicKey(userId);

    final verify = await Sentc.verifyUserPublicKey(userId, publicKey);

    expect(verify, true);
  });

  const string = "hello there £ Я a a";
  late String encryptedString;

  testWidgets("encrypt string data for another user", (widgetTester) async {
    encryptedString = await user.encryptString(string, user2.userId);

    //should not decrypt it again
    try {
      await user.decryptString(encryptedString);
    } catch (e) {
      final error = SentcError.fromError(e);

      expect(error.status, "server_304");
    }
  });

  testWidgets("decrypt the string for the other user", (widgetTester) async {
    final decrypt = await user2.decryptString(encryptedString);

    expect(decrypt, string);
  });

  testWidgets("encrypt string with sign", (widgetTester) async {
    encryptedString = await user.encryptString(string, user2.userId, true);
  });

  testWidgets("decrypt the signed string without verify", (widgetTester) async {
    final decrypt = await user2.decryptString(encryptedString);

    expect(decrypt, string);
  });

  testWidgets("decrypt the string with verify", (widgetTester) async {
    final decrypt = await user2.decryptString(encryptedString, true, user.userId);

    expect(decrypt, string);
  });

  testWidgets("delete user", (widgetTester) async {
    await user.deleteUser("password");
    await user2.deleteUser("password");
    await user3.deleteUser("password");
  });
}
