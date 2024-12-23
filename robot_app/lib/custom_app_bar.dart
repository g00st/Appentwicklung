import 'package:flutter/material.dart';
import 'status_bar.dart';  // Make sure to import your StatusBar widget

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,  // Disable the default drawer icon
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.menu, size: 55),  // Match FAB icon size
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer when tapped
            },
          );
        },
      ),
      flexibleSpace: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StatusBar(), // StatusBar in the app bar
          ],
        ),
      ),
      title: Text(title),  // Display title
      backgroundColor: Colors.blue,  // You can customize the AppBar color
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 40);  // Increase height to fit StatusBar
}
