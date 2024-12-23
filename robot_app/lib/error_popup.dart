import 'package:flutter/material.dart';
import 'package:robot_app/api_handler.dart';

class ErrorPopup extends StatelessWidget {
  final VoidCallback onHomePressed;

  const ErrorPopup({Key? key, required this.onHomePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the screen size and top/bottom padding
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = AppBar().preferredSize.height;
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    // Adjust the height and width to have 15px margin on all sides
    double availableHeight = screenHeight -
        appBarHeight -
        bottomPadding -
        50; // 15px margin on top and bottom
    double availableWidth = screenWidth - 60; // 15px margin on left and right

    return GestureDetector(
      child: Container(
        color: Colors.black.withOpacity(0.5), // Semi-transparent background
        child: Center(
          child: Container(
            color: Colors.white, // White background for the popup
            width: availableWidth, // 15px smaller on each side (total 30px)
            height:
                availableHeight, // 15px smaller on top and bottom (total 30px)
            child: Padding(
              padding:
                  const EdgeInsets.all(15), // Optional padding inside the popup
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onHomePressed, // Call the passed function
                    child: const Text('Home Robot',
                        style: TextStyle(fontSize: 25)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
