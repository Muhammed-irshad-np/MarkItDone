import 'dart:developer';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/ui/screens/task_creation.dart';
import 'package:markitdone/ui/widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _notificationController;
  late Animation<Color?> _colorAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    final String? userId = _auth.currentUser?.uid;
    // log(userId ?? "No user id found");

    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: AppColors.textPrimary,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _notificationController,
      curve: Curves.easeInOut,
    ));

    _notificationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _notificationController.reverse();
        setState(() => _isAnimating = false);
      }
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'Task Manager',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: AnimatedBuilder(
              animation: _notificationController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: _colorAnimation.value,
                    ),
                  ],
                );
              },
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildCategoryCard(
                  context,
                  icon: Icons.person,
                  title: 'Personal',
                  subtitle: '5 tasks',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pushNamed(context, '/personalTaskList');
                  },
                ),
                _buildCategoryCard(
                  context,
                  icon: Icons.assignment_ind,
                  title: 'Assigned',
                  subtitle: '3 tasks',
                  color: AppColors.secondary,
                  onTap: () {},
                ),
                _buildCategoryCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Scheduled',
                  subtitle: '8 tasks',
                  color: AppColors.pending,
                  onTap: () {},
                ),
                _buildCategoryCard(
                  context,
                  icon: Icons.check_circle,
                  title: 'Completed',
                  subtitle: '12 tasks',
                  color: AppColors.completed,
                  onTap: () {
                    Navigator.pushNamed(context, '/completedTaskList');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Your Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildUserTasksCard(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => TaskCreationBottomSheet.show(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        elevation: 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return CategoryCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: color,
      onTap: onTap,
    );
  }

  Widget _buildUserTasksCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/createdTaskList'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Tasks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'View all your tasks',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap() {
    if (!_isAnimating) {
      setState(() => _isAnimating = true);
      _notificationController.forward();
    }
  }

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }
}

class SparklesPainter extends CustomPainter {
  final double progress;
  final Color color;

  SparklesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(1 - progress)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * progress;

    for (var i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (progress * pi);
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(SparklesPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
