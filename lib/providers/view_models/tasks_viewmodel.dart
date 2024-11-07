import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:markitdone/data/repositories/add_task_repository.dart';

class TasksViewmodel extends ChangeNotifier {
  final AddTaskRepository _addTaskRepository;

  TasksViewmodel(this._addTaskRepository);

  Future<bool> addtask(BuildContext context,
      {required String assignedTo,
      required String createdBy,
      required DateTime scheduledTime,
      required String title,
      required bool isPostponed,
      required String state}) async {
    final res = await _addTaskRepository.addTask(
      assignedTo: assignedTo,
      createdBy: createdBy,
      scheduledTime: scheduledTime,
      title: title,
      isPostponed: isPostponed,
      state: state,
    );
    print("logggg $res");
    return res;
  }

  Future<void> updateTaskState(List<String> selectedTaskIds) async {
    for (String taskId in selectedTaskIds) {
      try {
        await FirebaseFirestore.instance
            .collection('alltasks')
            .doc(taskId)
            .update({
          'state': "completed", // Update the state of the task
          'updatedAt': FieldValue
              .serverTimestamp(), // Optionally track when it was updated
        });
      } catch (e) {
        print("Error updating task state: $e");
      }
    }
  }

  Future<void> deleteAllRows() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('alltask').get();
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      print("All documents in the alltask collection deleted successfully.");
    } catch (error) {
      print(error.toString());
    }
  }
}
