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
}
