import 'package:flutter/material.dart';
import 'package:sentc/sentc.dart';
import 'package:sentc/user.dart';
import 'package:sentc_example/core/presentation/layouts/page_scaffold.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late User user;

  void _prepareTest() async {
    await Sentc.init(
      app_token: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      base_url: "http://192.168.178.21:3002",
    );
  }

  void _doneTest() async {
    await user.deleteUser("password");
  }

  void _createUser() async {
    await Sentc.register("userIdentifier1", "password");
    user = await Sentc.login("userIdentifier1", "password");
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "user page",
      content: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(onPressed: _prepareTest, child: const Text("Start test")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _createUser, child: const Text("Create and login user")),

            //

            const Text("End ______________________________________________"),
            ElevatedButton(onPressed: _doneTest, child: const Text("End test")),
          ],
        ),
      ),
    );
  }
}
