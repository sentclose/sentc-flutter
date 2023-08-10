import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentc_light/sentc_light.dart';
import 'package:totp/totp.dart';

void main() {
  late User user;
  const username0 = "test0";
  const pw = "12345";

  setUpAll(() async {
    final init = await Sentc.init(
      appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      baseUrl: dotenv.env["SENTC_TEST_URL"],
    );

    expect(init, null);

    await Sentc.register(username0, pw);
    user = await Sentc.loginForced(username0, pw);
  });

  late String sec;
  late List<String> recoveryKeys;

  testWidgets("register otp", (widgetTester) async {
    final out = await user.registerRawOtp(pw);

    sec = out.secret;
    recoveryKeys = out.recover;
  });

  testWidgets("not login without otp", (widgetTester) async {
    final u = await Sentc.login(username0, pw);

    expect(u.isRight, true);
  });

  testWidgets("login with otp", (widgetTester) async {
    final u = await Sentc.login(username0, pw);

    if (u.isRight) {
      final totp = Totp.fromBase32(secret: sec, digits: 6);

      final u1 = await Sentc.mfaLogin(totp.now(), u.right);

      expect(u1.mfa, true);
    } else {
      //force test exception
      expect(true, false);
    }
  });

  testWidgets("get all recover keys", (widgetTester) async {
    final totp = Totp.fromBase32(secret: sec, digits: 6);

    final keys = await user.getOtpRecoverKeys(pw, totp.now(), false);

    expect(keys.length, 6);
  });

  testWidgets("login with otp recover keys", (widgetTester) async {
    final u = await Sentc.login(username0, pw);

    if (u.isRight) {
      final u1 = await Sentc.mfaRecoveryLogin(recoveryKeys[0], u.right);

      expect(u1.mfa, true);
    } else {
      //force test exception
      expect(true, false);
    }
  });

  testWidgets("get one recover key less", (widgetTester) async {
    final totp = Totp.fromBase32(secret: sec, digits: 6);

    final keys = await user.getOtpRecoverKeys(pw, totp.now(), false);

    expect(keys.length, 5);
  });

  testWidgets("should reset otp", (widgetTester) async {
    final totp = Totp.fromBase32(secret: sec, digits: 6);

    final out = await user.resetRawOtp(pw, totp.now(), false);

    sec = out.secret;
    recoveryKeys = out.recover;
  });

  testWidgets("get all keys back", (widgetTester) async {
    final totp = Totp.fromBase32(secret: sec, digits: 6);

    final keys = await user.getOtpRecoverKeys(pw, totp.now(), false);

    expect(keys.length, 6);
  });

  testWidgets("disable otp", (widgetTester) async {
    final totp = Totp.fromBase32(secret: sec, digits: 6);

    await user.disableOtp(pw, totp.now(), false);
  });

  testWidgets("login without otp after disabled", (widgetTester) async {
    final u = await Sentc.login(username0, pw);

    expect(u.isLeft, true);
  });

  tearDownAll(() async {
    await user.deleteUser(pw);
  });
}
