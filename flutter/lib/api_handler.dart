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
  static String IP_address = '';
  static CancelToken? _cancelToken;
  static Dio dio = Dio();

  static void set_ip_address(String ipAddress) {
    IP_address = ipAddress;
  }

  static Future<Status> fetchPrinterState() async {
    String endpoint =
        'http://$IP_address/printer/objects/query?webhooks&virtual_sdcard&print_stats';
    print(endpoint);

    _cancelToken?.cancel('New request triggered');

    _cancelToken = CancelToken();

    try {
      final response = await dio.get(
        endpoint,
        cancelToken: _cancelToken,
      );

      if (response.statusCode == 200) {
        final dataR = response.data;
        final data = dataR['result'];
        final webhooks = data["status"]['webhooks'];

        String state = webhooks['state'];
        String stateMessage = webhooks['state_message'];

        PrinterState? printerState;
        switch (state) {
          case 'startup':
            printerState = PrinterState.startup;
            break;
          case 'ready':
            if (data["status"]["print_stats"]["state"] != "printing") {
              printerState = PrinterState.ready;
            } else {
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

    final body = jsonEncode({
      "objects": {
        "toolhead": ["homed_axes"]
      }
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        String homedAxes =
            responseData['result']['status']['toolhead']['homed_axes'];

        bool isXHomed = homedAxes.contains('x');
        bool isZHomed = homedAxes.contains('z');
        return isXHomed && isZHomed;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> sendGCode(String gcode) async {
    final url = Uri.parse('http://$IP_address/printer/gcode/script');

    final body = jsonEncode({"script": gcode});

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
      } else {
      }
    // ignore: empty_catches
    } catch (e) {
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
      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        final dataR = response.data;
        return SeedTask.fromArray(dataR);
      } else {
        return List.empty();
      }
    } catch (e) {
      return List.empty();
    }
  }

  static Future<SeedTask> createTask(SeedTask task) async {
    String endpoint = 'http://$IP_address:3000/jobs';
    final taskJson = task.toJson();
    taskJson.remove('_id');

    try {
      final response = await dio.post(endpoint, data: taskJson);

      if (response.statusCode == 201) {
        return SeedTask.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create task, status code: ${response.statusCode}');
      }
    } catch (e) {
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
        throw Exception(
            'Failed to fetch task, status code: ${response.statusCode}');
      }
    } catch (e) {
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
      throw Exception('Error running task: $e');
    }
  }

  static Future<void> deleteTask(String id) async {
    String endpoint = 'http://$IP_address:3000/jobs/$id'; // DELETE endpoint

    try {
      final response = await dio.delete(endpoint);

      if (response.statusCode == 200) {
      } else {
        throw Exception(
            'Failed to delete task, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

  static Future<PlateType?> getPlatebyId(String id) async {
    String endpoint = 'http://$IP_address:3000/plates/$id';
    final response = await dio.get(endpoint);

    if (response.statusCode == 200) {
      return PlateType.fromJson(response.data);
    } else {
      return null;
    }
  }

  static Future<List<PlateType>> getPlateTypes() async {
    String endpoint = 'http://$IP_address:3000/plates';
    try {
      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        final dataR = response.data;
        return PlateType.fromArray(dataR);
      } else {
        return List.empty();
      }
    } catch (e) {
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

  factory SeedTask.fromJson(Map<String, dynamic> json) {
    final String? id = json['_id'];
    final String? seedType = json['seed_type'];
    final String? plateType = json['plate_type'];
    final int? targetCount = json['target_count'];
    final String? creationDate = json['creation_date'];
    final int? completionCount = json['completion_count'];
    final int? finishTime = json['finish_time'];


    return SeedTask(
      id: id ?? 'unknown_id',
      seedType: seedType ?? 'unknown_seed',
      plateType: plateType ?? 'unknown_plate',
      targetCount: targetCount ?? 0,
      creationDate: creationDate ?? 'unknown_date',
      completionCount: completionCount ?? 0,
      finishTime: finishTime,
    );
  }

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

  static List<SeedTask> fromArray(List<dynamic> jsonArray) {
    List<SeedTask> seedTaskList = [];
    for (var json in jsonArray) {
      SeedTask task = SeedTask.fromJson(json);
      seedTaskList.add(task);
    }
    return seedTaskList;
  }
}

class PlateType {
  final String id;
  final String name;
  final String g_code;

  // ignore: non_constant_identifier_names
  PlateType({required this.name, required this.g_code, required this.id});

  factory PlateType.fromJson(Map<String, dynamic> json) {
    return PlateType(
      name: json['name'] as String,
      g_code: json['g_code'] as String,
      id: json['_id'] as String,
    );
  }

  static List<PlateType> fromArray(List<dynamic> jsonArray) {
    List<PlateType> plateList = [];
    for (var i = 0; i < jsonArray.length; i++) {
      final Map<String, dynamic> jsonMap = jsonArray[i] as Map<String, dynamic>;
      final PlateType plate = PlateType.fromJson(jsonMap);
      plateList.add(plate);
    }
    return plateList;
  }
}
