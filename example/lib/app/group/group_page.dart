import 'package:flutter/material.dart';
import 'package:sentc_example/core/presentation/layouts/page_scaffold.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({Key? key}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "Group page",
      content: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("group page"),
          ],
        ),
      ),
    );
  }
}
