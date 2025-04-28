import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/menu_screen.dart';
import 'screens/task_screen.dart';
import 'screens/task_group_screen.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize(); // Inicializamos awesome_notifications

  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/menu': (context) => MenuScreen(),
        '/task': (context) => TaskScreen(),
        '/taskGroup': (context) => TaskGroupScreen(),
      },
    );
  }
}
