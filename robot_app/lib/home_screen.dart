import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'status_bar.dart';
import 'dart:convert'; // For JSON handling
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String status = "disconnected";
  String ipAddress = "";

  @override
  void initState() {
    super.initState();
    _loadIPAddress(); // Load IP address on init
  }

  Future<void> _loadIPAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = prefs.getString('ip_address') ?? '';
    });
    if (ipAddress.isNotEmpty) {
      _checkConnection(); // Check connection after loading IP
    } else {
      setState(() {
        status = "disconnected";
      });
    }
  }

  Future<void> _checkConnection() async {
    if (ipAddress.isEmpty) {
      setState(() {
        status = "disconnected";
      });
      return;
    }
    try {
      final response = await http.get(Uri.parse('http://$ipAddress/status'));
      if (response.statusCode == 200) {
        setState(() {
          status = "connected";
        });
      } else {
        setState(() {
          status = "unreachable";
        });
      }
    } catch (e) {
      setState(() {
        status = "error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _loadIPAddress();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          StatusBar(status: status, ipAddress: ipAddress),
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

  void _sendCommand(String command) async {
    if (ipAddress.isEmpty) {
      setState(() {
        status = "disconnected";
      });
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': command}),
      );

      if (response.statusCode == 200) {
        setState(() {
          status = "command sent";
        });
      } else {
        setState(() {
          status = "command failed";
        });
      }
    } catch (e) {
      setState(() {
        status = "error";
      });
    }
  }
}
