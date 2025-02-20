import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plate_seeder/api_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  Status _status = Status(PrinterState.error, "not initialized");
  String _ipAddress = "127.0.0.1";
  bool _isHomed = false;

  Status get status => _status;
  String get ipAddress => _ipAddress;
  bool get isHomed => _isHomed;

  AppState() {
    _loadIPAddress();
  }

  Future<void> _loadIPAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ipAddress = prefs.getString('ip_address') ?? 'seeding_robot.schaleon.com';
    ApiHandler.IP_address = _ipAddress;
    notifyListeners();
  }

  void updateStatus() async {
    _status = await ApiHandler.fetchPrinterState();
    notifyListeners();
  }

  void setIp(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip_address', ip);
    _ipAddress = ip;
    ApiHandler.IP_address = ip;
    notifyListeners();
  }

  static Timer? _timer = null;
  void initTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      updateStatus();
      if (status.state == PrinterState.ready) {
        getIsHomed();
      }
    });
  }

  void getIsHomed() async {
    _isHomed = await ApiHandler.isXAndZHomed();
  }
}
