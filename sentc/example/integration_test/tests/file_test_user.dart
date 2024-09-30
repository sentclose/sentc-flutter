import 'dart:io';

import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentc/sentc.dart';
import 'package:http/http.dart' as http;

const fileItemPathConst = "integration_test/test_data/file_item";

class FileAtt {
  final String testFilePath;
  final String testDirPath;

  const FileAtt(this.testFilePath, this.testDirPath);
}

Future<FileAtt> loadAssetAsFile(String path) async {
  if (!(Platform.isIOS || Platform.isAndroid)) {
    return const FileAtt(fileItemPathConst, "integration_test/test_data");
  }

  final ByteData assetData = await rootBundle.load(path);
  final List<int> bytes = assetData.buffer.asUint8List();

  // Get the directory for storing the file.
  final Directory tempDir = await getTemporaryDirectory();
  final String tempPath = tempDir.path;

  // Generate a unique file name.
  final String fileName = path.split('/').last;

  // Create a file and write the asset data to it.
  final File file = File('$tempPath/$fileName');
  await file.writeAsBytes(bytes, flush: true);

  return FileAtt('$tempPath/$fileName', tempPath);
}

void main() {
  const username0 = "test0";
  const username1 = "test1";

  const pw = "12345";

  late User user0, user1;

  late String file1, file2;
  late int fileItemLength;

  late FileAtt testFilePath;

  late String fileItemPath;
  late String file1Path;
  late String file2Path;

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
  });

  testWidgets("prepare test file", (widgetTester) async {
    testFilePath = await loadAssetAsFile(fileItemPathConst);
    fileItemPath = testFilePath.testFilePath;
    file1Path = "${testFilePath.testDirPath}/file1";
    file2Path = "${testFilePath.testDirPath}/file_item(1)";

    final file = File(fileItemPath);
    fileItemLength = await file.length();
  });

  testWidgets("prepare register a file manually", (widgetTester) async {
    final jwt = await user0.getJwt();

    final file = File(fileItemPath);

    final out = await user0.prepareRegisterFile(file);

    final res = await http.post(
      Uri.parse("${dotenv.env["SENTC_TEST_URL"]}/api/v1/file"),
      body: out.serverInput,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwt",
        "x-sentc-app-token": "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi"
      },
    );

    final fr = await user0.doneFileRegister(res.body);

    await user0.uploadFile(file: file, contentKey: out.key, sessionId: fr.sessionId);

    file1 = fr.fileId;
  });

  testWidgets("download the manually registered file", (widgetTester) async {
    final f = await user0.downloadFileMetaInfo(file1);

    await user0.downloadFileWithMetaInfo(
      file: File(file1Path),
      key: f.key,
      fileMeta: f.meta,
    );

    final file = File(file1Path);

    expect(await file.length(), fileItemLength);
  });

  testWidgets("delete a file as owner", (widgetTester) async {
    await user0.deleteFile(file1);
  });

  testWidgets("not fetch the deleted file", (widgetTester) async {
    try {
      await user0.downloadFileWithFile(file: File(file1Path), fileId: file1);
    } catch (e) {
      final err = SentcError.fromError(e);

      expect(err.status, "server_512");
    }
  });

  testWidgets("create a file from the sdk", (widgetTester) async {
    final out = await user0.createFileWithPath(path: fileItemPath);

    file2 = out.fileId;
  });

  testWidgets("download the created file", (widgetTester) async {
    await user0.downloadFile(path: testFilePath.testDirPath, fileId: file2);

    final file = File(file2Path);

    expect(await file.length(), fileItemLength);
  });

  testWidgets("delete the file as owner", (widgetTester) async {
    await user0.deleteFile(file2);
  });

  //to another user
  testWidgets("create a file from the sdk", (widgetTester) async {
    final out = await user0.createFileWithPath(path: fileItemPath, replyId: user1.userId);

    file2 = out.fileId;
  });

  testWidgets("download the created file", (widgetTester) async {
    await user1.downloadFile(path: testFilePath.testDirPath, fileId: file2);

    final file = File(file2Path);

    expect(await file.length(), fileItemLength);
  });

  testWidgets("delete the file as owner", (widgetTester) async {
    await user0.deleteFile(file2);
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

    await user0.deleteUser(pw);
    await user1.deleteUser(pw);
  });
}
