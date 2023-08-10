import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentc_light/sentc_light.dart';

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
    user = await Sentc.loginForced("userIdentifier1", "password");

    expect(user.userId, userId);
  });

  testWidgets("change password", (widgetTester) async {
    await user.changePassword("password", "newPassword");

    await user.logOut();
  });

  testWidgets("not login with the old password", (widgetTester) async {
    try {
      await Sentc.loginForced("userIdentifier1", "password");
    } catch (e) {
      final error = SentcError.fromError(e);

      expect(error.status, "server_112");
    }
  });

  testWidgets("should login with the new password", (widgetTester) async {
    user = await Sentc.loginForced("userIdentifier1", "newPassword");
  });

  testWidgets("change password back", (widgetTester) async {
    await user.changePassword("newPassword", "password");

    await user.logOut();

    user = await Sentc.loginForced("userIdentifier1", "password");
  });

  group("device tests", () {
    late User newDevice1;
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
      await Sentc.loginForced(deviceIdentifier, devicePw);
    });

    testWidgets("register a new device", (widgetTester) async {
      final res = await Sentc.generateRegisterData();
      deviceIdentifier1 = res.identifier;
      devicePw1 = res.password;

      deviceRegisterResult = await Sentc.registerDeviceStart(deviceIdentifier1, devicePw1);

      //and now end register
      await user.registerDevice(deviceRegisterResult);

      newDevice1 = await Sentc.loginForced(deviceIdentifier1, devicePw1);
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

  testWidgets("delete user", (widgetTester) async {
    await user.deleteUser("password");
  });
}
