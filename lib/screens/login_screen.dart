import 'package:flutter/material.dart';

import 'main_navigation_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // EMAIL VALIDATION
  // -------------------------------------------------------

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // -------------------------------------------------------
  // PASSWORD VALIDATION
  // -------------------------------------------------------

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter your password';
    }

    if (password.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    return null;
  }

  // -------------------------------------------------------
  // SIGN IN
  // -------------------------------------------------------

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      /*
       * TEMPORARY LOGIN
       *
       * This currently validates the form only.
       *
       * In the next step this will be replaced with:
       *
       * FirebaseAuth.instance.signInWithEmailAndPassword(
       *   email: _emailController.text.trim(),
       *   password: _passwordController.text,
       * );
       *
       * Do NOT consider this real authentication yet.
       */

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign in. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // -------------------------------------------------------
  // FORGOT PASSWORD
  // -------------------------------------------------------

  void _forgotPassword() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email first to reset your password.'),
        ),
      );

      return;
    }

    final emailError = _validateEmail(email);

    if (emailError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(emailError)));

      return;
    }

    /*
     * TODO:
     *
     * When Firebase Authentication is connected:
     *
     * FirebaseAuth.instance.sendPasswordResetEmail(
     *   email: email,
     * );
     */

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password recovery will be connected with Firebase Authentication.',
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // CREATE ACCOUNT
  // -------------------------------------------------------

  void _openCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  // -------------------------------------------------------
  // INPUT DESIGN
  // -------------------------------------------------------

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),

      suffixIcon: suffixIcon,

      labelStyle: const TextStyle(color: Colors.grey),

      hintStyle: const TextStyle(color: Colors.white30),

      errorStyle: const TextStyle(color: Colors.redAccent),

      filled: true,

      fillColor: const Color(0xFF1C1C1C),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  // -------------------------------------------------------
  // UI
  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 45, 24, 35),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    // ------------------------------------------------
                    // LOGO
                    // ------------------------------------------------
                    const Icon(
                      Icons.play_circle_fill,
                      size: 72,
                      color: Color(0xFF6C63FF),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'GLASSNIK',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Share your perspective',
                      textAlign: TextAlign.center,

                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 45),

                    // ------------------------------------------------
                    // WELCOME
                    // ------------------------------------------------
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Sign in to continue to Glassnik',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),

                    const SizedBox(height: 30),

                    // ------------------------------------------------
                    // EMAIL
                    // ------------------------------------------------
                    TextFormField(
                      controller: _emailController,

                      keyboardType: TextInputType.emailAddress,

                      textInputAction: TextInputAction.next,

                      autocorrect: false,

                      autofillHints: const [AutofillHints.email],

                      style: const TextStyle(color: Colors.white),

                      validator: _validateEmail,

                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      decoration: _inputDecoration(
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ------------------------------------------------
                    // PASSWORD
                    // ------------------------------------------------
                    TextFormField(
                      controller: _passwordController,

                      obscureText: _obscurePassword,

                      textInputAction: TextInputAction.done,

                      enableSuggestions: false,

                      autocorrect: false,

                      autofillHints: const [AutofillHints.password],

                      style: const TextStyle(color: Colors.white),

                      validator: _validatePassword,

                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _signIn();
                        }
                      },

                      decoration: _inputDecoration(
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,

                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',

                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },

                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,

                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    // ------------------------------------------------
                    // FORGOT PASSWORD
                    // ------------------------------------------------
                    Align(
                      alignment: Alignment.centerRight,

                      child: TextButton(
                        onPressed: _isLoading ? null : _forgotPassword,

                        child: const Text(
                          'Forgot password?',

                          style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ------------------------------------------------
                    // SIGN IN BUTTON
                    // ------------------------------------------------
                    SizedBox(
                      height: 52,

                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),

                          foregroundColor: Colors.white,

                          disabledBackgroundColor: const Color(
                            0xFF6C63FF,
                          ).withValues(alpha: 0.5),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,

                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',

                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ------------------------------------------------
                    // DIVIDER
                    // ------------------------------------------------
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white24)),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),

                          child: Text(
                            'OR',

                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),

                        Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ------------------------------------------------
                    // CREATE ACCOUNT
                    // ------------------------------------------------
                    SizedBox(
                      height: 52,

                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _openCreateAccount,

                        icon: const Icon(Icons.person_add_outlined),

                        label: const Text(
                          'Create New Account',

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,

                          side: const BorderSide(color: Color(0xFF6C63FF)),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ------------------------------------------------
                    // ACCOUNT MESSAGE
                    // ------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        const Text(
                          "Don't have an account?",

                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),

                        TextButton(
                          onPressed: _isLoading ? null : _openCreateAccount,

                          child: const Text(
                            'Sign Up',

                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // TEMPORARY WARNING
                    // ------------------------------------------------
                    const Text(
                      'Authentication backend is not connected yet.',
                      textAlign: TextAlign.center,

                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
