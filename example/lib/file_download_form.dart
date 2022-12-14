import 'package:flutter/material.dart';

class FileIdForm extends StatefulWidget {
  final void Function(String fileId) updateData;

  const FileIdForm({Key? key, required this.updateData}) : super(key: key);

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
        children: [
          TextFormField(
            validator: _validatorString,
            controller: textController,
            decoration: const InputDecoration(
              label: Text("Extern file id to download"),
            ),
          ),
          ElevatedButton(
            onPressed: _btnPressed,
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }
}
