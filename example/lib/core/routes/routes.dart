import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sentc_example/app/file/file_page.dart';
import 'package:sentc_example/app/group/group_page.dart';
import 'package:sentc_example/app/user/user_page.dart';

const String userR = "/";
const String groupR = "group";
const String fileR = "file";

Route<dynamic> generateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case userR:
      return CustomRoute(builder: (context) => const UserPage());
    case groupR:
      return CustomRoute(builder: (context) => const GroupPage());
    case fileR:
      return CustomRoute(builder: (context) => const FilePage());
    default:
      return CustomRoute(builder: (context) => const UserPage());
  }
}

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  final canAnimation = !(Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!canAnimation) return child;

    return super.buildTransitions(context, animation, secondaryAnimation, child);
  }
}
