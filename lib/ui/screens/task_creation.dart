import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/providers/view_models/tasks_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class TaskCreationBottomSheet extends StatefulWidget {
  const TaskCreationBottomSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

  Widget _buildChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedChip == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.textLight : AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) async {
        _onChipTap(selected ? value : '');
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.cardBorder,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TasksViewmodel>(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Task',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              IconButton(
                icon: const Icon(Icons.check),
                color: AppColors.primary,
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
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'What needs to be done?',
                    prefixIcon: Icon(
                      Icons.check_circle_outline,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  'Task Options',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(
                      label: 'Personal',
                      value: 'personal',
                      icon: Icons.person_outline,
                    ),
                    _buildChip(
                      label: 'Schedule',
                      value: 'schedule',
                      icon: Icons.calendar_today_outlined,
                    ),
                    _buildChip(
                      label: 'Assign',
                      value: 'assign',
                      icon: Icons.group_outlined,
                    ),
                    _buildChip(
                      label: 'Postpone',
                      value: 'postpone',
                      icon: Icons.timer_outlined,
                    ),
                  ],
                ),
                if (_selectedChip == 'schedule' && _dueDate != null)
                  _buildSelectedOption(
                    icon: Icons.calendar_today_outlined,
                    text: DateFormat('MMM d, y').format(_dueDate!),
                    onTap: () => _selectDate(context),
                  ),
                if (_selectedChip == 'assign' && _selectedContact != null)
                  _buildSelectedOption(
                    icon: Icons.person_outline,
                    text: _selectedContact!.displayName,
                    onTap: _pickContact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
