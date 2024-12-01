import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/ui/widgets/task_card.dart';

class CompletedTaskScreen extends StatelessWidget {
  const CompletedTaskScreen({super.key});

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
          'Completed Tasks',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alltasks')
            .where('state', isEqualTo: 'completed')
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
                    Icons.task_outlined,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No completed tasks yet',
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
              final isScheduled = task['isScheduled'] ?? false;
              final scheduledTime = task['scheduledTime']?.toDate();
              final createdTime = task['createdAt']?.toDate() ?? DateTime.now();

              if (index == 0 ||
                  _shouldShowDateHeader(tasks[index - 1], tasks[index])) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          _formatDateHeader(
                              isScheduled ? scheduledTime : createdTime),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ),
                    _buildTaskItem(context, task),
                  ],
                );
              }

              return _buildTaskItem(context, task);
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task) {
    final isScheduled = task['isScheduled'] ?? false;
    final timeToShow = isScheduled
        ? task['scheduledTime'].toDate()
        : task['createdAt']?.toDate() ?? DateTime.now();

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task['title'] ?? 'Untitled Task',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
            if (task['description']?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  task['description'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 28),
                Icon(
                  isScheduled
                      ? Icons.calendar_today_outlined
                      : Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  isScheduled
                      ? 'Completed at ${_formatTime(timeToShow)}'
                      : 'Completed at ${_formatTime(timeToShow)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDateHeader(
      DocumentSnapshot previous, DocumentSnapshot current) {
    final previousData = previous.data() as Map<String, dynamic>;
    final currentData = current.data() as Map<String, dynamic>;

    final previousIsScheduled = previousData['isScheduled'] ?? false;
    final currentIsScheduled = currentData['isScheduled'] ?? false;

    final previousDate = previousIsScheduled
        ? previousData['scheduledTime']?.toDate()
        : previousData['createdAt']?.toDate();
    final currentDate = currentIsScheduled
        ? currentData['scheduledTime']?.toDate()
        : currentData['createdAt']?.toDate();

    if (previousDate == null || currentDate == null) return false;
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
