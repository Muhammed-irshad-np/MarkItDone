import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:markitdone/providers/view_models/tasks_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:markitdone/ui/widgets/contact_picker_sheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskCreationBottomSheet extends StatefulWidget {
  const TaskCreationBottomSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darksurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
  void initState() {
    super.initState();
    // If you need to perform any additional initialization
  }

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
                title: Text('Contact Permission Required',
                    style: TextStyle(fontSize: 16.sp)),
                content: Text(
                    'This app needs contact permission to assign tasks to your contacts. '
                    'Please enable it in app settings.',
                    style: TextStyle(fontSize: 14.sp)),
                actions: [
                  TextButton(
                    child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: Text('Open Settings',
                        style: TextStyle(fontSize: 14.sp)),
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
    if (!await _handleContactPermission()) return;

    try {
      // Get all contacts
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      if (!mounted) return;

      // Show custom contact picker dialog
      final contact = await showModalBottomSheet<Contact>(
        context: context,
        backgroundColor: AppColors.darksurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) => ContactPickerSheet(contacts: contacts),
      );

      if (contact != null) {
        setState(() {
          _selectedContact = contact;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing contacts',
                style: TextStyle(fontSize: 14.sp)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onChipTap(String chipName) async {
    setState(() {
      // Toggle chip selection
      _selectedChip = _selectedChip == chipName ? null : chipName;
    });

    if (chipName == 'assign') {
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
            size: 16.sp,
            color: isSelected ? AppColors.textDark : AppColors.darktextPrimary,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color:
                  isSelected ? AppColors.textDark : AppColors.darktextPrimary,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) => _onChipTap(value),
      backgroundColor: AppColors.darksurface,
      selectedColor: AppColors.darkprimary,
      checkmarkColor: AppColors.textDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: isSelected ? AppColors.darkprimary : AppColors.cardBorder,
          width: 1.w,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  bool _validateTask() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_selectedChip == 'assign' && _selectedContact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select a contact to assign the task',
                style: TextStyle(fontSize: 14.sp))),
      );
      return false;
    }

    if (_selectedChip == 'schedule' && _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select a due date for the task',
                style: TextStyle(fontSize: 14.sp))),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TasksViewmodel>(context);

    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: AppColors.darkdivider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Task',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 24.sp),
              ),
              IconButton(
                icon: Icon(Icons.check, size: 24.sp),
                color: AppColors.darkprimary,
                onPressed: () async {
                  if (_validateTask()) {
                    try {
                      final authViewModel =
                          Provider.of<AuthViewModel>(context, listen: false);
                      final userPhone = authViewModel.phoneNumber;

                      // Determine assignedTo based on selected option
                      String assignedTo;
                      if (_selectedChip == 'personal') {
                        // For personal tasks, assignedTo is the same as createdBy
                        assignedTo = userPhone;
                      } else if (_selectedChip == 'assign' &&
                          _selectedContact != null) {
                        // For assigned tasks, use the selected contact's ID
                        assignedTo = _selectedContact!.phones.first.number
                            .replaceAll(' ', '');
                      } else {
                        // Default to user's phone number if no specific assignment
                        assignedTo = userPhone;
                      }

                      final finalvalue = await viewModel.addtask(
                        context,
                        assignedTo: assignedTo,
                        createdBy:
                            userPhone, // Always set to the current user's phone
                        isPostponed: _selectedChip == 'postpone',
                        scheduledTime: _dueDate ?? DateTime.now(),
                        isScheduled: _selectedChip == 'schedule',
                        state: "inProgress",
                        title: _titleController.text.trim(),
                      );

                      if (finalvalue) {
                        Navigator.pop(context, {
                          'title': _titleController.text.trim(),
                          'description': _descriptionController.text.trim(),
                          'dueDate': _dueDate,
                          'assignedTo': assignedTo,
                          'createdBy': userPhone,
                          'isPostponed': _selectedChip == 'postpone',
                        });
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error adding task: $e',
                                style: TextStyle(fontSize: 14.sp))),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  validator: _validateTitle,
                  decoration: InputDecoration(
                    hintText: 'What needs to be done?',
                    prefixIcon: Icon(
                      Icons.check_circle_outline,
                      color: AppColors.darktextSecondary,
                      size: 24.sp,
                    ),
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Task Options (Optional)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
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
      padding: EdgeInsets.only(top: 16.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: AppColors.darkprimary),
              SizedBox(width: 8.w),
              Text(
                text,
                style: TextStyle(
                    color: AppColors.darktextPrimary, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
