import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ip_config_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if an IP address is already configured
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? ipAddress = prefs.getString('ip_address');

  runApp(MyApp(
    isInitialSetup: ipAddress == null || ipAddress.isEmpty,
  ));
}

class MyApp extends StatelessWidget {
  final bool isInitialSetup;

  MyApp({required this.isInitialSetup});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Route to either home or IP config screen based on initial setup
      home:
          isInitialSetup ? IPConfigScreen(isInitialSetup: true) : HomeScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/ip-config': (context) =>
            IPConfigScreen(isInitialSetup: false), // Settings screen case
      },
    );
  }
}
