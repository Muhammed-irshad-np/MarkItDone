import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:markitdone/data/repositories/add_task_repository.dart';
import 'package:markitdone/data/repositories/user_repository.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:markitdone/providers/view_models/tasks_viewmodel.dart';
import 'package:markitdone/ui/screens/auth_screen.dart';
import 'package:markitdone/ui/screens/comleted_task_screen.dart';
import 'package:markitdone/ui/screens/created_task_screen.dart';
import 'package:markitdone/ui/screens/homescreen.dart';
import 'package:markitdone/ui/screens/main_screen.dart';
import 'package:markitdone/ui/screens/personal_task_screen.dart';
import 'package:markitdone/ui/screens/register_and_permission_screen.dart';
import 'package:markitdone/ui/screens/schedule_screen.dart';
import 'package:provider/provider.dart';
import 'package:markitdone/config/theme.dart';

import 'ui/screens/assigned_task_screen.dart';
import 'providers/navigation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AuthViewModel(UserRepository())),
        ChangeNotifierProvider(
            create: (context) => TasksViewmodel(AddTaskRepository())),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'MarkItDone',
        theme: lightTheme(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        darkTheme: appTheme(),
        themeMode: ThemeMode.system,
        routes: {
          '/': (context) => AuthScreen(),
          '/register': (context) => const RegisterAndPermissionScreen(),
          '/createdTaskList': (context) => const TaskListingScreen(),
          '/completedTaskList': (context) => const CompletedTaskScreen(),
          '/personalTaskList': (context) => const PersonalTaskScreen(),
          '/assignedTaskList': (context) => const AssignedTaskScreen(),
          '/scheduledTaskList': (context) => const ScheduleScreen(),
          '/main': (context) => const MainScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
