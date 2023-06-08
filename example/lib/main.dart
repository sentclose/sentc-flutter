import 'package:flutter/material.dart';
import 'package:sentc/sentc.dart';

void main() async {
  //init the client to load the native dependency
  await Sentc.init(appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sentc flutter demo",
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: const MyHomepage(),
    );
  }
}

class MyHomepage extends StatefulWidget {
  const MyHomepage({Key? key}) : super(key: key);

  @override
  State<MyHomepage> createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  demo() async {
    //register a user
    await Sentc.register("userIdentifier", "password");

    //log in a user
    final user = await Sentc.login("userIdentifier", "password");

    //create a group
    final groupId = await user.createGroup();

    //load a group. returned a group obj for every user.
    final group = await user.getGroup(groupId);

    //invite another user to the group. Not here in the example because we only got one user so far
    // await group.inviteAuto("other user id");

    //encrypt a string for the group
    final encrypted = await group.encryptString("hello there!");

    //now every user in the group can decrypt the string
    final decrypted = await group.decryptString(encrypted);

    print(decrypted); //hello there!

    //delete a group
    await group.deleteGroup();

    //delete a user
    await user.deleteUser("password");
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
