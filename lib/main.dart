import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/screens/assigned_task_screen.dart';
import 'providers/navigation_provider.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/pricing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  await _initializeFirebase();
  runApp(MyApp(initialRoute: '/onboarding'));
  // onboardingCompleted ? '/auth' : '/onboarding'
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
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 919),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => AuthViewModel(UserRepository())),
          ChangeNotifierProvider(
              create: (context) => TasksViewmodel(AddTaskRepository())),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ],
        child: MaterialApp(
          title: 'MarkItDone',
          theme: appTheme(),
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/pricing': (context) => const PricingScreen(),
            '/auth': (context) => const AuthScreen(),
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
      ),
    );
  }
}
