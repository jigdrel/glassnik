import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) {
          return;
        }

        // If a session already exists (user signed in during a
        // previous app run and never logged out), skip straight
        // past LoginScreen instead of making them sign in again.
        final isSignedIn = AuthService().currentUser != null;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isSignedIn
                ? const MainNavigationScreen()
                : const LoginScreen(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
            ),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                Container(
                  width: 100,
                  height: 100,

                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF6C63FF,
                    ).withValues(
                      alpha: 0.15,
                    ),

                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.play_circle_fill,
                    size: 70,
                    color: Color(
                      0xFF6C63FF,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                const Text(
                  'GLASSNIK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  'Create. Share. Discover.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 45,
                ),

                const SizedBox(
                  width: 28,
                  height: 28,

                  child:
                      CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(
                      0xFF6C63FF,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}