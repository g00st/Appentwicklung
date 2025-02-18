import 'package:flutter/material.dart';
import 'status_bar.dart'; 
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, 
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, size: 55), 
            onPressed: () {
              Scaffold.of(context).openDrawer(); 
            },
          );
        },
      ),
      flexibleSpace: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StatusBar(), 
          ],
        ),
      ),
      title: Text(title), 
      backgroundColor: Colors.blue, 
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
      kToolbarHeight + 40); 
}
