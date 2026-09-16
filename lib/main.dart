import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'services/theme_store.dart';
import 'theme/app_theme.dart';
import 'widgets/iphone_frame.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized(); await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); runApp(const GlassnikApp()); }

class GlassnikApp extends StatelessWidget {
  const GlassnikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeStore.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Glassnik',

          // Your existing dark theme.
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor:
                const Color(0xFFF5F5F7),
          ),

          darkTheme: AppTheme.darkTheme,

          // This now changes when the switch changes.
          themeMode: themeMode,

          home: const SplashScreen(),

          builder: (context, child) {
            return IPhoneFrame(
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
