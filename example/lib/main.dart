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
  final _sentcPlugin = Sentc(app_token: "");

  late Future<void> register;

  @override
  void initState() {
    super.initState();
    register = _sentcPlugin.register("abc", "def");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              FutureBuilder<List<dynamic>>(
                  future: Future.wait([register]),
                  builder: (context, snap) {
                    final data = snap.data;

                    if (data == null) {
                      return const Text("Loading");
                    }

                    return Text(
                      '${data[0]}',
                      style: Theme.of(context).textTheme.headline4,
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
