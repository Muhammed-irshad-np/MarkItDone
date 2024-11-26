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
              child: CircularProgressIndicator(
                color: AppColors.primary,
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
                      color: AppColors.textSecondary,
                    ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index].data() as Map<String, dynamic>;
              return TaskCard(
                fromCompleted: true,
                title: task['title'] ?? 'Untitled Task',
                description: task['description'] ?? '',
                status: task['state'] ?? 'pending',
                dueDate: task['scheduledTime']?.toDate(),
                onTap: () {
                  // Handle task tap
                },
              );
            },
          );
        },
      ),
    );
  }
}
