import 'package:flutter/material.dart';
import 'package:markitdone/ui/screens/homescreen.dart';
import 'package:markitdone/ui/screens/schedule_screen.dart';

import 'package:markitdone/ui/widgets/bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Make this method accessible to child widgets
  void onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // List of screens to be displayed
  final List<Widget> _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    Scaffold(
        body: Center(
            child: Text('Notifications Coming Soon'))), // Temporary placeholder
    Scaffold(
        body:
            Center(child: Text('Search Coming Soon'))), // Temporary placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: onNavTap,
      ),
    );
  }
}
