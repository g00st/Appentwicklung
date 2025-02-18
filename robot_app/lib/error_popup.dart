import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final VoidCallback onHomePressed;

  const ErrorDialog({Key? key, required this.onHomePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // White background for the dialog
      contentPadding: EdgeInsets.all(15), // Padding inside the dialog
      titlePadding: EdgeInsets.zero, // Remove padding around the title
      content: Column(
        mainAxisSize: MainAxisSize.min, // Adjust the size based on the content
        children: [
          Icon(Icons.warning, color: Colors.red, size: 100),
          const SizedBox(height: 20),
          const Text(
            "Robot not homed",
            style: TextStyle(fontSize: 25, color: Colors.black),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 25),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onHomePressed, // Call the passed function
            child: const Text('Home Robot', style: TextStyle(fontSize: 25)),
          ),
        ],
      ),
    );
  }
}

// This function is used to show the error dialog
void showErrorDialog(BuildContext context, VoidCallback onHomePressed) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
    builder: (BuildContext context) {
      return ErrorDialog(onHomePressed: onHomePressed);
    },
  );
}
