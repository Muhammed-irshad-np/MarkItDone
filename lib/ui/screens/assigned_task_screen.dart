import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:markitdone/ui/widgets/contact_picker_sheet.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssignedTaskScreen extends StatelessWidget {
  const AssignedTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userPhone =
        Provider.of<AuthViewModel>(context, listen: false).phoneNumber;

    return Scaffold(
      backgroundColor: AppColors.darkbackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.darkbackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.darktextPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Assign Tasks',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alltasks')
            .where('createdBy', isEqualTo: userPhone)
            .where('assignedto', isNotEqualTo: userPhone)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64.sp,
                    color: AppColors.darktextSecondary.withOpacity(0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No assigned tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.darktextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final taskData = tasks[index].data() as Map<String, dynamic>;
              final assigneeName = taskData['assigneeName'] ?? 'Unknown User';
              final isCompleted = taskData['state'] == 'completed';
              final scheduledTime =
                  (taskData['scheduledTime'] as Timestamp).toDate();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0 ||
                      _shouldShowDateHeader(
                          tasks[index - 1], tasks[index])) ...[
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 16.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.darkprimary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          _formatDateHeader(scheduledTime),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.darkprimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ),
                  ],
                  Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: Transform.scale(
                            scale: 0.9,
                            child: Checkbox(
                              value: isCompleted,
                              onChanged: (bool? value) async {
                                if (value != null) {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('alltasks')
                                        .doc(tasks[index].id)
                                        .update({
                                      'state': value ? 'completed' : 'pending'
                                    });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Error updating task status'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                              activeColor: AppColors.darkprimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              side: BorderSide(
                                color: AppColors.darkprimary.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                taskData['title'] ?? 'Untitled Task',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darktextPrimary,
                                    ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14.sp,
                                    color: AppColors.darktextSecondary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _formatTime(scheduledTime),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.darktextSecondary,
                                          fontSize: 12.sp,
                                        ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? AppColors.darkprimary
                                              .withOpacity(0.1)
                                          : AppColors.warning.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      isCompleted ? 'Completed' : 'Pending',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isCompleted
                                                ? AppColors.darkprimary
                                                : AppColors.warning,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11.sp,
                                          ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  IconButton(
                                    icon: Icon(Icons.person_add_alt_1,
                                        size: 20.sp,
                                        color: AppColors.darktextSecondary),
                                    onPressed: () {
                                      _showReassignDialog(context,
                                          tasks[index].id, assigneeName);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: Colors.white,
                              child: Text(
                                assigneeName[0].toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.darkprimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              assigneeName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.darktextSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  bool _shouldShowDateHeader(
      DocumentSnapshot previous, DocumentSnapshot current) {
    final previousData = previous.data() as Map<String, dynamic>;
    final currentData = current.data() as Map<String, dynamic>;

    final previousDate = (previousData['scheduledTime'] as Timestamp).toDate();
    final currentDate = (currentData['scheduledTime'] as Timestamp).toDate();

    return !isSameDay(previousDate, currentDate);
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showReassignDialog(
      BuildContext context, String taskId, String currentAssignee) async {
    try {
      bool hasPermission = await _handleContactPermission(context);
      if (!hasPermission) return;

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      if (!context.mounted) return;

      final selectedContact = await showModalBottomSheet<Contact>(
        context: context,
        backgroundColor: AppColors.darksurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) => ContactPickerSheet(contacts: contacts),
      );

      if (selectedContact != null && context.mounted) {
        final phone = selectedContact.phones.first.number.replaceAll(' ', '');

        await FirebaseFirestore.instance
            .collection('alltasks')
            .doc(taskId)
            .update({
          'assignedto': phone,
          'assigneeName': selectedContact.displayName,
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Task reassigned from $currentAssignee to ${selectedContact.displayName}'),
              backgroundColor: AppColors.darkprimary,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error reassigning task'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool> _handleContactPermission(BuildContext context) async {
    PermissionStatus permission = await Permission.contacts.status;

    if (permission != PermissionStatus.granted) {
      permission = await Permission.contacts.request();
      if (permission != PermissionStatus.granted) {
        if (permission == PermissionStatus.permanentlyDenied &&
            context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Contact Permission Required'),
              content: const Text(
                  'This app needs contact permission to assign tasks. '
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
        return false;
      }
    }
    return true;
  }
}
