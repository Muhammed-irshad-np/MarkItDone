import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:markitdone/data/repositories/user_repository.dart';
import 'package:markitdone/firebase_options.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:markitdone/ui/screens/auth_screen.dart';
import 'package:markitdone/ui/screens/register_and_permission_screen.dart';
import 'package:markitdone/ui/screens/task_creation.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthScreen(),
          '/register': (context) => const RegisterAndPermissionScreen(),
          '/task': (context) => const TaskCreationScreen(),
        },
      ),
    );
  }
}
