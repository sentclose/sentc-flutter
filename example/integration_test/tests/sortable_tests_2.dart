import 'dart:convert';

import 'package:sentc/sentc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    final init = await Sentc.init(
      appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      baseUrl: dotenv.env["SENTC_TEST_URL"],
    );

    expect(init, null);
  });

  testWidgets("generate the same numbers with same key", (widgetTester) async {
    final group = Group.fromJson(
      {
        "groupId": "abc",
        "lastCheckTime": 0,
        "keyUpdate": false,
        "parentGroupId": "abc",
        "createdTime": "0",
        "joinedTime": "0",
        "rank": 1,
        "keyMap": "{\"2a568705-057b-49d1-928f-17a7c34ae3a0\":0}",
        "newestKeyId": "abc",
        "accessByParentGroup": null,
        "accessByGroupAsMember": null,
        "keys": "[]",
        "hmacKeys": "[]",
        "sortableKeys":
            "[\"{\\\"Ope16\\\":{\\\"key\\\":\\\"5kGPKgLQKmuZeOWQyJ7vOg==\\\",\\\"key_id\\\":\\\"1876b629-5795-471f-9704-0cac52eaf9a1\\\"}}\"]"
      },
      "baseUrl",
      "appToken",
      User.fromJson(
        {
          "jwt": "abc",
          "refreshToken": "abc",
          "userId": "abc",
          "deviceId": "abc",
          "privateDeviceKey": "abc",
          "publicDeviceKey": "abc",
          "signDeviceKey": "abc",
          "verifyDeviceKey": "abc",
          "exportedPublicDeviceKey": "abc",
          "exportedVerifyDeviceKey": "abc",
          "userIdentifier": "abc",
          "keyMap": "{\"2a568705-057b-49d1-928f-17a7c34ae3a0\":0}",
          "newestKeyId": "abc",
          "userKeys": "[]",
          "hmacKeys": "[]",
        },
        "baseUrl",
        "appToken",
      ),
      false,
    );

    final a = await group.encryptSortableRawNumber(262);
    final b = await group.encryptSortableRawNumber(263);
    final c = await group.encryptSortableRawNumber(65321);

    print("a: $a, b: $b, c: $c");

    expect((a < b), true);
    expect((b < c), true);

    expect(a, 17455249);
    expect(b, 17488544);
    expect(c, 4280794268);
  });
}
