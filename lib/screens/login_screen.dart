import 'package:flutter/material.dart';

import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _signIn() async {
    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email and password.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Small delay to simulate login for demo.
    await Future.delayed(
      const Duration(
        milliseconds: 700,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    // IMPORTANT:
    // Login goes to MainNavigationScreen,
    // NOT directly to HomeScreen.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const MainNavigationScreen(),
      ),
      (route) => false,
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Password recovery will be connected with authentication later.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            50,
            24,
            30,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              const Icon(
                Icons.play_circle_fill,
                size: 70,
                color: Color(
                  0xFF6C63FF,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'Welcome to Glassnik',
                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Sign in to continue',
                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(
                height: 38,
              ),

              // EMAIL
              TextField(
                controller:
                    _emailController,

                keyboardType:
                    TextInputType.emailAddress,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    InputDecoration(
                  labelText: 'Email',
                  hintText:
                      'you@example.com',

                  prefixIcon:
                      const Icon(
                    Icons.email_outlined,
                    color:
                        Color(
                      0xFF6C63FF,
                    ),
                  ),

                  labelStyle:
                      const TextStyle(
                    color: Colors.grey,
                  ),

                  hintStyle:
                      const TextStyle(
                    color:
                        Colors.white30,
                  ),

                  filled: true,

                  fillColor:
                      const Color(
                    0xFF1C1C1C,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),

                    borderSide:
                        const BorderSide(
                      color:
                          Colors.white12,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),

                    borderSide:
                        const BorderSide(
                      color:
                          Color(
                        0xFF6C63FF,
                      ),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // PASSWORD
              TextField(
                controller:
                    _passwordController,

                obscureText:
                    _obscurePassword,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    InputDecoration(
                  labelText: 'Password',

                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                    color:
                        Color(
                      0xFF6C63FF,
                    ),
                  ),

                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },

                    icon: Icon(
                      _obscurePassword
                          ? Icons
                              .visibility_outlined
                          : Icons
                              .visibility_off_outlined,

                      color: Colors.grey,
                    ),
                  ),

                  labelStyle:
                      const TextStyle(
                    color: Colors.grey,
                  ),

                  filled: true,

                  fillColor:
                      const Color(
                    0xFF1C1C1C,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),

                    borderSide:
                        const BorderSide(
                      color:
                          Colors.white12,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),

                    borderSide:
                        const BorderSide(
                      color:
                          Color(
                        0xFF6C63FF,
                      ),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Align(
                alignment:
                    Alignment.centerRight,

                child: TextButton(
                  onPressed:
                      _forgotPassword,

                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color:
                          Color(
                        0xFF6C63FF,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // SIGN IN
              SizedBox(
                height: 52,

                child:
                    ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _signIn,

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF6C63FF,
                    ),

                    foregroundColor:
                        Colors.white,

                    disabledBackgroundColor:
                        const Color(
                      0xFF6C63FF,
                    ).withValues(
                      alpha: 0.5,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),

                  child:
                      _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,

                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In',

                              style:
                                  TextStyle(
                                fontSize:
                                    16,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              const Text(
                'Demo authentication',
                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
