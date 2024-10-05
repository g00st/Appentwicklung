import 'dart:convert';
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
  final String msg;         // Holds the message associated with the state
  // Constructor for Status
  const Status(this.state, this.msg);
}








class ApiHandler {
  // Static variable to hold the IP address
  static String IP_address = '';
  static CancelToken? _cancelToken; // Holds the cancel token for the current request
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
        return Status(PrinterState.networkError, "network error: ${response.statusCode}");
      }
    } catch (e) {
      
        return Status(PrinterState.networkError, 'Request timed out ');
      }
     
     
    }
  }


