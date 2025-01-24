import 'dart:developer';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/providers/view_models/tasks_viewmodel.dart';
import 'package:markitdone/ui/screens/task_creation.dart';
import 'package:markitdone/ui/widgets/category_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:markitdone/ui/widgets/task_card.dart';
import 'package:provider/provider.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: AppColors.darktextPrimary,
      end: Colors.red,
    ).animate(_notificationController);
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
              Provider.of<AuthViewModel>(context, listen: false).reset();
              Provider.of<TasksViewmodel>(context, listen: false).reset();
              await _auth.signOut();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/auth', (route) => false);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      Provider.of<AuthViewModel>(context, listen: false).reset();
      Provider.of<TasksViewmodel>(context, listen: false).reset();
      await _auth.signOut();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (ctx, result) async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: Text('Logout'),
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          Provider.of<AuthViewModel>(context, listen: false).reset();
          Provider.of<TasksViewmodel>(context, listen: false).reset();
          await _auth.signOut();
          if (context.mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false);
          }
          // return false;
        }
        // return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.darkbackground,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      _buildTaskOverview(context),
                      SizedBox(height: 24.h),
                      _buildTaskCategories(context),
                      _buildRecentlyAssignedTasksDummy(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.darkbackground,
      title: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          return Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.darkprimary.withOpacity(0.1),
                child: Text(
                  authVM.name.isNotEmpty ? authVM.name[0].toUpperCase() : 'U',
                  style: TextStyle(color: AppColors.darkprimary),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darktextSecondary,
                        ),
                  ),
                  Text(
                    authVM.name.isNotEmpty ? authVM.name : 'User',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: AppColors.darktextPrimary,
          ),
          color: AppColors.darksurface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          onSelected: (value) async {
            if (value == 'logout') {
              await _handleLogout(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: AppColors.error,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskOverview(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('alltasks')
          .where('assignedto', isEqualTo: _auth.currentUser?.phoneNumber)
          .snapshots(),
      builder: (context, snapshot) {
        int totalTasks = snapshot.data?.docs.length ?? 0;
        int completedTasks = snapshot.data?.docs
                .where((doc) =>
                    (doc.data() as Map<String, dynamic>)['state'] ==
                    'completed')
                .length ??
            0;
        int pendingTasks = totalTasks - completedTasks;

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.darkprimary,
                AppColors.darkprimary.withOpacity(0.8)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/createdTaskList'),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAnalyticItem(
                    context,
                    icon: Icons.task_alt,
                    value: totalTasks.toString(),
                    label: 'Total',
                  ),
                  _buildAnalyticItem(
                    context,
                    icon: Icons.pending_actions,
                    value: pendingTasks.toString(),
                    label: 'Pending',
                    color: AppColors.pending,
                  ),
                  _buildAnalyticItem(
                    context,
                    icon: Icons.check_circle_outline,
                    value: completedTasks.toString(),
                    label: 'Completed',
                    color: AppColors.completed,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.white, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
        ),
      ],
    );
  }

  Widget _buildTaskCategories(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('alltasks').snapshots(),
      builder: (context, snapshot) {
        int selfTasks = snapshot.data?.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['createdBy'] == _auth.currentUser?.phoneNumber &&
                  data['assignedto'] == _auth.currentUser?.phoneNumber &&
                  data['state'] != 'completed';
            }).length ??
            0;

        int assignedTasks = snapshot.data?.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['createdBy'] == _auth.currentUser?.phoneNumber &&
                  data['assignedto'] != _auth.currentUser?.phoneNumber &&
                  data['state'] != 'completed';
            }).length ??
            0;

        int scheduledTasks = snapshot.data?.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isScheduled'] == true &&
                  data['state'] != 'completed';
            }).length ??
            0;

        int completedTasks = snapshot.data?.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['state'] == 'completed';
            }).length ??
            0;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 1.1,
          children: [
            _buildCategoryCard(
              context,
              icon: Icons.person_outline,
              title: 'Self Tasks',
              subtitle: 'Personal tasks',
              count: selfTasks,
              color: AppColors.accent1,
              onTap: () => Navigator.pushNamed(context, '/personalTaskList'),
            ),
            _buildCategoryCard(
              context,
              icon: Icons.group_add_outlined,
              title: 'Assigned Tasks',
              subtitle: 'Tasks for others',
              count: assignedTasks,
              color: AppColors.accent2,
              onTap: () => Navigator.pushNamed(context, '/assignedTaskList'),
            ),
            _buildCategoryCard(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Scheduled',
              subtitle: 'Upcoming tasks',
              count: scheduledTasks,
              color: AppColors.accent3,
              onTap: () => Navigator.pushNamed(context, '/scheduledTaskList'),
            ),
            _buildCategoryCard(
              context,
              icon: Icons.check_circle_outline,
              title: 'Completed',
              subtitle: 'Finished tasks',
              count: completedTasks,
              color: AppColors.accent4,
              onTap: () => Navigator.pushNamed(context, '/completedTaskList'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int count,
    VoidCallback? onTap,
  }) {
    return CategoryCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: color,
      count: count,
      onTap: onTap,
    );
  }

  Widget _buildRecentlyAssignedTasksDummy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darksurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Task Activities',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.darktextPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/taskHistory');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.darkprimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14.sp,
                            color: AppColors.darkprimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
                child: Text(
                  'Tasks shared with you and by you',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darktextSecondary,
                      ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (context, index) {
                  String personName = 'Person ${index + 1}';
                  String taskTitle = 'Task Title ${index + 1}';
                  String dateTime = '9:50 AM';

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.darksurface,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12.w),
                        leading: CircleAvatar(
                          radius: 24.r,
                          backgroundColor:
                              AppColors.darkprimary.withOpacity(0.15),
                          child: Text(
                            personName[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.darkprimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        title: Text(
                          personName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.darktextPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            taskTitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.darktextSecondary,
                                ),
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkprimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            dateTime,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.darkprimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                        onTap: () {
                          // Placeholder for tap action
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
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
