import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.gamepad),
            title: const Text('Control'),
            onTap: () {
              Navigator.pushNamed(context, '/robot-control');
            },
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Jobs'),
            onTap: () {
              Navigator.pushNamed(context, '/jobs');
            },
          ),
          ListTile(
            leading: const Icon(Icons.signal_wifi_4_bar_lock_rounded),
            title: const Text('Robot connection'),
            onTap: () {
              Navigator.pushNamed(context, '/ip-config');
            },
          ),
        ],
      ),
    );
  }
}
