import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class PersonalTaskScreen extends StatelessWidget {
  const PersonalTaskScreen({super.key});

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
          'Personal Tasks',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getTasks(userPhone),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.darkprimary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            );
          }

          final tasks = snapshot.data?.docs ?? [];
          final filteredTasks = tasks.where((task) {
            final data = task.data() as Map<String, dynamic>;
            return data['state'] != 'completed';
          }).toList();

          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_outlined,
                    size: 64.sp,
                    color: AppColors.darktextSecondary.withOpacity(0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No personal tasks yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.darktextSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index].data() as Map<String, dynamic>;
              final scheduledTime = task['scheduledTime']?.toDate();

              if (index == 0 ||
                  _shouldShowDateHeader(
                      filteredTasks[index - 1], filteredTasks[index])) {
                return Column(
                  children: [
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
                    _buildTaskItem(context, task, filteredTasks[index].id),
                  ],
                );
              }

              return _buildTaskItem(context, task, filteredTasks[index].id);
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

  String _formatDateHeader(DateTime? date) {
    if (date == null) return 'No date';

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

  Widget _buildTaskItem(
      BuildContext context, Map<String, dynamic> task, String taskId) {
    final isCompleted = task['state'] == 'completed';
    final isScheduled = task['isScheduled'] ?? false;
    final DateTime timeToShow = isScheduled
        ? task['scheduledTime'].toDate()
        : task['createdAt']?.toDate() ?? DateTime.now();

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.darkprimary.withOpacity(0.2)
              : AppColors.darkprimary.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
          ),
          border: Border.all(
            color: AppColors.darkprimary.withOpacity(0.15),
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: Transform.scale(
                          scale: 0.9,
                          child: Checkbox(
                            value: isCompleted,
                            onChanged: (bool? value) {
                              FirebaseFirestore.instance
                                  .collection('alltasks')
                                  .doc(taskId)
                                  .update({
                                'state': value! ? 'completed' : 'pending'
                              });
                            },
                            activeColor: AppColors.darkprimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            side: BorderSide(
                              color: AppColors.darkprimary.withOpacity(0.5),
                              width: 1.5.w,
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
                              task['title'] ?? 'Untitled Task',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darktextPrimary,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                            if (isScheduled)
                              Container(
                                margin: EdgeInsets.only(top: 2.h),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.darkprimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'Scheduled',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.darkprimary,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_add_outlined),
                      iconSize: 20.sp,
                      color: AppColors.darktextSecondary,
                      onPressed: () => _showAssignDialog(context, taskId),
                      tooltip: 'Assign task',
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.darkprimary.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        isCompleted ? 'Completed' : 'Pending',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isCompleted
                                  ? AppColors.darkprimary
                                  : AppColors.warning,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (task['description']?.isNotEmpty == true) ...[
              SizedBox(height: 4.h),
              Text(
                task['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darktextSecondary,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isScheduled
                      ? Icons.calendar_today_outlined
                      : Icons.access_time,
                  size: 14.sp,
                  color: AppColors.darktextSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  isScheduled
                      ? 'Scheduled: ${_formatTime(timeToShow)}'
                      : 'Created: ${_formatTime(timeToShow)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.darktextSecondary,
                        fontSize: 12.sp,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'No date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow at ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showAssignDialog(BuildContext context, String taskId) async {
    try {
      bool hasPermission = await _handleContactPermission(context);
      if (!hasPermission) return;

      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        // Get phone number
        final phone = contact.phones.first.number.replaceAll(' ', '');

        // Update task in Firestore
        await FirebaseFirestore.instance
            .collection('alltasks')
            .doc(taskId)
            .update({
          'assignedto': phone,
          'assigneeName': contact.displayName,
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task assigned to ${contact.displayName}'),
              backgroundColor: AppColors.darkprimary,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error assigning task'),
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

Stream<QuerySnapshot> getTasks(String userPhone) {
  return FirebaseFirestore.instance
      .collection('alltasks')
      .where('createdBy', isEqualTo: userPhone)
      .where('assignedto', isEqualTo: userPhone)
      .snapshots();
}
