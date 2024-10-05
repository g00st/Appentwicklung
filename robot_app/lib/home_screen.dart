import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'status_bar.dart';
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
    appState.initTimer();
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Panel'),
        actions: [
          // Add a settings icon to allow IP change
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              // Navigate to the IP Config Screen
              await Navigator.pushNamed(context, '/ip-config');
              // Refresh the IP address and status after returning from IPConfigScreen
             
            },
          ),
        ],
      ),
      body: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_upward, size: 50),
                        onPressed: () => _sendCommand("up"),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward, size: 50),
                        onPressed: () => _sendCommand("down"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(Icons.power, size: 50),
                        onPressed: () => _sendCommand("pump_on"),
                      ),
                      IconButton(
                        icon: Icon(Icons.power_off, size: 50),
                        onPressed: () => _sendCommand("pump_off"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // To be implemented - Job creation logic
            },
            child: Text("Job Tab"),
          ),
        ],
      ),
    );
  }
  _sendCommand(String d){}
  
}
