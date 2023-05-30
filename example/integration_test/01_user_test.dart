import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sentc/sentc.dart';

void main() {
  late User user;
  late String userId;

  setUpAll(() async {
    final init = await Sentc.init(
      appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      baseUrl: "http://192.168.178.21:3002",
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
    user = await Sentc.login("userIdentifier1", "password");

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
    user = await Sentc.login("userIdentifier1", "newPassword");
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
    user = await Sentc.login("userIdentifier1", "password");
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

        expect(error.status, "server_112");
      }
    });

    testWidgets("end the device register", (widgetTester) async {
      await user.registerDevice(deviceRegisterResult);
    });

    testWidgets("login the new device", (widgetTester) async {
      newDevice = await Sentc.login(deviceIdentifier, devicePw);
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

      newDevice1 = await Sentc.login(deviceIdentifier1, devicePw1);
    });
  });

  testWidgets("delete user", (widgetTester) async {
    await user.deleteUser("password");
  });
}
