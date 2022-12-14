import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sentc/file/downloader.dart';
import 'package:sentc/file/uploader.dart';
import 'package:sentc/group.dart';
import 'package:sentc/sentc.dart';
import 'package:sentc/user.dart';
import 'package:sentc_example/file_download_form.dart';

class FilePickerTest extends StatefulWidget {
  const FilePickerTest({Key? key}) : super(key: key);

  @override
  State<FilePickerTest> createState() => _FilePickerTestState();
}

class _FilePickerTestState extends State<FilePickerTest> {
  late User user;
  late Group group;

  String fileText = "";
  bool testReady = false;
  double _progressUpload = 0;
  double _progressDownload = 0;

  String fileId = "";

  late FileCreateOutput fileUploadResult;
  late DownloadResult fileDownloadResult;

  void _prepareTest() async {
    await Sentc.init(
      app_token: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      base_url: "http://192.168.178.21:3002",
      //base_url: "http://127.0.0.1:3002",
    );

    await Sentc.register("userIdentifier1", "password");

    user = await Sentc.login("userIdentifier1", "password");

    final groupId = await user.createGroup();
    group = await user.getGroup(groupId);

    setState(() {
      testReady = true;
    });
  }

  void _doneTest() async {
    if (!testReady) {
      return;
    }

    if (fileId != "") {
      await group.deleteFile(fileId);
    }

    await group.deleteGroup();
    await user.deleteUser("password");
  }

  void _pickFile() async {
    if (!testReady) {
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        fileText = result.files.single.path!;
      });
    }
  }

  void _handleUpload() async {
    if (!testReady) {
      return;
    }

    fileUploadResult = await group.createFileWithPath(
      path: fileText,
      uploadCallback: (progress) {
        setState(() {
          _progressUpload = progress;
        });
      },
    );

    fileId = fileUploadResult.fileId;
  }

  void _handleDownload() async {
    if (!testReady) {
      return;
    }

    fileDownloadResult = await group.downloadFile(
      path: "C:/Users/joern/Desktop",
      fileId: fileId,
      updateProgressCb: (progress) {
        setState(() {
          _progressDownload = progress;
        });
      },
    );
  }

  void _handleDownloadExtern(String fileIdExtern) async {
    if (!testReady) {
      return;
    }

    fileDownloadResult = await group.downloadFile(
      path: "C:/Users/joern/Desktop",
      fileId: fileIdExtern,
      updateProgressCb: (progress) {
        setState(() {
          _progressDownload = progress;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("File test"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ElevatedButton(onPressed: _prepareTest, child: const Text("Start test")),
            const SizedBox(height: 10),
            const Text("Upload ______________________________________________"),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _pickFile, child: const Text("Pick a file")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _handleUpload, child: const Text("Upload file")),
            const SizedBox(height: 20),
            Text("upload progress: $_progressUpload"),
            const SizedBox(height: 30),
            const Text("Download ______________________________________________"),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _handleDownload, child: const Text("Download file")),
            const SizedBox(height: 20),
            Text("download progress: $_progressDownload"),
            const Text("End ______________________________________________"),
            ElevatedButton(onPressed: _doneTest, child: const Text("End test")),
            const SizedBox(height: 10),
            const Text("File id: "),
            SelectableText(fileId),
            const SizedBox(height: 20),
            //extern file
            const Text("extern file id"),
            const SizedBox(height: 10),
            //input form
            FileIdForm(updateData: _handleDownloadExtern),
          ],
        ),
      ),
    ));
  }
}
