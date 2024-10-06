import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/api_handler.dart';
import 'package:robot_app/app_state.dart';

class RobotControlWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the app state from the Provider
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (appState.status.state == PrinterState.ready) ...[
              // Case: Robot is connected but not homed
              if (!appState.isHomed) ...[
                Icon(Icons.warning, color: Colors.red, size: 100),
                Text("Robot not homed", style: TextStyle(fontSize: 25)),
                SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // Change to a more vibrant color
                    foregroundColor: Colors.white, // Text color
                    textStyle: TextStyle(fontSize: 25),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: ApiHandler.homeRobot,
                  child: Text('Home Robot', style: TextStyle(fontSize: 25)),
                ),
              ] else ...[
                // Disarm Motors Section
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Change to a vibrant color
                    foregroundColor: Colors.white, // Text color
                    textStyle: TextStyle(fontSize: 25),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: ApiHandler.disarmRobot,
                  child: Text('Disarm Motors'),
                ),

                SizedBox(height: 10), // Space between sections

                // X Axis Controls
                _buildAxisControlSection('X', ApiHandler.moveX),

                SizedBox(height: 10), // Space between sections

                // Z Axis Controls
                _buildZAxisControlSection(),

                SizedBox(height: 10), // Space between sections

                // Pump Controls
                _buildPumpControlSection(),
              ]
            ] else ...[
              // Case: No connection to robot
              Icon(Icons.error_outline, color: Colors.grey, size: 100),
              Text("No Connection", style: TextStyle(fontSize: 25)),
              Text(
                appState.status.msg,
                style: TextStyle(fontSize: 20, color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAxisControlSection(String axis, Function(int) moveFunction) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$axis Axis Controls',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // X-axis buttons with ±100
      
              _buildMoveButton(moveFunction, 10),
              SizedBox(width: 10),
              _buildMoveButton(moveFunction, 1),
              SizedBox(width: 10),
              _buildMoveButton(moveFunction, -1),
              SizedBox(width: 10),
                _buildMoveButton(moveFunction, -10),
              
            
             
            ],
            
          ) ,
          SizedBox(height: 10),
          if (axis == 'X') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMoveButton(moveFunction, 100),
                SizedBox(width: 10),
                _buildMoveButton(moveFunction, -100),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildZAxisControlSection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Z Axis Controls',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMoveButton(ApiHandler.moveZ, 10),
              SizedBox(width: 10),
              _buildMoveButton(ApiHandler.moveZ, 1),
              SizedBox(width: 10),
              _buildMoveButton(ApiHandler.moveZ, -1),
              SizedBox(width: 10),
              _buildMoveButton(ApiHandler.moveZ, -10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoveButton(Function(int) moveFunction, int increment) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => moveFunction(increment),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Use a vibrant color for visibility
          foregroundColor: Colors.white, // Text color
          padding: EdgeInsets.symmetric(vertical: 15), // Add vertical padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(increment > 0 ? '+$increment' : '$increment'),
      ),
    );
  }

  Widget _buildPumpControlSection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Pump Controls',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ApiHandler.ctrlPump(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green, // Use a vibrant color for visibility
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('ON'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ApiHandler.ctrlPump(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // Use a vibrant color for visibility
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('OFF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void printHi() {
    print("hi");
  }
}
