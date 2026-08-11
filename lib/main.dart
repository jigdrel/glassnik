import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GlassnikApp());
}

class GlassnikApp extends StatelessWidget {
  const GlassnikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glassnik',
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}