import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'views/home_view.dart';
import 'core/api/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService.loadConfig();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wondertale | Personalised AI Storybooks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeView(),
    );
  }
}
