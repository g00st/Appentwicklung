import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'custom_app_bar.dart';
import 'menu_drawer.dart';
import 'app_state.dart';
import 'error_popup.dart';
import 'api_handler.dart';

class JobsPage extends StatefulWidget {
  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  late Future<List<SeedTask>> _tasksFuture;
  bool _dialogShown = false;
  // Two booleans for filtering finished and unfinished tasks independently.
  bool _showFinishedTasks = true;
  bool _showUnfinishedTasks = true;

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Fetch tasks on initialization
  }

  // Function to reload tasks.
  void _loadTasks() {
    setState(() {
      _tasksFuture = ApiHandler.getTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    appState.initTimer();

    // Show the error dialog if the robot is not homed and it hasn't been shown already.
    if (!appState.isHomed &&
        !_dialogShown &&
        appState.status.state != PrinterState.networkError) {
      Future.delayed(Duration.zero, () {
        showErrorDialog(
          context,
          () {
            // Home the robot.
            ApiHandler.homeRobot();
            // Dismiss the dialog after homing the robot.
            Navigator.of(context).pop();
            setState(() {
              _dialogShown = false;
            });
          },
        );
        setState(() {
          _dialogShown = true; // Mark dialog as shown.
        });
      });
    } else if (appState.isHomed && _dialogShown) {
      // If the robot is homed, dismiss the dialog and update state.
      Navigator.of(context).pop();
      setState(() {
        _dialogShown = false;
      });
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Jobs'),
      drawer: MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Modified header: Only the filter icon is shown on the right.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      if (value == 'unfinished') {
                        _showUnfinishedTasks = !_showUnfinishedTasks;
                      } else if (value == 'finished') {
                        _showFinishedTasks = !_showFinishedTasks;
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    CheckedPopupMenuItem<String>(
                      value: 'unfinished',
                      checked: _showUnfinishedTasks,
                      child: Text('Show Unfinished'),
                    ),
                    CheckedPopupMenuItem<String>(
                      value: 'finished',
                      checked: _showFinishedTasks,
                      child: Text('Show Finished'),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                // Wrap list with pull-to-refresh.
                onRefresh: () async {
                  _loadTasks(); // Reload data when user pulls down.
                },
                child: _buildJobList(),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button to add a new Task.
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Navigate to CreateTaskScreen and wait for a result.
          bool? created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskScreen()),
          );
          // If a new task was created, reload tasks.
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
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No tasks found'));
        }

        var tasks = snapshot.data!;
        // Filter tasks based on the selected checkboxes.
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
              margin: EdgeInsets.symmetric(vertical: 8.0),
              elevation: 5,
              color: task.completionCount >= task.targetCount
                  ? const Color.fromARGB(255, 120, 221, 106)
                  : Colors.white, // Change background color based on completion.
              child: ListTile(
                leading: Icon(Icons.work, color: Colors.blue),
                title: Text(task.seedType),
                subtitle: Text('${task.completionCount}/${task.targetCount}'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailsScreen(taskId: task.id),
                    ),
                  );
                  _loadTasks(); // Reload tasks when returning.
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

  JobDetailsScreen({this.taskId});

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Future<Map<String, dynamic>> _detailFuture;
  PrinterState? _previousState; // Track previous printer state.

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
        SnackBar(content: Text("Task started successfully!")),
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
        title: Text("Delete Task"),
        content: Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await ApiHandler.deleteTask(taskId);
        Navigator.pop(context, true); // Return to refresh job list.
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

        // Check if the state changed to "ready" (from any other state).
        if (_previousState != PrinterState.ready && isReady) {
          _detailFuture = _loadDetails(); // Refresh details on state change.
        }

        // Update the previous state for the next comparison.
        _previousState = appState.status.state;

        return Scaffold(
          appBar: AppBar(
            title: Text('Job Details'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, true); // Refresh when returning.
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
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
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!["task"] == null) {
                return Center(child: Text('No details found'));
              }

              final SeedTask task = snapshot.data!["task"];
              final String plateName = snapshot.data!["plateName"] ?? "Unknown";

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Completion Count / Target Count at the top.
                    Center(
                      child: Text(
                        "${task.completionCount} / ${task.targetCount}",
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Seed Type.
                    Text(
                      "Seed Type: ${task.seedType}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    // Plate Type (Name).
                    Text(
                      "Plate Type: $plateName",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    // Other Task Info.
                    Text("ID: ${task.id}", style: TextStyle(fontSize: 18)),
                    Text("Created: ${task.creationDate}",
                        style: TextStyle(fontSize: 18)),
                    Text("Finish Time: ${task.finishTime ?? 'N/A'}",
                        style: TextStyle(fontSize: 18)),
                    Divider(),
                    // RUN TASK Button.
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (task.completionCount >= task.targetCount)
                              ? Colors.green // Completed state.
                              : (isReady ? Colors.red : Colors.grey), // Active or disabled.
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16),
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
                          style: TextStyle(
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
  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields (creationDate and completionCount are auto-handled).
  final TextEditingController _seedTypeController = TextEditingController();
  final TextEditingController _targetCountController = TextEditingController();
  final TextEditingController _finishTimeController = TextEditingController();

  String? _selectedPlateId; // Selected plate's id.
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
      print("Error loading plate types: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Auto-generate creation date as current date in ISO 8601 format.
      final String creationDate = DateTime.now().toIso8601String();

      // Create a new SeedTask with id as null and completionCount as 0.
      final newTask = SeedTask(
        id: null,
        seedType: _seedTypeController.text,
        plateType: _selectedPlateId ?? "",
        targetCount: int.tryParse(_targetCountController.text) ?? 0,
        creationDate: creationDate,
        completionCount: 0,
        finishTime: int.tryParse(_finishTimeController.text),
      );

      print("New Task: $newTask");

      try {
        final createdTask = await ApiHandler.createTask(newTask);
        print("Created Task: $createdTask");
        Navigator.pop(context, true);
      } catch (e) {
        print("Error creating task: $e");
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
        title: Text("Create New Task"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _seedTypeController,
                      decoration: InputDecoration(labelText: "Seed Type"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter seed type";
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "Plate"),
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
                      decoration: InputDecoration(labelText: "Target Count"),
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
                      decoration: InputDecoration(labelText: "Finish Time"),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text("Create Task"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
