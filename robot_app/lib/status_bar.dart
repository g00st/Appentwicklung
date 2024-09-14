import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String status;
  final String ipAddress;

  StatusBar({required this.status, required this.ipAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: status == 'connected' ? Colors.green : Colors.red,
      height: 50,
      child: Center(
        child: Text(
          'Status: $status | IP: $ipAddress',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
