import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IPConfigScreen extends StatefulWidget {
  final bool isInitialSetup; // A flag to indicate whether it's initial setup
  

  IPConfigScreen({this.isInitialSetup = false});

  @override
  _IPConfigScreenState createState() => _IPConfigScreenState();
}

class _IPConfigScreenState extends State<IPConfigScreen> {
  TextEditingController _ipController = TextEditingController();
  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Move Provider.of() to didChangeDependencies
    final appState = Provider.of<AppState>(context, listen: false); 
    _ipController.text = appState.ipAddress;  // Update the controller with appState value
  }


  Future<void> _saveIPAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final appState = Provider.of<AppState>(context, listen: false);
   
    appState.setIp (_ipController.text);
    // Check if this is the initial setup or not
    if (widget.isInitialSetup) {
      // Replace the IP config screen with the home screen
      print("tryed /home");
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // If it's not initial setup, just pop or go back to the previous screen
      print("cool nav shit");
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure IP Address'),
        automaticallyImplyLeading:
            !widget.isInitialSetup, // Disable back button during initial setup
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(labelText: 'Enter IP Address'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveIPAddress,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}