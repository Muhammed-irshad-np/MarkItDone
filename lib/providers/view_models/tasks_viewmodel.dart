import 'package:flutter/material.dart';
import 'package:markitdone/data/repositories/add_task_repository.dart';

class TasksViewmodel extends ChangeNotifier {
  final AddTaskRepository _addTaskRepository;

  TasksViewmodel(this._addTaskRepository);

  addtask(BuildContext context, Map<String, dynamic> task) async {
    final res = await _addTaskRepository.addTask();
  }
}
