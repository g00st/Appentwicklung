import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

enum PrinterState {
  startup,
  ready,
  shutdown,
  error,
  networkError,
  printing;
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
    String endpoint = 'http://$IP_address/printer/objects/query?webhooks&virtual_sdcard&print_stats';
    print("IIIIIIIIIIIIIIIIIIIIIPPPPPPPPPPPPPPPPPPPPPPPPPP");
    print(endpoint);

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
        print(data_r);
        final data = data_r['result'];
        print(data);
        final webhooks = data["status"]['webhooks'];
        print(webhooks);

        String state = webhooks['state'];
        String stateMessage = webhooks['state_message'];

        // Map the string state to the corresponding PrinterState enum
        PrinterState? printerState;
        switch (state) {
          case 'startup':
            printerState = PrinterState.startup;
            break;
          case 'ready':
            if (data["status"]["print_stats"]["state"] != "printing"){
            printerState = PrinterState.ready;
            }else{
              printerState = PrinterState.printing;
            }
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
      return Status(PrinterState.networkError,
          'Request to IP: $IP_address timed out, please check if robot is turned on');
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
        String homedAxes =
            responseData['result']['status']['toolhead']['homed_axes'];

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
    final body = jsonEncode({"script": gcode});

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
    return sendGCode("G28");
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

  static Future<void> ctrlPump(bool on) async {
    return sendGCode(on ? "TURN_PUMP_ON" : "TURN_PUMP_OFF");
  }

  static Future<List<SeedTask>> getTasks() async {

    String endpoint = 'http://$IP_address:3000/jobs';
     try {
      // Make the request with the cancel token
      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        final data_r = response.data;
        final test = SeedTask.fromArray(data_r);
        print(test);
        return SeedTask.fromArray(data_r);

      } 
      else {
        print("Big Fuckup1");
        return List.empty();
      } 
    }catch (e) {
      print("Big Fuckup2");
      print(e);
      return List.empty();
    }

  }

  static Future <SeedTask> createTask(SeedTask task) async {
    String endpoint = 'http://$IP_address:3000/jobs';
    print("TASK ????????????????????????????????????????????????");
    print(task);
    final taskJson = task.toJson();
    taskJson.remove('_id');
    print(taskJson);

    try {
      final response = await dio.post(endpoint, data: taskJson);

      if (response.statusCode == 201) {
        // Assuming the server returns the task data after creation
        return SeedTask.fromJson(response.data);
      } else {
        throw Exception('Failed to create task, status code: ${response.statusCode}');
      }
    } catch (e) {
      // Error handling (e.g., network errors)
      print('Error: $e');
      throw Exception('Error creating task: $e');
    }
    }

  static Future<SeedTask?> getTaskById(String id) async {
    String endpoint = 'http://$IP_address:3000/jobs/$id'; // GET endpoint

    try {
      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        return SeedTask.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch task, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching task: $e');
    }
  }

  static Future<SeedTask> runTask(SeedTask task) async {
    if (task.id == null) {
      throw Exception("Invalid ID: Task ID cannot be null.");
    }

    final String id = task.id!;
    String endpoint = 'http://$IP_address:3000/run/$id';

    try {
      final response = await dio.post(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        return SeedTask.fromJson(response.data);
      } else {
        throw Exception('Failed to run task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error running task: $e');
      throw Exception('Error running task: $e');
    }
  }

  static Future<void> deleteTask(String id) async {
    String endpoint = 'http://$IP_address:3000/jobs/$id'; // DELETE endpoint

    try {
      final response = await dio.delete(endpoint);

      if (response.statusCode == 200) {
        print('Task with ID $id deleted successfully.');
      } else {
        throw Exception('Failed to delete task, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error deleting task: $e');
    }
  }
  
  static Future<PlateType?> getPlatebyId(String id) async {
      String endpoint = 'http://$IP_address:3000/plates/$id'; // GET endpoint

      try {
        final response = await dio.get(endpoint);

        if (response.statusCode == 200) {
          return PlateType.fromJson(response.data);
        } else {
          throw Exception('Failed to fetch PlateType, status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
        throw Exception('Error fetching PlateType: $e');
      }
  }

  static Future<List<PlateType>> getPlateTypes() async {

    String endpoint = 'http://$IP_address:3000/plates';
     try {
      // Make the request with the cancel token
      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        final data_r = response.data;
        final test = SeedTask.fromArray(data_r);
        print(test);
        return PlateType.fromArray(data_r);

      } 
      else {
        print("Big  plates Fuckup1");
        return List.empty();
      } 
    }catch (e) {
      print("Big  plates Fuckup2");
      print(e);
      return List.empty();
    }
  }
  
  }

  




class SeedTask {


  final String? id;
  final String seedType;
  final String plateType;
  final int targetCount;
  final String creationDate;
  final int completionCount;
  final int? finishTime;

  SeedTask({
    required this.id,
    required this.seedType,
    required this.plateType,
    required this.targetCount,
    required this.creationDate,
    required this.completionCount,
    required this.finishTime,
  });

  // Factory method to create an instance from a JSON map
factory SeedTask.fromJson(Map<String, dynamic> json) {
  try {
    // Extract values with debugging prints
    final String? id = json['_id'];
    final String? seedType = json['seed_type'];
    final String? plateType = json['plate_type'];
    final int? targetCount = json['target_count'];
    final String? creationDate = json['creation_date'];
    final int? completionCount = json['completion_count'];
    final int? finishTime = json['finish_time'];

    // Debug print statements
    print("ID: $id");
    print("Seed Type: $seedType");
    print("Plate Type: $plateType");
    print("Target Count: $targetCount");
    print("Creation Date: $creationDate");
    print("Completion Count: $completionCount");
    print("Finish Time: $finishTime");

    // Return the created object
    return SeedTask(
      id: id ?? 'unknown_id', // Handle potential nulls safely
      seedType: seedType ?? 'unknown_seed',
      plateType: plateType ?? 'unknown_plate',
      targetCount: targetCount ?? 0,
      creationDate: creationDate ?? 'unknown_date',
      completionCount: completionCount ?? 0,
      finishTime: finishTime ?? null,
    );
  } catch (e, stackTrace) {
    print("Error parsing SeedTask JSON: $e");
    print("StackTrace: $stackTrace");
    throw Exception("Failed to parse SeedTask JSON: $json");
    
  }
}

  // Method to convert this object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': {'\$oid': id},
      'seed_type': seedType,
      'plate_type': plateType,
      'target_count': targetCount,
      'creation_date': creationDate,
      'completion_count': completionCount,
      'finish_time': finishTime,
    };
  }

  // Method to deserialize a JSON array into a list of SeedTask objects
  static List<SeedTask> fromArray(List<dynamic> jsonArray) {
    List<SeedTask> seedTaskList = [];

    for (var json in jsonArray) {
      print("Processing JSON: $json"); // Debugging: Print each JSON object
      try {
      SeedTask task = SeedTask.fromJson(json);
      seedTaskList.add(task);
      print("--------------------------------------------------------------------------");
      print(task.id);
      } catch (e) {
       print("Error converting JSON to SeedTask: $e");
      }
  }
    return seedTaskList;
  }
}


class PlateType{
  final String id;
  final String name; 
  final  String g_code;

  PlateType({required this.name, required this.g_code, required this.id});

  factory PlateType.fromJson(Map<String, dynamic> json) {
    try{

    return PlateType(
      name: json['name'] as String,
      g_code: json['g_code'] as String,
      id : json['_id'] as String,
    );
    } catch (e, stackTrace) {
      print("---------------------------------------------------------------------------Error processing JSON at index  $e");
      print("StackTrace: $stackTrace");
      print(json);
      throw e;
    }
  }

static List<PlateType> fromArray(List<dynamic> jsonArray) {
  List<PlateType> plateList = [];
  for (var i = 0; i < jsonArray.length; i++) {
    try {
      final Map<String, dynamic> jsonMap = jsonArray[i] as Map<String, dynamic>;
      print("--------------------------------------------------------------------------------Processing JSON at index $i: $jsonMap");
      final PlateType plate = PlateType.fromJson(jsonMap);
      plateList.add(plate);
    } catch (e, stackTrace) {
      print("Error processing JSON at index $i: $e");
      print("StackTrace: $stackTrace");
    }
  }
  return plateList;
}
}

