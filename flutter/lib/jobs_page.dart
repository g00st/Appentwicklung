// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'custom_app_bar.dart';
import 'menu_drawer.dart';
import 'app_state.dart';
import 'error_popup.dart';
import 'api_handler.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  late Future<List<SeedTask>> _tasksFuture;
  bool _dialogShown = false;

  bool _showFinishedTasks = true;
  bool _showUnfinishedTasks = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasksFuture = ApiHandler.getTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    appState.initTimer();

    if (!appState.isHomed &&
        !_dialogShown &&
        appState.status.state != PrinterState.networkError) {
      Future.delayed(Duration.zero, () {
        showErrorDialog(
          context,
          () {
            ApiHandler.homeRobot();

            Navigator.of(context).pop();
            setState(() {
              _dialogShown = false;
            });
          },
        );
        setState(() {
          _dialogShown = true;
        });
      });
    } else if (appState.isHomed && _dialogShown) {
      Navigator.of(context).pop();
      setState(() {
        _dialogShown = false;
      });
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Jobs'),
      drawer: const MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      if (value == 'unfinished') {
                        _showUnfinishedTasks = !_showUnfinishedTasks;
                      } else if (value == 'finished') {
                        _showFinishedTasks = !_showFinishedTasks;
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    CheckedPopupMenuItem<String>(
                      value: 'unfinished',
                      checked: _showUnfinishedTasks,
                      child: const Text('Show Unfinished'),
                    ),
                    CheckedPopupMenuItem<String>(
                      value: 'finished',
                      checked: _showFinishedTasks,
                      child: const Text('Show Finished'),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadTasks();
                },
                child: _buildJobList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          bool? created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          );

          if (created == true) {
            _loadTasks();
          }
        },
      ),
    );
  }

  Widget _buildJobList() {
    return FutureBuilder<List<SeedTask>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks found'));
        }

        var tasks = snapshot.data!;

        var filteredTasks = tasks.where((task) {
          bool isFinished = task.completionCount >= task.targetCount;
          return (isFinished && _showFinishedTasks) ||
              (!isFinished && _showUnfinishedTasks);
        }).toList();

        return ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            var task = filteredTasks[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 5,
              color: task.completionCount >= task.targetCount
                  ? const Color.fromARGB(255, 120, 221, 106)
                  : Colors.white,
              child: ListTile(
                leading: const Icon(Icons.work, color: Colors.blue),
                title: Text(task.seedType),
                subtitle: Text('${task.completionCount}/${task.targetCount}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailsScreen(taskId: task.id),
                    ),
                  );
                  _loadTasks();
                },
              ),
            );
          },
        );
      },
    );
  }
}

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

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _seedTypeController = TextEditingController();
  final TextEditingController _targetCountController = TextEditingController();
  final TextEditingController _finishTimeController = TextEditingController();

  String? _selectedPlateId;
  List<PlateType> _plateTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlateTypes();
  }

  Future<void> _loadPlateTypes() async {
    try {
      final plates = await ApiHandler.getPlateTypes();
      setState(() {
        _plateTypes = plates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      DateTime.now().toIso8601String();
      try {
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating task: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _seedTypeController.dispose();
    _targetCountController.dispose();
    _finishTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Task"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _seedTypeController,
                      decoration: const InputDecoration(labelText: "Seed Type"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter seed type";
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Plate"),
                      value: _selectedPlateId,
                      items: _plateTypes.map((plate) {
                        return DropdownMenuItem<String>(
                          value: plate.id,
                          child: Text(plate.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedPlateId = val;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a plate";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _targetCountController,
                      decoration:
                          const InputDecoration(labelText: "Target Count"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter target count";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _finishTimeController,
                      decoration:
                          const InputDecoration(labelText: "Finish Time (ms)"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text("Create Task"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
