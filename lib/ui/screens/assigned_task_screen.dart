import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:markitdone/providers/view_models/tasks_viewmodel.dart';
import 'package:provider/provider.dart';

class AssignedTaskScreen extends StatefulWidget {
  const AssignedTaskScreen({super.key});

  @override
  State<AssignedTaskScreen> createState() => _AssignedTaskScreenState();
}

class _AssignedTaskScreenState extends State<AssignedTaskScreen> {
  List<String> selectedTask = [];
  List<Task> task = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    fetchTask();
  }

  // Function to handle checkbox state change
  void onCheckboxChanged(String taskId, bool? value) {
    setState(() {
      if (value != null) {
        if (value) {
          selectedTask.add(taskId); // Add to list if selected
        } else {
          selectedTask.remove(taskId); // Remove from list if deselected
        }
      }
    });
  }

  fetchTask() async {
    try {
      var allTaskSnapshot = await FirebaseFirestore.instance
          .collection("alltasks")
          .where("assignedto",
              isEqualTo: Provider.of<AuthViewModel>(context).phoneNumber)
          .get();
      setState(() {
        task = allTaskSnapshot.docs.map((doc) {
          return Task(
            id: doc.id,
            title: doc['title'],
            state: doc['state'],
            assignedTo: doc['assignedto'],
            createdBy: doc['createdBy'],
          );
        }).toList();
      });
    } catch (e) {
      // Handle error during Firestore fetch
      print("Error fetching tasks: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Visibility(
            visible: selectedTask.isNotEmpty,
            child: SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  if (selectedTask.isNotEmpty) {
                    // Update task states using TasksViewmodel
                    Provider.of<TasksViewmodel>(context, listen: false)
                        .updateTaskState(selectedTask)
                        .then((_) {
                      setState(() {
                        selectedTask.clear(); // Clear after update is done
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Updated ${selectedTask.length} tasks."),
                      ));
                    }).catchError((e) {
                      // Error handling if update fails
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Error updating tasks: $e"),
                      ));
                    });
                  }
                },
                child: const Text(
                  'Done',
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: task.length,
              itemBuilder: (context, index) {
                Task taskValue = task[index];
                final taskName = taskValue.title;
                final taskStatus = taskValue.state;
                final taskAssignedTo = taskValue.assignedTo;
                final taskCreatedBy = taskValue.createdBy;

                return ListTile(
                  title: Text(taskName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: $taskStatus'),
                      Text('Assigned To: $taskAssignedTo'),
                      Text('Created By: $taskCreatedBy'),
                    ],
                  ),
                  trailing: Checkbox(
                    value: selectedTask.contains(taskValue.id),
                    onChanged: (bool? value) {
                      onCheckboxChanged(taskValue.id, value);
                    },
                  ),
                  onTap: () {
                    // Handle task tap, e.g., view task details or edit
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String state;
  final String assignedTo;
  final String createdBy;

  Task(
      {required this.id,
      required this.title,
      required this.state,
      required this.assignedTo,
      required this.createdBy});
}
