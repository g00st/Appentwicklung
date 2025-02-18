import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer Header
          DrawerHeader(
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
          // Menu Buttons
          ListTile(
            leading: Icon(Icons.gamepad),
            title: Text('Control'),
            onTap: () {
              Navigator.pushNamed(
                  context, '/robot-control'); // Close the menu when tapped
              // Navigate to home or perform some other action
            },
          ),
          ListTile(
            leading: Icon(Icons.work),
            title: Text('Jobs'),
            onTap: () {
              Navigator.pushNamed(context, '/jobs');

              // Navigate to settings or perform some other action
            },
          ),
          ListTile(
            leading: Icon(Icons.signal_wifi_4_bar_lock_rounded),
            title: Text('Robot connection'),
            onTap: () {
              Navigator.pushNamed(context, '/ip-config');

              // Navigate to settings or perform some other action
            },
          ),
        ],
      ),
    );
  }
}
