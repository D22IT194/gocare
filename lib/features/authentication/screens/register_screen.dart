import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/google_sign_in_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

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

    final authProvider =
        context.read<AuthProvider>();

    final success = await authProvider.register(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success &&
        authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage!,
          ),
        ),
      );

      authProvider.clearError();
    }

    // IMPORTANT:
    //
    // Do NOT Navigator.pop().
    //
    // Successful Firebase registration automatically
    // authenticates the user.
    //
    // AuthProvider changes its state.
    //
    // AuthGate detects the authenticated state
    // and displays HomeScreen.
  }

  // ============================================================
  // GOOGLE SIGN IN
  // ============================================================

  Future<void> _googleSignIn() async {
    FocusScope.of(context).unfocus();

    final authProvider =
        context.read<AuthProvider>();

    final success =
        await authProvider.signInWithGoogle();

    if (!mounted) {
      return;
    }

    if (!success &&
        authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage!,
          ),
        ),
      );

      authProvider.clearError();
    }

    // No navigation here.
    //
    // AuthGate handles the authenticated state.
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 500,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

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
                      controller:
                          _nameController,
                      label: 'Full name',
                      hintText:
                          'Enter your full name',
                      prefixIcon:
                          Icons.person_outline,
                      textInputAction:
                          TextInputAction.next,
                      validator:
                          _validateName,
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // EMAIL
                    // =================================================

                    AppTextField(
                      controller:
                          _emailController,
                      label: 'Email',
                      hintText:
                          'Enter your email',
                      prefixIcon:
                          Icons.email_outlined,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      validator:
                          _validateEmail,
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // PASSWORD
                    // =================================================

                    AppTextField(
                      controller:
                          _passwordController,
                      label: 'Password',
                      hintText:
                          'Create a password',
                      prefixIcon:
                          Icons.lock_outline,
                      obscureText:
                          _obscurePassword,
                      textInputAction:
                          TextInputAction.next,
                      validator:
                          _validatePassword,

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
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // CONFIRM PASSWORD
                    // =================================================

                    AppTextField(
                      controller:
                          _confirmPasswordController,
                      label:
                          'Confirm password',
                      hintText:
                          'Enter password again',
                      prefixIcon:
                          Icons.lock_outline,
                      obscureText:
                          _obscureConfirmPassword,
                      textInputAction:
                          TextInputAction.done,
                      validator:
                          _validateConfirmPassword,

                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // REGISTER BUTTON
                    // =================================================

                    AppButton(
                      text: 'Create account',
                      isLoading:
                          authProvider.isLoading,
                      onPressed:
                          _register,
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // OR
                    // =================================================

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color:
                                Color(0xFFE4E7EC),
                          ),
                        ),

                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              )
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Divider(
                            color:
                                Color(0xFFE4E7EC),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // GOOGLE
                    // =================================================

                    GoogleSignInButton(
                      isLoading:
                          authProvider.isLoading,
                      onPressed:
                          _googleSignIn,
                      text:
                          'Sign up with Google',
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // LOGIN
                    // =================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          child:
                              const Text('Login'),
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

  // ============================================================
  // VALIDATORS
  // ============================================================

  String? _validateName(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Enter a valid name';
    }

    return null;
  }

  String? _validateEmail(
    String? value,
  ) {
    final email =
        value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final regex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!regex.hasMatch(email)) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? _validatePassword(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value !=
        _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }
}