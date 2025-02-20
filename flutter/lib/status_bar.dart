import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plate_seeder/api_handler.dart';
import 'package:plate_seeder/app_state.dart';

class StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    Color bgColor = Colors.white24;
    String statusText = "";

    switch (appState.status.state) {
      case PrinterState.error:
        bgColor = const Color.fromARGB(255, 255, 0, 0);
        break;
      case PrinterState.startup:
        bgColor = const Color.fromARGB(255, 5, 99, 122);
        statusText = 'Starting Up';
        break;
      case PrinterState.ready:
        bgColor = const Color.fromARGB(255, 0, 255, 34);
        statusText = 'Ready';
        break;
      case PrinterState.shutdown:
        bgColor = const Color.fromARGB(255, 179, 255, 2);
        statusText = 'Shutting Down';
        break;
      case PrinterState.printing:
        bgColor = const Color.fromARGB(184, 2, 225, 255); // Light Yellow
        statusText = 'Job running';
        break;
      case PrinterState.networkError:
        bgColor = const Color.fromARGB(255, 85, 9, 9); // Dark Red
        statusText = 'Network Error';
        break;
      default:
        statusText = 'Unknown State';
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/ip-config');
      },
      onLongPress: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appState.status.msg),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        color: bgColor,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Status: $statusText',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            Text(
              'IP: ${appState.ipAddress}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
