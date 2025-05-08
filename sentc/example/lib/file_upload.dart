import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentc/sentc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  //init the client to load the native dependency
  await Sentc.init(appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi", baseUrl: dotenv.env["SENTC_TEST_URL"]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sentc file demo",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("File page"),
        ),
        body: const FilePage(),
      ),
    );
  }
}

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  late User user;
  late Group group;

  String fileText = "";
  String dirText = "";

  bool testReady = false;
  double _progressUpload = 0;
  double _progressDownload = 0;

  String fileId = "";

  late FileCreateOutput fileUploadResult;
  late DownloadResult fileDownloadResult;

  void _prepareTest() async {
    await Sentc.register("userIdentifier1", "password");

    user = await Sentc.loginForced("userIdentifier1", "password");

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

    setState(() {
      testReady = false;
    });
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

  void _pickDirectory() async {
    if (Platform.isAndroid) {
      //use the download dir
      final selectedDirectory = (await getExternalStorageDirectory())!.path;

      setState(() {
        dirText = selectedDirectory;
      });

      return;
    }

    if (Platform.isIOS) {
      final selectedDirectory = (await getDownloadsDirectory())!.path;

      setState(() {
        dirText = selectedDirectory;
      });
      return;
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        dirText = selectedDirectory;
      });
    } else {
      // User canceled the picker
    }
  }

  void _handleDownload() async {
    if (!testReady || dirText.isEmpty) {
      return;
    }

    fileDownloadResult = await group.downloadFile(
      path: dirText,
      fileId: fileId,
      updateProgressCb: (progress) {
        setState(() {
          _progressDownload = progress;
        });
      },
    );
  }

  void _handleDownloadExtern(String fileIdExtern) async {
    if (!testReady || dirText.isEmpty) {
      return;
    }

    fileDownloadResult = await group.downloadFile(
      path: dirText,
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        primary: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(testReady ? "ready to upload" : "not started"),

            ElevatedButton(onPressed: _prepareTest, child: const Text("Start test")),
            const SizedBox(height: 10),

            //upload section
            const Text("Upload ______________________________________________"),
            const SizedBox(height: 10),

            //pick a file with the file picker
            ElevatedButton(onPressed: _pickFile, child: const Text("Pick a file")),

            const SizedBox(height: 10),
            Text("chosen file: $fileText"),
            const SizedBox(height: 10),

            //start file upload after picking a file
            ElevatedButton(onPressed: _handleUpload, child: const Text("Upload file")),

            const SizedBox(height: 20),

            //showing the upload progress from the uploader
            Text("upload progress: $_progressUpload"),

            const SizedBox(height: 30),

            //download section
            const Text("Download ______________________________________________"),
            const SizedBox(height: 10),

            //pick a dir to store the file in
            ElevatedButton(onPressed: _pickDirectory, child: const Text("Pick a download directory")),

            const SizedBox(height: 10),
            Text("chosen directory: $dirText"),
            const SizedBox(height: 10),

            //start download the uploaded file. just choose the same id
            ElevatedButton(onPressed: _handleDownload, child: const Text("Download file")),

            const SizedBox(height: 20),

            //show the download progress from the downloader
            Text("download progress: $_progressDownload"),

            const Text("End ______________________________________________"),

            //end the test, deleting all groups and users
            ElevatedButton(onPressed: _doneTest, child: const Text("End test")),
            const SizedBox(height: 10),

            const Text("File id: "),
            SelectableText(fileId),
            const SizedBox(height: 20),

            //external test, download file with id
            const Text(
              "extern file id",
            ),
            const SizedBox(height: 10),
            //input form
            FileIdForm(updateData: _handleDownloadExtern),
          ],
        ),
      ),
    );
  }
}

class FileIdForm extends StatefulWidget {
  final void Function(String fileId) updateData;

  const FileIdForm({super.key, required this.updateData});

  @override
  State<FileIdForm> createState() => _FileIdFormState();
}

class _FileIdFormState extends State<FileIdForm> {
  final _formKey = GlobalKey<FormState>();

  final textController = TextEditingController();

  /// Clean up the form
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  String? _validatorString(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter the file id to download";
    }

    return null;
  }

  _btnPressed() {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    //process input
    final fileId = textController.text;

    //notify the parent that we got a value
    widget.updateData(fileId);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            validator: _validatorString,
            controller: textController,
            decoration: const InputDecoration(
              label: Text("Extern file id to download"),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _btnPressed,
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }
}
