import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/google_sign_in_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _AccountRequirements extends StatelessWidget {
  const _AccountRequirements();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // EMAIL
          // ==========================================================
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined, size: 17, color: Color(0xFF1976D2)),
              SizedBox(width: 8),
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF344054),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          const Text(
            'Use a valid email address, e.g. name@example.com',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: Color(0xFF667085),
            ),
          ),

          const SizedBox(height: 14),

          // ==========================================================
          // PASSWORD
          // ==========================================================
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 17, color: Color(0xFF1976D2)),
              SizedBox(width: 8),
              Text(
                'Password requirements',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF344054),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const _Requirement(text: 'At least 8 characters'),

          const _Requirement(text: 'At least one uppercase letter (A-Z)'),

          const _Requirement(text: 'At least one lowercase letter (a-z)'),

          const _Requirement(text: 'At least one number (0-9)'),

          const _Requirement(text: 'At least one special character'),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 15,
            color: Color(0xFF667085),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: Color(0xFF667085),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      final error = authProvider.errorMessage ?? 'Unable to create account.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );

      authProvider.clearError();

      return;
    }

    // ------------------------------------------------------------
    // Registration successful
    // ------------------------------------------------------------
    //
    // Firebase has already authenticated the user.
    // AuthProvider status is now authenticated.
    //
    // Remove RegisterScreen from the navigation stack.
    //

    Navigator.of(context).pop();
  }

  Future<void> _googleSignIn() async {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signInWithGoogle();

    if (!mounted) {
      return;
    }

    if (!success) {
      final error =
          authProvider.errorMessage ??
          'Google sign-in failed. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );

      authProvider.clearError();

      return;
    }

    // Google authentication succeeded.
    //
    // Remove Login/Register screen from the navigation stack.
    // AuthProvider is already authenticated.

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),

              child: Form(
                key: _formKey,

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const AuthHeader(
                        title: 'Create account',
                        subtitle:
                            'Create your GoCare account to access health and emergency features.',
                      ),

                      const SizedBox(height: 32),

                      // =================================================
                      // NAME
                      // =================================================
                      AppTextField(
                        controller: _nameController,
                        label: 'Full name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: _validateName,
                      ),

                      const SizedBox(height: 8),

                      // =================================================
                      // EMAIL
                      // =================================================
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 16),

                      // =================================================
                      // PASSWORD
                      // =================================================
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Create a password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        validator: _validatePassword,

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // =================================================
                      // CONFIRM PASSWORD
                      // =================================================
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm password',
                        hintText: 'Enter password again',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        validator: _validateConfirmPassword,

                        suffixIcon: IconButton(
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
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const _AccountRequirements(),

                      const SizedBox(height: 18),

                      // =================================================
                      // REGISTER BUTTON
                      // =================================================
                      AppButton(
                        text: 'Create account',
                        isLoading: authProvider.isLoading,
                        onPressed: _register,
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // OR
                      // =================================================
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Color(0xFFE4E7EC)),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const Expanded(
                            child: Divider(color: Color(0xFFE4E7EC)),
                          ),
                        ],
                      ),

                      // =================================================
                      // LOGIN
                      // =================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ============================================================
  // VALIDATORS
  // ============================================================

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Full name is required';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (name.length > 50) {
      return 'Name must not exceed 50 characters';
    }

    // Allows letters, spaces, apostrophe and dot.
    final nameRegex = RegExp(r"^[a-zA-Z][a-zA-Z\s.'-]*$");

    if (!nameRegex.hasMatch(name)) {
      return 'Enter a valid name';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    if (email.length > 254) {
      return 'Email address is too long';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@'
      r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}'
      r'[a-zA-Z0-9])?'
      r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}'
      r'[a-zA-Z0-9])?)+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (password.length > 128) {
      return 'Password must not exceed 128 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain an uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain a lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain a number';
    }

    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Password must contain a special character';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (confirmPassword != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }
}
