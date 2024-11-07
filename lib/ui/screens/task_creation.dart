import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:markitdone/providers/view_models/tasks_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class TaskCreationBottomSheet extends StatefulWidget {
  const TaskCreationBottomSheet({super.key, required this.phNumberController});
  final String phNumberController;

  static Future<Map<String, dynamic>?> show(BuildContext context,
      {required String phNumberController}) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TaskCreationBottomSheet(phNumberController: phNumberController),
      ),
    );
  }

  @override
  State<TaskCreationBottomSheet> createState() =>
      _TaskCreationBottomSheetState();
}

class _TaskCreationBottomSheetState extends State<TaskCreationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _filterValueData = <String>{'personal'};
  DateTime? _scheduleTime;
  // String? _selectedChip;
  Contact? _selectedContact;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduleTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _scheduleTime) {
      setState(() {
        _scheduleTime = picked;
      });
    }
  }

  Future<bool> _handleContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;

    if (permission != PermissionStatus.granted) {
      permission = await Permission.contacts.request();
      if (permission != PermissionStatus.granted) {
        // Show settings dialog if permission permanently denied
        if (permission == PermissionStatus.permanentlyDenied) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Contact Permission Required'),
                content: const Text(
                    'This app needs contact permission to assign tasks to your contacts. '
                    'Please enable it in app settings.'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text('Open Settings'),
                    onPressed: () {
                      openAppSettings();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
        }
        return false;
      }
    }
    return true;
  }

  Future<void> _pickContact() async {
    try {
      bool hasPermission = await _handleContactPermission();
      if (!hasPermission) {
        return;
      }

      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        setState(() {
          _selectedContact = contact;
        });
      }
    } catch (e) {
      print('Error picking contact: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing contacts: $e'),
          ),
        );
      }
    }
  }

  // void _onChipTap(String chipName) async {
  //   print('Chip tapped: $chipName');
  //   setState(() {
  //     _selectedChip = chipName;
  //   });

  //   if (chipName == 'assign') {
  //     print('Attempting to pick contact');
  //     await _pickContact();
  //   } else if (chipName == 'schedule') {
  //     await _selectDate(context);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TasksViewmodel>(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final task = {
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'dueDate': _scheduleTime,
                    };
                    try {
                      // Map<String, dynamic> task = {
                      //   // Updated collection name
                      //   'title': _titleController.text,
                      //   'assignedTo': "",
                      //   'createdBy': "",
                      //   'scheduledTime':
                      //       Timestamp.fromDate(_dueDate ?? DateTime.now()),
                      //   'state': "inProgress",
                      //   'isPostponed': true,
                      //   'createdAt': FieldValue.serverTimestamp(),
                      //   'updatedAt': FieldValue.serverTimestamp(),
                      // };
                      final finalvalue = await viewModel.addtask(
                        context,
                        assignedTo: _filterValueData.contains('assign')
                            ? _selectedContact!.phones[0].normalizedNumber
                                .replaceFirst('+1', '')
                            : widget.phNumberController,
                        createdBy: widget.phNumberController,
                        isPostponed: _filterValueData.contains('postpone')
                            ? true
                            : false,
                        scheduledTime: _scheduleTime ?? DateTime.now(),
                        state: "inProgress",
                        title: _titleController.text,
                      );
                      if (finalvalue) {
                        Navigator.pop(context, task);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding task: $e')),
                      );
                      return;
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter task',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task';
                    }
                    return null;
                  },
                ),
                if (_filterValueData.contains('schedule') &&
                    _scheduleTime != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${_scheduleTime!.day}/${_scheduleTime!.month}/${_scheduleTime!.year}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_filterValueData.contains('assign') &&
                    _selectedContact != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickContact,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _selectedContact!.displayName,
                            // _selectedContact!.phones[0].normalizedNumber
                            //     .replaceFirst('+1', ''),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                FilterChip(
                  label: const Text('Personal'),
                  // selected: _selectedChip == 'personal',
                  selected: _filterValueData.contains('personal'),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _filterValueData.add('personal');
                        if (_filterValueData.contains('assign')) {
                          _filterValueData.remove('assign');
                        }
                      } else {
                        _filterValueData.remove('personal');

                        if (!_filterValueData.contains('assign') &&
                            !_filterValueData.contains('personal')) {
                          _filterValueData.add('personal');
                        }
                      }
                      // _selectedChip = selected ? 'personal' : null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Postpone'),
                  // selected: _selectedChip == 'postpone',
                  selected: _filterValueData.contains('postpone'),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _filterValueData.add('postpone');
                        if (_filterValueData.contains('schedule')) {
                          _filterValueData.remove('schedule');
                        }
                      } else {
                        _filterValueData.remove('postpone');
                      }
                      // _selectedChip = selected ? 'postpone' : null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Assign to'),
                  // selected: _selectedChip == 'assign',
                  selected: _filterValueData.contains('assign'),
                  onSelected: (bool selected) async {
                    setState(() {
                      if (selected) {
                        _filterValueData.add('assign');
                        if (_filterValueData.contains('personal')) {
                          _filterValueData.remove('personal');
                        }
                      } else {
                        _filterValueData.remove('assign');

                        _selectedContact = null;
                        if (!_filterValueData.contains('assign') &&
                            !_filterValueData.contains('personal')) {
                          _filterValueData.add('personal');
                        }
                      }
                      // _selectedChip = selected ? 'assign' : null;
                    });
                    if (selected) {
                      await _pickContact();
                    }
                  },
                ),
                FilterChip(
                  label: const Text('Schedule'),
                  // selected: _selectedChip == 'schedule',
                  selected: _filterValueData.contains('schedule'),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _filterValueData.add('schedule');
                        if (_filterValueData.contains('postpone')) {
                          _filterValueData.remove('postpone');
                        }
                      } else {
                        _filterValueData.remove('schedule');
                      }
                      // _selectedChip = selected ? 'schedule' : null;
                      if (selected) {
                        _selectDate(context);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
