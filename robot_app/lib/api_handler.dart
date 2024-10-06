import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

enum PrinterState {
  startup,
  ready,
  shutdown,
  error,
  networkError;
}

class Status {
  final PrinterState state; // Holds the printer state
  final String msg; // Holds the message associated with the state
  // Constructor for Status
  const Status(this.state, this.msg);
}

class ApiHandler {
  // Static variable to hold the IP address
  static String IP_address = '';
  static CancelToken?
      _cancelToken; // Holds the cancel token for the current request
  static Dio dio = Dio();

  // Static method to set the IP address
  static void set_ip_address(String ipAddress) {
    IP_address = ipAddress;
  }

  static Future<Status> fetchPrinterState() async {
    String endpoint = 'http://$IP_address/printer/info';

    // Cancel the previous request if there is one
    _cancelToken?.cancel('New request triggered');

    // Create a new cancel token for the current request
    _cancelToken = CancelToken();

    try {
      // Make the request with the cancel token
      final response = await dio.get(
        endpoint,
        cancelToken: _cancelToken,
      );

      if (response.statusCode == 200) {
        final data_r = response.data;
        final data = data_r['result'];

        String state = data['state'];
        String stateMessage = data['state_message'];

        // Map the string state to the corresponding PrinterState enum
        PrinterState? printerState;
        switch (state) {
          case 'startup':
            printerState = PrinterState.startup;
            break;
          case 'ready':
            printerState = PrinterState.ready;
            break;
          case 'shutdown':
            printerState = PrinterState.shutdown;
            break;
          case 'error':
            printerState = PrinterState.error;
            break;
          default:
            throw Exception('Unknown printer state: $state');
        }

        return Status(printerState, stateMessage);
      } else {
        return Status(
            PrinterState.networkError, "network error: ${response.statusCode}");
      }
    } catch (e) {
      return Status(PrinterState.networkError, 'Request to IP: $IP_address timed out, please check if robot is turned on');
    }
  }

  static Future<bool> isXAndZHomed() async {
    final url = Uri.parse('http://$IP_address/printer/objects/query');

    // The data to send in the POST request
    final body = jsonEncode({
      "objects": {
        "toolhead": ["homed_axes"]
      }
    });

    try {
      // Send the POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Extract the "homed_axes" field
        String homedAxes = responseData['result']['status']['toolhead']['homed_axes'];

        // Check if X and Z axes are homed
        bool isXHomed = homedAxes.contains('x');
        bool isZHomed = homedAxes.contains('z');

        // Return true if both X and Z are homed
        return isXHomed && isZHomed;
      } else {
        // Handle the error if the status code is not 200
        print('Request failed with status: ${response.statusCode}.');
        return false;
      }
    } catch (e) {
      // Handle any exceptions
      print('Error: $e');
      return false;
    }
  }


   static Future<void> sendGCode(String gcode) async {
    final url = Uri.parse('http://$IP_address/printer/gcode/script');

    // Body of the POST request - sending the G-code passed as a parameter
    final body = jsonEncode({
      "script": gcode
    });

    try {
      // Send the POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        print("G-code '$gcode' sent successfully!");
      } else {
        print("Failed to send G-code '$gcode': ${response.statusCode}");
      }
    } catch (e) {
      // Handle any errors
      print("Error occurred while sending G-code '$gcode': $e");
    }
  }

  static Future<void> homeRobot() async {
    return sendGCode("HOME_ZX");
    }

  static Future<void> disarmRobot() async {
    ctrlPump(false);
    return sendGCode("M84");
    }

  static Future<void> moveX(int X) async {
    String moveX = "G91\nG1 X$X F6000\nG90";
    return sendGCode(moveX);
    }

  static Future<void> moveZ(int Z) async {
    String moveZ = "G91\nG1 Z$Z F6000\nG90";
    return sendGCode(moveZ);
    }

  static Future<void> ctrlPump(bool on) async { return sendGCode(on?"TURN_PUMP_ON":"TURN_PUMP_OFF");  }
}
