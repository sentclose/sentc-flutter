import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentc/sentc.dart';

void main() {
  const username0 = "test0";
  const username1 = "test1";

  const pw = "12345";

  late User user0, user1;

  late Group group, groupForUser1;

  setUpAll(() async {
    final init = await Sentc.init(
      appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      baseUrl: dotenv.env["SENTC_TEST_URL"],
    );

    expect(init, null);

    await Sentc.register(username0, pw);
    user0 = await Sentc.login(username0, pw);

    await Sentc.register(username1, pw);
    user1 = await Sentc.login(username1, pw);
  });

  testWidgets("create a group", (widgetTester) async {
    final groupId = await user0.createGroup();
    group = await user0.getGroup(groupId);

    expect(group.groupId, groupId);
  });

  testWidgets("invite the 2nd user in this group", (widgetTester) async {
    await group.inviteAuto(user1.userId);

    groupForUser1 = await user1.getGroup(group.groupId);
  });

  late int a, b, c;

  testWidgets("encrypt a number", (widgetTester) async {
    a = await group.encryptSortableRawNumber(262);
    b = await group.encryptSortableRawNumber(263);
    c = await group.encryptSortableRawNumber(65321);

    expect((a < b), true);
    expect((b < c), true);
  });

  testWidgets("get the same number as result", (widgetTester) async {
    final a1 = await groupForUser1.encryptSortableRawNumber(262);
    final b1 = await groupForUser1.encryptSortableRawNumber(263);
    final c1 = await groupForUser1.encryptSortableRawNumber(65321);

    expect((a1 < b1), true);
    expect((b1 < c1), true);

    expect(a1, a);
    expect(b1, b);
    expect(c1, c);
  });

  final strValues = ["a", "az", "azzz", "b", "ba", "baaa", "o", "oe", "z", "zaaa"];
  final encryptedValues = <int>[];

  testWidgets("encrypt a string", (widgetTester) async {
    for (var i = 0; i < strValues.length; ++i) {
      var v = strValues[i];

      encryptedValues.add(await group.encryptSortableRawString(v));
    }

    //check
    int pastItem = 0;

    for (var i = 0; i < encryptedValues.length; ++i) {
      var item = encryptedValues[i];

      expect(pastItem < item, true);

      pastItem = item;
    }
  });

  testWidgets("encrypt the same values", (widgetTester) async {
    final newValues = <int>[];

    for (var i = 0; i < strValues.length; ++i) {
      var v = strValues[i];

      newValues.add(await groupForUser1.encryptSortableRawString(v));
    }

    //check
    int pastItem = 0;

    for (var i = 0; i < newValues.length; ++i) {
      var item = newValues[i];
      var checkItem = encryptedValues[i];

      expect(pastItem < item, true);

      expect(checkItem, item);

      pastItem = item;
    }
  });

  tearDownAll(() async {
    await group.deleteGroup();
    await user0.deleteUser(pw);
    await user1.deleteUser(pw);
  });
}
