import 'package:flutter/material.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/iphone_frame.dart';

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

      // IMPORTANT:
      // Do not put HomeScreen here.
      home: const MainNavigationScreen(),

      builder: (context, child) {
        return IPhoneFrame(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
