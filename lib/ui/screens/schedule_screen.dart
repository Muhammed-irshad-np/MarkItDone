import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
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
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_rounded,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scheduled tasks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDateHeader(scheduledTime),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: isToday
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.15),
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
                        width: 24,
                        height: 24,
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
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: BorderSide(
                              color: AppColors.primary.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task['title'] ?? 'Untitled Task',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.warning,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
            if (task['description']?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                task['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: isToday ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Scheduled: ${_formatDateTime(scheduledTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isToday
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 12,
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
