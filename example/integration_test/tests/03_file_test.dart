import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sentc/sentc.dart';
import 'package:http/http.dart' as http;

void main() {
  const username0 = "test0";
  const username1 = "test1";

  const pw = "12345";

  late User user0, user1;

  late Group group, groupForUser1;

  late String file1, file2;
  late int fileItemLength;

  const fileItemPath = "integration_test/test_data/file_item";
  const file1Path = "integration_test/test_data/file1";
  const file2Path = "integration_test/test_data/file_item(1)"; //same name it is set in the downloader

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

    final file = File(fileItemPath);
    fileItemLength = await file.length();
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

  testWidgets("prepare register a file manually", (widgetTester) async {
    final jwt = await user0.getJwt();

    final file = File(fileItemPath);

    final out = await group.prepareRegisterFile(file);

    final res = await http.post(
      Uri.parse("http://192.168.178.21:3002/api/v1/group/${group.groupId}/file"),
      body: out.serverInput,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwt",
        "x-sentc-app-token": "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi"
      },
    );

    final fr = await group.doneFileRegister(res.body);

    await group.uploadFile(file: file, contentKey: out.key, sessionId: fr.sessionId);

    file1 = fr.fileId;
  });

  testWidgets("download the manually registered file", (widgetTester) async {
    final f = await groupForUser1.downloadFileMetaInfo(file1);

    await groupForUser1.downloadFileWithMetaInfo(
      file: File(file1Path),
      key: f.key,
      fileMeta: f.meta,
    );

    final file = File(file1Path);

    expect(await file.length(), fileItemLength);
  });

  testWidgets("not delete the file as non owner", (widgetTester) async {
    try {
      await groupForUser1.deleteFile(file1);
    } catch (e) {
      final err = SentcError.fromError(e);

      expect(err.status, "server_521");
    }
  });

  testWidgets("delete a file as owner", (widgetTester) async {
    await group.deleteFile(file1);
  });

  testWidgets("not fetch the deleted file", (widgetTester) async {
    try {
      await group.downloadFileWithFile(file: File(file1Path), fileId: file1);
    } catch (e) {
      final err = SentcError.fromError(e);

      expect(err.status, "server_512");
    }
  });

  testWidgets("create a file from the sdk", (widgetTester) async {
    final out = await groupForUser1.createFileWithPath(path: fileItemPath);

    file2 = out.fileId;
  });

  testWidgets("download the created file", (widgetTester) async {
    await group.downloadFile(path: "integration_test/test_data", fileId: file2);

    final file = File(file2Path);

    expect(await file.length(), fileItemLength);
  });

  testWidgets("delete the file as group owner", (widgetTester) async {
    //should work even if the user is not the creator
    await group.deleteFile(file2);
  });

  tearDownAll(() async {
    //delete the local copies for the next tests
    try {
      final file1 = File(file1Path);
      await file1.delete();
    } catch (e) {
      //
    }

    try {
      final file2 = File(file2Path);
      await file2.delete();
    } catch (e) {
      //
    }

    await group.deleteGroup();
    await user0.deleteUser(pw);
    await user1.deleteUser(pw);
  });
}
