import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import '../api_handler.dart';

class JobDetailsScreen extends StatefulWidget {
  final String? taskId;

  const JobDetailsScreen({super.key, this.taskId});

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Future<Map<String, dynamic>> _detailFuture;
  PrinterState? _previousState;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetails();
  }

  Future<Map<String, dynamic>> _loadDetails() async {
    final SeedTask? task = await ApiHandler.getTaskById(widget.taskId!);

    String? plateName;
    if (task != null && task.plateType.isNotEmpty) {
      try {
        final plate = await ApiHandler.getPlatebyId(task.plateType);
        plateName = plate?.name ?? "No valid plate";
      } catch (e) {
        plateName = "Unknown Plate";
      }
    }

    return {"task": task, "plateName": plateName};
  }

  Future<void> _runTask(SeedTask task) async {
    try {
      await ApiHandler.runTask(task);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task started successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to start task: $e")),
      );
    }
  }

  Future<void> _deleteTask(String taskId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await ApiHandler.deleteTask(taskId);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete task: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        bool isReady = appState.status.state == PrinterState.ready;

        if (_previousState != PrinterState.ready && isReady) {
          _detailFuture = _loadDetails();
        }

        _previousState = appState.status.state;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Job Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  if (widget.taskId != null) {
                    await _deleteTask(widget.taskId!);
                  }
                },
              ),
            ],
          ),
          body: FutureBuilder<Map<String, dynamic>>(
            future: _detailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!["task"] == null) {
                return const Center(child: Text('No details found'));
              }

              final SeedTask task = snapshot.data!["task"];
              final String plateName = snapshot.data!["plateName"] ?? "Unknown";

              final creationDateTime = DateTime.parse(task.creationDate);
              final formattedCreationDate =
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(creationDateTime);

              final finishDateTime = task.finishTime != null
                  ? DateTime.fromMillisecondsSinceEpoch(task.finishTime!)
                  : null;
              final formattedFinishTime = finishDateTime != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(finishDateTime)
                  : 'Task not finished';

              final durationString = finishDateTime != null
                  ? "${finishDateTime.difference(creationDateTime).inHours}h ${finishDateTime.difference(creationDateTime).inMinutes.remainder(60)}m"
                  : '';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "${task.completionCount} / ${task.targetCount} completed",
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Seed Type: ${task.seedType}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(thickness: 4),
                    Text(
                      "Plate Type: $plateName",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(thickness: 4),
                    Text("Created: $formattedCreationDate",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("Finish Time: $formattedFinishTime",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(thickness: 4),
                    Text("Duration: $durationString",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(
                      thickness: 4,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (task.completionCount >= task.targetCount)
                                  ? Colors.green
                                  : (isReady ? Colors.red : Colors.grey),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Colors.grey,
                          disabledForegroundColor: Colors.black,
                        ),
                        onPressed: (task.completionCount >= task.targetCount)
                            ? null
                            : (isReady ? () => _runTask(task) : null),
                        child: Text(
                          (task.completionCount >= task.targetCount)
                              ? "Task Completed"
                              : (isReady
                                  ? "RUN TASK"
                                  : "Robot is ${appState.status.state.toString().split('.').last}"),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}