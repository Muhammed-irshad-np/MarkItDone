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
      required bool isScheduled,
      required String state}) async {
    final res = await _addTaskRepository.addTask(
      assignedTo: assignedTo,
      createdBy: createdBy,
      scheduledTime: scheduledTime,
      title: title,
      isPostponed: isPostponed,
      state: state,
      isScheduled: isScheduled,
    );
    print("logggg $res");
    return res;
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

  void reset() {
    // Clear any stored task data or state
    notifyListeners();
  }
}
