import 'package:flutter/material.dart';
import 'dart:async';

import 'package:sentc/sentc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String>? register;

  _asyncInit() async {
    await Sentc.init(
      app_token: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi",
      base_url: "http://192.168.178.21:3002",
      //base_url: "http://127.0.0.1:3002",
    );

    var reg = await Sentc.register("userIdentifier", "password");

    print(reg);

    //set here the futures
    setState(() {
      register = Sentc.register("abc", "def");
      print("init");
    });
  }

  @override
  void initState() {
    super.initState();

    _asyncInit();
  }

  @override
  Widget build(BuildContext context) {
    if (register != null) {
      //normal view

      return MaterialApp(
        home: ListViewLayout(
          <Widget>[
            FutureBuilder<List<dynamic>>(
              future: Future.wait([register ?? Future(() => "")]),
              builder: (context, snap) {
                final data = snap.data;

                if (data == null) {
                  return const Text("Loading");
                }

                return Text(
                  '${data[0]}',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
          ],
        ),
      );
    } else {
      //waiting view for init the app

      return const MaterialApp(
        home: ListViewLayout(
          <Widget>[Text("waiting")],
        ),
      );
    }
  }
}

class ListViewLayout extends StatelessWidget {
  final List<Widget> body;

  const ListViewLayout(this.body);

  @override
  Widget build(BuildContext context) {
    return Layout(
      Center(
        child: ListView(
          children: body,
        ),
      ),
    );
  }
}

class Layout extends StatelessWidget {
  final Widget body;

  const Layout(this.body);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: body,
    );
  }
}
