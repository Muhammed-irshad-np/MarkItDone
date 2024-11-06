import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:markitdone/providers/view_models/tasks_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class TaskCreationBottomSheet extends StatefulWidget {
  const TaskCreationBottomSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const TaskCreationBottomSheet(),
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
  DateTime? _dueDate;
  String? _selectedChip;
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
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
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

  void _onChipTap(String chipName) async {
    print('Chip tapped: $chipName');
    setState(() {
      _selectedChip = chipName;
    });

    if (chipName == 'assign') {
      print('Attempting to pick contact');
      await _pickContact();
    } else if (chipName == 'schedule') {
      await _selectDate(context);
    }
  }

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
                      'dueDate': _dueDate,
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
                        assignedTo: "",
                        createdBy: "",
                        isPostponed: true,
                        scheduledTime: DateTime.now(),
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
                if (_selectedChip == 'schedule' && _dueDate != null) ...[
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
                            '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_selectedChip == 'assign' && _selectedContact != null) ...[
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
                  selected: _selectedChip == 'personal',
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedChip = selected ? 'personal' : null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Postpone'),
                  selected: _selectedChip == 'postpone',
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedChip = selected ? 'postpone' : null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Assign to'),
                  selected: _selectedChip == 'assign',
                  onSelected: (bool selected) async {
                    setState(() {
                      _selectedChip = selected ? 'assign' : null;
                    });
                    if (selected) {
                      await _pickContact();
                    }
                  },
                ),
                FilterChip(
                  label: const Text('Schedule'),
                  selected: _selectedChip == 'schedule',
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedChip = selected ? 'schedule' : null;
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
