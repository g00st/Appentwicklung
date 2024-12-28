import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_handler.dart'; // Import the ApiHandler class
import 'custom_app_bar.dart';
import 'menu_drawer.dart';
import 'app_state.dart';
import 'api_handler.dart';
import 'error_popup.dart';

class SimplePlate extends StatelessWidget {
  const SimplePlate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final List<String> gcodeCommands = [
      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X63 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X95 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',


      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X127 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X159 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X193 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',
      
      'G1 X226 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X259 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X292 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X326 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X359 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X392 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X425 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X458 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X491 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
      'G1 Z25 F20000',
      'G4 P500',
      'TURN_PUMP_ON',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 X520 F20000',
      'G1 Z20 F20000',
      'G4 P500',
      'TURN_PUMP_OFF',
      'G4 P500',
      'G1 Z0 F20000',

      'G1 Z0 F20000',
      'G1 X0 F20000',
    ];

    return Scaffold(
      appBar: CustomAppBar(title: 'Simple test'),  // Use the CustomAppBar with title "Jobs"
      drawer: MenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                for (String command in gcodeCommands) {
                  await ApiHandler.sendGCode(command);
                  // if (command == 'TURN_PUMP_ON' || command == 'TURN_PUMP_OFF') {
                  //   await Future.delayed(const Duration(seconds: 2)); // Wait for 1 second
                  // } else {
                  //   await Future.delayed(const Duration(milliseconds: 700)); // Wait for 0.5 seconds
                  // }
                }
              },
              child: const Text('Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Correct parameter name
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                for (String command in gcodeCommands) {
                  await ApiHandler.sendGCode(command);
                }
              },
              child: const Text('Pause'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Correct parameter name
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Use ApiHandler to send the stop G-code
                await ApiHandler.sendGCode('M112'); // Example: Emergency Stop
              },
              child: const Text('Stop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Correct parameter name
              ),
            ),
            if (!appState.isHomed) // Error condition from AppState
            Positioned.fill(
              child: ErrorPopup(
                onHomePressed:
                    ApiHandler.homeRobot, // Function to home the robot
              ),
            ),
          ],
        ),
      ),
    );
  }
}
