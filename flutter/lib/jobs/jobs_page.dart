// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'jobs_page_create_task.dart';
import 'jobs_page_details.dart';
import '../custom_app_bar.dart';
import '../menu_drawer.dart';
import '../app_state.dart';
import '../error_popup.dart';
import '../api_handler.dart';

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
