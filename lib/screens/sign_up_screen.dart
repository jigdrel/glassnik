import 'package:flutter/material.dart';

import 'main_navigation_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // VALIDATION
  // -------------------------------------------------------

  String? _validateDisplayName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your name';
    }

    if (name.length < 2) {
      return 'Name must contain at least 2 characters';
    }

    if (name.length > 40) {
      return 'Name must be 40 characters or less';
    }

    return null;
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';

    if (username.isEmpty) {
      return 'Please choose a username';
    }

    if (username.length < 3) {
      return 'Username must contain at least 3 characters';
    }

    if (username.length > 20) {
      return 'Username must be 20 characters or less';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9._]+$');

    if (!usernameRegex.hasMatch(username)) {
      return 'Only letters, numbers, . and _ are allowed';
    }

    if (username.startsWith('.') || username.startsWith('_')) {
      return 'Username must start with a letter or number';
    }

    return null;
  }

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

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter a password';
    }

    if (password.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Add at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Add at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Add at least one special character';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // -------------------------------------------------------
  // CREATE ACCOUNT
  // -------------------------------------------------------

  Future<void> _createAccount() async {
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
       * TEMPORARY ACCOUNT CREATION
       *
       * Front-end validation is complete, but Firebase Authentication
       * is NOT connected yet.
       *
       * Later this will become:
       *
       * final credential =
       *     await FirebaseAuth.instance
       *         .createUserWithEmailAndPassword(
       *   email: _emailController.text.trim(),
       *   password: _passwordController.text,
       * );
       *
       * Then the user's profile will be saved to Firestore using:
       *
       * credential.user!.uid
       *
       * Passwords must NEVER be saved to Firestore.
       */

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome ${_displayNameController.text.trim()}!'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to create account. Please try again.'),
        ),
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

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Create Account'),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 15, 24, 40),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    // LOGO
                    const Icon(
                      Icons.play_circle_fill,
                      size: 65,
                      color: Color(0xFF6C63FF),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Join Glassnik',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Create your account and start sharing your perspective.',
                      textAlign: TextAlign.center,

                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 32),

                    // DISPLAY NAME
                    TextFormField(
                      controller: _displayNameController,

                      textInputAction: TextInputAction.next,

                      textCapitalization: TextCapitalization.words,

                      style: const TextStyle(color: Colors.white),

                      validator: _validateDisplayName,

                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      decoration: _inputDecoration(
                        label: 'Display Name',
                        hint: 'Your name',
                        icon: Icons.person_outline,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // USERNAME
                    TextFormField(
                      controller: _usernameController,

                      textInputAction: TextInputAction.next,

                      autocorrect: false,

                      enableSuggestions: false,

                      style: const TextStyle(color: Colors.white),

                      validator: _validateUsername,

                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      decoration: _inputDecoration(
                        label: 'Username',
                        hint: 'Choose a username',
                        icon: Icons.alternate_email,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,

                      keyboardType: TextInputType.emailAddress,

                      textInputAction: TextInputAction.next,

                      autocorrect: false,

                      autofillHints: const [AutofillHints.newUsername],

                      style: const TextStyle(color: Colors.white),

                      validator: _validateEmail,

                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      decoration: _inputDecoration(
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,

                      obscureText: _obscurePassword,

                      textInputAction: TextInputAction.next,

                      enableSuggestions: false,

                      autocorrect: false,

                      autofillHints: const [AutofillHints.newPassword],

                      style: const TextStyle(color: Colors.white),

                      validator: _validatePassword,

                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      decoration: _inputDecoration(
                        label: 'Password',
                        hint: 'Create a password',
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

                    const SizedBox(height: 10),

                    const Text(
                      'Use at least 8 characters with an uppercase letter, lowercase letter, number and special character.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),

                    const SizedBox(height: 16),

                    // CONFIRM PASSWORD
                    TextFormField(
                      controller: _confirmPasswordController,

                      obscureText: _obscureConfirmPassword,

                      textInputAction: TextInputAction.done,

                      enableSuggestions: false,

                      autocorrect: false,

                      style: const TextStyle(color: Colors.white),

                      validator: _validateConfirmPassword,

                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _createAccount();
                        }
                      },

                      decoration: _inputDecoration(
                        label: 'Confirm Password',
                        hint: 'Enter password again',
                        icon: Icons.lock_reset_outlined,

                        suffixIcon: IconButton(
                          tooltip: _obscureConfirmPassword
                              ? 'Show password'
                              : 'Hide password',

                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },

                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,

                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // CREATE ACCOUNT
                    SizedBox(
                      height: 52,

                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createAccount,

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
                                'Create Account',

                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // RETURN TO LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        const Text(
                          'Already have an account?',

                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),

                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },

                          child: const Text(
                            'Sign In',

                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Account storage is not connected to Firebase yet.',
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
