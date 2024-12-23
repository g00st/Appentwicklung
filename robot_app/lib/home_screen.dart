import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/api_handler.dart';
import 'package:robot_app/app_state.dart';
import 'package:robot_app/robot_control.dart';
import 'package:robot_app/error_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'status_bar.dart';
import 'custom_app_bar.dart';
import 'menu_drawer.dart'; // Import the MenuDrawer
import 'dart:convert'; // For JSON handling
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    appState.initTimer(); // Initialize timer or other necessary actions

    return Scaffold(
      appBar: CustomAppBar(title: 'Robot Control'),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              Expanded(
                child: RobotControlWidget(),
              ),
            ],
          ),

          // Conditionally show the error popup if robot is not homed
          if (!appState.isHomed) // Error condition from AppState
            Positioned.fill(
              child: ErrorPopup(
                onHomePressed:
                    ApiHandler.homeRobot, // Function to home the robot
              ),
            ),
        ],
      ),

      // Add the Drawer to the Scaffold
      drawer: MenuDrawer(),
    );
  }
}
