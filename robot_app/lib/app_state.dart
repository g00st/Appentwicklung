import 'dart:async';

import 'package:flutter/material.dart';
import 'package:robot_app/api_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class holds the app state and extends ChangeNotifier to notify listeners of changes
class AppState extends ChangeNotifier {
  // Example of state variables
  int _counter = 0;
  Status _status = Status(PrinterState.error, "not initialized");
  String _ipAddress = "127.0.0.1";
  bool _isHomed = false;
 
  // Getters to access private state
  int get counter => _counter;
  Status get status => _status;
  String get ipAddress => _ipAddress;
  bool get isHomed => _isHomed;

  AppState() {
    _loadIPAddress(); // Call the asynchronous IP loading function
  }

  // Method to load the IP address from SharedPreferences asynchronously
  Future<void> _loadIPAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ipAddress = prefs.getString('ip_address') ?? '';
    ApiHandler.IP_address = _ipAddress;

    // Notify listeners that the IP address has been loaded
    notifyListeners();
  }

  void updateStatus() async {
    _status = await ApiHandler.fetchPrinterState();
    //print("Guenter");
    print(_status.state);
    notifyListeners();
  }

  void  setIp (String ip)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip_address', ip);
    _ipAddress = ip;
    ApiHandler.IP_address =ip;
    notifyListeners();
  }

  // Example of a method that modifies the state and notifies listeners
  void incrementCounter() {
    _counter++;
    notifyListeners(); // This triggers the UI to rebuild when the state changes
  }

  static Timer? _timer = null;
  void initTimer() {
    _timer ??= Timer.periodic(Duration(seconds: 1), (Timer timer) {
      incrementCounter(); // Call the method every second
      updateStatus();
      if(status.state == PrinterState.ready){
        getIsHomed();
      }
    });
  }

  void getIsHomed()async{
    _isHomed = await ApiHandler.isXAndZHomed();
  }
}
