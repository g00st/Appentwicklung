import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/api_handler.dart'; // Assuming this is where PrinterState is defined
import 'package:robot_app/app_state.dart';

class StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    Color bgColor = Colors.white24; // Default color
    String statusText = ""; // Variable to hold the status message

    switch (appState.status.state) {
      case PrinterState.error:
        bgColor = const Color.fromARGB(255, 255, 0, 0); // Red
        statusText = 'Error';
        break;
      case PrinterState.startup:
        bgColor = const Color.fromARGB(255, 5, 99, 122); // Dark Cyan
        statusText = 'Starting Up';
        break;
      case PrinterState.ready:
        bgColor = const Color.fromARGB(255, 0, 255, 34); // Green
        statusText = 'Ready';
        break;
      case PrinterState.shutdown:
        bgColor = const Color.fromARGB(255, 179, 255, 2); // Light Yellow
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
        // Navigate to the IP configuration screen when tapped
        Navigator.pushNamed(context, '/ip-config');
      },
      onLongPress: () {
        // Show a snack bar with the alternate message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appState.status.msg), // Display the alternate message
            duration: const Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
      },
      child: Container(
        color: bgColor,
        height: 40, // Adjusted height for smaller size
        padding: const EdgeInsets.symmetric(
            horizontal: 5.0), // Add padding for spacing
        child: Row(
          children: [
            // Expanded widget to center the Status text
            Expanded(
              
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Status: $statusText',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16), // Smaller font size
                ),
              ),
            ),

            // Right-aligned IP text
            Text(
              'IP: ${appState.ipAddress}',
              style: const TextStyle(
                  color: Colors.white, fontSize: 16), // Smaller font size
            ),
          ],
        ),
      ),
    );
  }
}
