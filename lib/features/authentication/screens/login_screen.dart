import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

Future<void> _login() async {
  FocusScope.of(context).unfocus();

  setState(() {
    _emailError = null;
    _passwordError = null;
  });

  // Local validation
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final authProvider = context.read<AuthProvider>();

  final success = await authProvider.login(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  if (!mounted) {
    return;
  }

  if (success) {
    authProvider.clearError();
    return;
  }

  // Get Firebase/AuthProvider error
  final error = authProvider.errorMessage?.trim() ?? '';

  debugPrint('LOGIN UI ERROR: $error');

  final normalized = error.toLowerCase();

  // ==========================================================
  // WRONG PASSWORD
  // ==========================================================

  if (normalized.contains('wrong password') ||
      normalized.contains('invalid credential') ||
      normalized.contains('invalid-credential') ||
      normalized.contains('incorrect password') ||
      normalized.contains('wrong-password')) {
    setState(() {
      _passwordError = 'Wrong password. Please try again.';
      _emailError = null;
    });

    _showErrorSnackBar(
      'Wrong password. Please try again.',
    );

    authProvider.clearError();
    return;
  }

  // ==========================================================
  // USER NOT FOUND
  // ==========================================================

  if (normalized.contains('no account found') ||
      normalized.contains('user-not-found')) {
    setState(() {
      _emailError = 'No account found with this email.';
      _passwordError = null;
    });

    _showErrorSnackBar(
      'No account found with this email.',
    );

    authProvider.clearError();
    return;
  }

  // ==========================================================
  // INVALID EMAIL
  // ==========================================================

  if (normalized.contains('valid email') ||
      normalized.contains('invalid-email')) {
    setState(() {
      _emailError = 'Please enter a valid email address.';
      _passwordError = null;
    });

    _showErrorSnackBar(
      'Please enter a valid email address.',
    );

    authProvider.clearError();
    return;
  }

  // ==========================================================
  // OTHER ERROR
  // ==========================================================

  _showErrorSnackBar(
    error.isEmpty
        ? 'Unable to sign in. Please try again.'
        : error,
  );

  authProvider.clearError();
}

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> _googleSignIn() async {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signInWithGoogle();

    if (!mounted) {
      return;
    }

    if (success) {
      authProvider.clearError();
      return;
    }

    final error = authProvider.errorMessage ?? 'Google sign-in failed.';

    _showErrorSnackBar(error);

    authProvider.clearError();
  }

  // ============================================================
  // LOGIN ERROR HANDLING
  // ============================================================

  void _showLoginError(String error) {
    final normalized = error.trim().toLowerCase();

    // ============================================================
    // INVALID CREDENTIALS
    // ============================================================

    if (normalized.contains('invalid email or password') ||
        normalized.contains('incorrect email or password') ||
        normalized.contains('wrong password') ||
        normalized.contains('incorrect password') ||
        normalized.contains('invalid credential') ||
        normalized.contains('invalid-credential') ||
        normalized.contains('wrong-password')) {
      setState(() {
        _passwordError = 'Wrong password. Please try again.';
        _emailError = null;
      });

      _showErrorSnackBar('Wrong password. Please try again.');

      return;
    }

    // ============================================================
    // USER NOT FOUND
    // ============================================================

    if (normalized.contains('no account found') ||
        normalized.contains('user-not-found')) {
      setState(() {
        _emailError = 'No account found with this email.';
        _passwordError = null;
      });

      _showErrorSnackBar('No account found with this email.');

      return;
    }

    // ============================================================
    // INVALID EMAIL FORMAT
    // ============================================================

    // IMPORTANT:
    // Don't use:
    //
    // normalized.contains('valid email')
    //
    // because "invalid email" contains "valid email".

    if (normalized.contains('please enter a valid email') ||
        normalized == 'invalid-email') {
      setState(() {
        _emailError = 'Please enter a valid email address.';
        _passwordError = null;
      });

      _showErrorSnackBar('Please enter a valid email address.');

      return;
    }

    // ============================================================
    // DEFAULT
    // ============================================================

    _showErrorSnackBar(
      error.isEmpty ? 'Unable to sign in. Please try again.' : error,
    );
  }
  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

void _showErrorSnackBar(String message) {
  if (!mounted) {
    return;
  }

  final messenger =
      ScaffoldMessenger.maybeOf(context);

  if (messenger == null) {
    return;
  }

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration:
            const Duration(seconds: 4),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        backgroundColor:
            const Color(0xFFD92D20),
        elevation: 6,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

  // ============================================================
  // VALIDATION
  // ============================================================

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

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

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(
      r'''[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=;`~]''',
    ).hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final isLoading = authProvider.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================
                    const AuthHeader(
                      title: 'Welcome back',
                      subtitle: 'Sign in to continue using GoCare.',
                    ),

                    const SizedBox(height: 36),

                    // ==================================================
                    // EMAIL
                    // ==================================================
                    AppTextField(
                      controller: _emailController,

                      label: 'Email',

                      hintText: 'Enter your email',

                      prefixIcon: Icons.email_outlined,

                      keyboardType: TextInputType.emailAddress,

                      textInputAction: TextInputAction.next,

                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // PASSWORD
                    // ==================================================
                    AppTextField(
                      controller: _passwordController,

                      label: 'Password',

                      hintText: 'Enter your password',

                      prefixIcon: Icons.lock_outline,

                      obscureText: _obscurePassword,

                      textInputAction: TextInputAction.done,

                      validator: _validatePassword,

                      onChanged: (_) {
                        if (_passwordError == null) {
                          return;
                        }

                        setState(() {
                          _passwordError = null;
                        });
                      },

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
                        ),
                      ),
                    ),

                    // ==================================================
                    // SERVER ERROR
                    // ==================================================
                    if (_passwordError != null) ...[
                      const SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.only(left: 4),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 16,
                              color: Color(0xFFD92D20),
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child: Text(
                                _passwordError!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFD92D20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ==================================================
                    // FORGOT PASSWORD
                    // ==================================================
                    Align(
                      alignment: Alignment.centerRight,

                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPassword,
                                );
                              },

                        child: const Text('Forgot password?'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // LOGIN
                    // ==================================================
                    AppButton(
                      text: 'Login',

                      isLoading: isLoading,

                      onPressed: _login,
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // DIVIDER
                    // ==================================================
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

                    const SizedBox(height: 20),

                    // ==================================================
                    // GOOGLE
                    // ==================================================
                    GoogleSignInButton(
                      isLoading: isLoading,

                      onPressed: _googleSignIn,
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // REGISTER
                    // ==================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        const Text("Don't have an account?"),

                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.register,
                                  );
                                },

                          child: const Text('Create account'),
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
    );
  }
}
