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
    await Sentc.init(app_token: "");

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
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: ListView(
              children: <Widget>[
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
          ),
        ),
      );
    } else {
      //waiting view for init the app

      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: ListView(
              children: const <Widget>[Text("waiting")],
            ),
          ),
        ),
      );
    }
  }
}
