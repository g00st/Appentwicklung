import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final VoidCallback onHomePressed;

  const ErrorDialog({super.key, required this.onHomePressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, 
      contentPadding: const EdgeInsets.all(15), 
      titlePadding: EdgeInsets.zero, 
      content: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          const Icon(Icons.warning, color: Colors.red, size: 100),
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
            onPressed: onHomePressed, 
            child: const Text('Home Robot', style: TextStyle(fontSize: 25)),
          ),
        ],
      ),
    );
  }
}

void showErrorDialog(BuildContext context, VoidCallback onHomePressed) {
  showDialog(
    context: context,
    barrierDismissible:
        false, 
    builder: (BuildContext context) {
      return ErrorDialog(onHomePressed: onHomePressed);
    },
  );
}
