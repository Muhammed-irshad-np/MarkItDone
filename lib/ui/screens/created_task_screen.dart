import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/ui/widgets/task_card.dart';

class TaskListingScreen extends StatelessWidget {
  const TaskListingScreen({Key? key}) : super(key: key);

  // Add helper method to format dates
  String _formatDate(DateTime date) {
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

  // Add method to group tasks by date
  Map<String, List<QueryDocumentSnapshot>> _groupTasksByDate(
      List<QueryDocumentSnapshot> tasks) {
    final groupedTasks = <String, List<QueryDocumentSnapshot>>{};

    for (var task in tasks) {
      final data = task.data() as Map<String, dynamic>;
      final date = (data['scheduledTime'] as Timestamp).toDate();
      final dateString = _formatDate(date);

      if (!groupedTasks.containsKey(dateString)) {
        groupedTasks[dateString] = [];
      }
      groupedTasks[dateString]!.add(task);
    }

    return groupedTasks;
  }

  @override
  Widget build(BuildContext context) {
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
          'My Tasks',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle done action
            },
            child: const Text(
              'Done',
              style: TextStyle(color: AppColors.darkprimary),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alltasks')
            .orderBy('scheduledTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.darkprimary,
              ),
            );
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

          if (tasks.isEmpty) {
            return Center(
              child: Text(
                'No tasks yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.darktextSecondary,
                    ),
              ),
            );
          }

          final groupedTasks = _groupTasksByDate(tasks);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedTasks.length,
            itemBuilder: (context, index) {
              final date = groupedTasks.keys.elementAt(index);
              final tasksForDate = groupedTasks[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header with improved styling
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.darkprimary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          date,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.darkprimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  // Tasks for this date
                  ...tasksForDate.map((task) {
                    final taskData = task.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          // Handle task tap if needed
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              // Custom Checkbox
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Transform.scale(
                                  scale: 0.9,
                                  child: Checkbox(
                                    value: taskData['state'] == 'completed',
                                    onChanged: (bool? value) {
                                      FirebaseFirestore.instance
                                          .collection('alltasks')
                                          .doc(task.id)
                                          .update({
                                        'state':
                                            value! ? 'completed' : 'pending'
                                      });
                                    },
                                    activeColor: AppColors.darkprimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    side: BorderSide(
                                      color: AppColors.darkprimary
                                          .withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Task Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      taskData['title'] ?? 'Untitled Task',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            decoration:
                                                taskData['state'] == 'completed'
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                            color: taskData['state'] ==
                                                    'completed'
                                                ? AppColors.darktextSecondary
                                                : AppColors.darktextPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    if (taskData['description']?.isNotEmpty ==
                                        true) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        taskData['description'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  AppColors.darktextSecondary,
                                              fontSize: 14,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Time indicator
                              Text(
                                _formatTime(taskData['scheduledTime'].toDate()),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.darktextSecondary,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Add this helper method for time formatting
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
