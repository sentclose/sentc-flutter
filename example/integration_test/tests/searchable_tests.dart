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

  const str = r"123*+^êéèüöß@€&$ 👍 🚀 😎";
  late List<String> searchStrFull, searchStr;

  testWidgets("create full search str", (widgetTester) async {
    searchStrFull = await group.createSearchRaw(str, true);

    expect(searchStrFull.length, 1);
  });

  testWidgets("create searchable item", (widgetTester) async {
    searchStr = await group.createSearchRaw(str);

    expect(searchStr.length, 39);
  });

  testWidgets("search item", (widgetTester) async {
    final strItem = await groupForUser1.search(str);

    expect(searchStrFull[0], strItem);

    expect(searchStr.contains(strItem), true);
  });

  testWidgets("search item in parts", (widgetTester) async {
    final strItem = await groupForUser1.search("123");

    expect((searchStrFull[0] == strItem), false);

    expect(searchStr.contains(strItem), true);
  });

  tearDownAll(() async {
    await group.deleteGroup();
    await user0.deleteUser(pw);
    await user1.deleteUser(pw);
  });
}
