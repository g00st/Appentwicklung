import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/api_handler.dart';
import 'package:robot_app/home_screen.dart';
import 'package:robot_app/ip_config_screen.dart';
import 'package:robot_app/status_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_state.dart';

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

    
 

    return ChangeNotifierProvider(
      

      // Provide the AppState instance to the widget tree
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Flutter App State Management',
        home: 
          isInitialSetup ? IPConfigScreen(isInitialSetup: true) : HomeScreen(),
        routes: {
        '/home': (context) => HomeScreen(),
        '/ip-config': (context) =>
            IPConfigScreen(isInitialSetup: false), // Settings screen case
      }
      ),
    );
  }
}


