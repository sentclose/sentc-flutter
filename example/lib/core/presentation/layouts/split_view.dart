import 'package:flutter/material.dart';

class SplitView extends StatelessWidget {
  const SplitView({
    Key? key,
    required this.scaffoldKey,
    required this.menu,
    required this.content,
  }) : super(key: key);

  final Widget content;
  final Widget menu;
  static const _breakPoint = 600.0;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= _breakPoint) {
      //wide screen
      return Row(
        children: [
          SizedBox(
            width: 250,
            child: menu,
          ),
          Container(
            width: 0.5,
            color: Colors.white,
          ),
          Expanded(child: content)
        ],
      );
    }

    return Scaffold(
      key: scaffoldKey,
      body: content,
      drawer: SizedBox(
        width: 300,
        child: Drawer(
          child: menu,
        ),
      ),
    );
  }
}
