import 'package:flutter/material.dart';
import '../api_handler.dart';

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
