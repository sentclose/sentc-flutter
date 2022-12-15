import 'package:flutter/material.dart';
import 'package:sentc_example/core/routes/routes.dart' as routes;
import 'package:sentc_example/core/presentation/styles/styles.dart' as style;

const SizedBox spaceM = SizedBox(height: 2);
const SizedBox spaceL = SizedBox(height: 10);

class AppMenu extends StatelessWidget {
  const AppMenu({Key? key}) : super(key: key);

  final padding = const EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: style.appMenuColor,
      child: ListView(
        children: [
          buildHeader(title: "Sentc", subtitle: "encryption as a service. Dart sdk"),
          Container(
            padding: padding,
            child: Column(
              children: [
                spaceM,
                const Divider(color: Colors.white70),
                spaceM,
                buildMenuItem(text: "User", icon: Icons.account_circle, route: routes.userR, context: context),
                spaceM,
                buildMenuItem(text: "Group", icon: Icons.group, route: routes.groupR, context: context),
                spaceL,
                const Divider(color: Colors.white70),
                spaceL,
                buildMenuItem(text: "File", icon: Icons.file_present, route: routes.fileR, context: context),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    required String route,
    required BuildContext context,
  }) {
    const color = Colors.white;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color, fontSize: 16)),
      hoverColor: style.appMenuHoverColor,
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget buildHeader({required String title, required String subtitle}) {
    return InkWell(
      child: Container(
        padding: padding.add(const EdgeInsets.symmetric(vertical: 15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 35, child: Text("sentc")),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: style.subTitleStyleRevert,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
