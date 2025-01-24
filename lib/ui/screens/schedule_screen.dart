import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:markitdone/providers/view_models/tasks_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:markitdone/providers/navigation_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.darkbackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.darkbackground,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<NavigationProvider>().setIndex(0);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/main', (route) => false);
            },
          ),
          title: Text(
            'Schedule',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('alltasks')
              .where('isScheduled', isEqualTo: true)
              .where('createdBy',
                  isEqualTo: Provider.of<AuthViewModel>(context, listen: false)
                      .phoneNumber)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.darkprimary),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_note_rounded,
                      size: 64.sp,
                      color: AppColors.darktextSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No scheduled tasks',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.darktextSecondary,
                          ),
                    ),
                  ],
                ),
              );
            }

            final tasks = snapshot.data!.docs;
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index].data() as Map<String, dynamic>;
                final scheduledTime = task['scheduledTime'].toDate();

                if (index == 0 ||
                    _shouldShowDateHeader(tasks[index - 1], tasks[index])) {
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
                      _buildTaskItem(context, task, tasks[index].id),
                    ],
                  );
                }

                return _buildTaskItem(context, task, tasks[index].id);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTaskItem(
      BuildContext context, Map<String, dynamic> task, String taskId) {
    final isCompleted = task['state'] == 'completed';
    final scheduledTime = task['scheduledTime'].toDate();
    final isToday = _isToday(scheduledTime);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.darkprimary.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
          border: Border.all(
            color: isToday
                ? AppColors.darkprimary
                : AppColors.darkprimary.withOpacity(0.15),
            width: isToday ? 2 : 1,
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
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          task['title'] ?? 'Untitled Task',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darktextPrimary,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                        ),
                      ),
                    ],
                  ),
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
            if (task['description']?.isNotEmpty == true) ...[
              SizedBox(height: 4.h),
              Text(
                task['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darktextSecondary,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
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
                  Icons.calendar_today_outlined,
                  size: 14.sp,
                  color: isToday
                      ? AppColors.darkprimary
                      : AppColors.darktextSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Scheduled: ${_formatDateTime(scheduledTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isToday
                            ? AppColors.darkprimary
                            : AppColors.darktextSecondary,
                        fontSize: 12.sp,
                        fontWeight: isToday ? FontWeight.w600 : null,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDateTime(DateTime dateTime) {
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
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    hour = hour == 0 ? 12 : hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  bool _shouldShowDateHeader(
      DocumentSnapshot previous, DocumentSnapshot current) {
    final prevTask = previous.data() as Map<String, dynamic>;
    final currTask = current.data() as Map<String, dynamic>;

    final prevScheduledTime = prevTask['scheduledTime'].toDate();
    final currScheduledTime = currTask['scheduledTime'].toDate();

    return prevScheduledTime.year != currScheduledTime.year ||
        prevScheduledTime.month != currScheduledTime.month ||
        prevScheduledTime.day != currScheduledTime.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }
}
