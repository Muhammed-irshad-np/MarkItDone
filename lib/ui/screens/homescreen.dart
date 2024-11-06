import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:markitdone/ui/screens/task_creation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    final String? userId = _auth.currentUser?.uid;
    log(userId ?? "No user id found");

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search task',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2x2 Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  CategoryCard(
                    onTap: () {},
                    icon: Icons.person,
                    title: 'Personal',
                    color: Colors.blue,
                  ),
                  CategoryCard(
                    onTap: () {},
                    icon: Icons.assignment_ind,
                    title: 'Assigned',
                    color: Colors.green,
                  ),
                  CategoryCard(
                    onTap: () {},
                    icon: Icons.calendar_today,
                    title: 'Scheduled',
                    color: Colors.orange,
                  ),
                  CategoryCard(
                    onTap: () {},
                    icon: Icons.check_circle,
                    title: 'Completed',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 20,
                  child: CategoryCard(
                    onTap: () {
                      Navigator.pushNamed(context, '/createdTaskList');
                    },
                    icon: Icons.person,
                    title: 'User Tasks',
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigator.pushNamed(context, '/task');
          TaskCreationBottomSheet.show(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  void Function() onTap;

  CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
