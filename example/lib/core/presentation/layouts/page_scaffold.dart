import 'package:flutter/material.dart';
import 'package:sentc_example/core/presentation/layouts/split_view.dart';
import 'package:sentc_example/core/presentation/widgets/app_menu.dart';
import 'package:sentc_example/core/presentation/styles/styles.dart' as style;

class PageScaffold extends StatelessWidget {
  PageScaffold({Key? key, required this.content, required this.title, this.openAsSubPage = false}) : super(key: key);

  final Widget content;
  final String title;
  final bool openAsSubPage;

  static const _breakPoint = 600.0;

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final hasDrawer = screenWidth < _breakPoint;

    return SplitView(
      menu: const AppMenu(),
      scaffoldKey: _key,
      content: Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: style.appMenuColor,
          automaticallyImplyLeading: (hasDrawer && openAsSubPage),
          leading: (hasDrawer && !openAsSubPage)
              ? IconButton(
                  icon: const Icon(Icons.menu),
                  // 4. open the drawer if we have one
                  onPressed: hasDrawer ? () => _key.currentState!.openDrawer() : null,
                )
              : null,
          title: Text(title),
        ),
        body: content,
      ),
    );
  }
}
