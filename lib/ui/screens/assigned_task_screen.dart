import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class AssignedTaskScreen extends StatelessWidget {
  const AssignedTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned task '),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alltasks')
            .where('assignedto',
                isEqualTo: Provider.of<AuthViewModel>(context).phoneNumber)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading tasks.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks available.'));
          }

          // Display the list of tasks
          final tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskName = task['title'] ?? 'Unnamed Task';
              final taskStatus = task['state'] ?? 'Status not set';
              final taskAssignedTo = task['assignedto'] ?? "";
              final taskCreatedBy = task['createdBy'] ?? "";

              return ListTile(
                title: Text(taskName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: $taskStatus'),
                    Text('Assigned To: $taskAssignedTo'),
                    Text('CreatedBy: $taskCreatedBy')
                  ],
                ),
                onTap: () {
                  // Handle task tap, e.g., view task details or edit
                },
              );
            },
          );
        },
      ),
    );
  }
}
