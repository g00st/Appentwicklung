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
            leading: Icon(Icons.home),
            title: Text('Control'),
            onTap: () {
              Navigator.pushNamed(context, '/robot-control'); // Close the menu when tapped
              // Navigate to home or perform some other action
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Jobs'),
            onTap: () {
              Navigator.pushNamed(context, '/jobs');

              // Navigate to settings or perform some other action
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('simple test'),
            onTap: () {
              Navigator.pushNamed(context, '/simple-plate');
              // Navigate to info or perform some other action
            },
          ),

        ],
      ),
    );
  }
}
