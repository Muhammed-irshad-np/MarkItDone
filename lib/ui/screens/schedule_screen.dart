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
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_rounded,
                    size: 120,
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No scheduled events',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add tasks with dates to see them here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data!.docs;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Schedule',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = tasks[index];
                    final taskData = task.data() as Map<String, dynamic>;
                    final scheduledTime =
                        (taskData['scheduledTime'] as Timestamp).toDate();
                    final isToday = _isToday(scheduledTime);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isToday ? AppColors.primary : AppColors.border,
                            width: isToday ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            taskData['title'] ?? 'Untitled Task',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: taskData['state'] == 'completed'
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (taskData['description']?.isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  taskData['description'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: isToday
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDateTime(scheduledTime),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: isToday
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          fontWeight: isToday
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Checkbox(
                            value: taskData['state'] == 'completed',
                            onChanged: (bool? value) {
                              FirebaseFirestore.instance
                                  .collection('alltasks')
                                  .doc(task.id)
                                  .update({
                                'state': value! ? 'completed' : 'pending'
                              });
                            },
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: tasks.length,
                ),
              ),
            ],
          );
        },
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
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
