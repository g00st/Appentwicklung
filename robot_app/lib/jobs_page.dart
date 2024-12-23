import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_app_bar.dart';  // Import the CustomAppBar widget
import 'menu_drawer.dart';  // Import the MenuDrawer widget
import 'app_state.dart';
import 'error_popup.dart';
import 'api_handler.dart';

class JobsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    appState.initTimer();
    return Scaffold(
      appBar: CustomAppBar(title: 'Jobs'),  // Use the CustomAppBar with title "Jobs"
      drawer: MenuDrawer(),  // Add the MenuDrawer for navigation
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!appState.isHomed) // Error condition from AppState
            Positioned.fill(
              child: ErrorPopup(
                onHomePressed:
                    ApiHandler.homeRobot, // Function to home the robot
              ),
            ),
            SizedBox(height: 20),
            Expanded(  // Wrap the job list in an Expanded widget to fill the available space
              child: _buildJobList(),  // List of jobs (can be dynamically populated)
            ),
          ],
        ),
      ),
    );
  }

  // Sample job list builder (can be replaced with actual data)
  Widget _buildJobList() {
    return ListView.builder(
      itemCount: 20,  // Set the number of jobs (can be dynamic)
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          elevation: 5,
          child: ListTile(
            leading: Icon(Icons.work, color: Colors.blue),
            title: Text('Job Title ${index + 1}'),
            subtitle: Text('This is a description of job #${index + 1}'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the Job Details page (replace with your actual navigation)
            },
          ),
        );
      },
    );
  }
}
