import 'package:flutter/material.dart';
import 'package:task_manager/config/app_router.dart';
import 'package:task_manager/core/services/NetworkSyncService.dart';
import 'package:task_manager/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  di.sl<NetworkSyncService>().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
