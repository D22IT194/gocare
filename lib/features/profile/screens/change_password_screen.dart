import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../authentication/providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
  });

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _currentPasswordController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmController =
      TextEditingController();

  // ============================================================
  // PASSWORD VISIBILITY
  // ============================================================

  bool _hideCurrentPassword = true;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(
      _onPasswordChanged,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _passwordController.removeListener(
      _onPasswordChanged,
    );

    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();

    super.dispose();
  }

  // ============================================================
  // PASSWORD LISTENER
  // ============================================================

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // PASSWORD STRENGTH
  // ============================================================

  double get _passwordStrength {
    final password =
        _passwordController.text;

    if (password.isEmpty) {
      return 0;
    }

    double strength = 0;

    // At least 6 characters
    if (password.length >= 6) {
      strength += 0.25;
    }

    // At least 8 characters
    if (password.length >= 8) {
      strength += 0.25;
    }

    // Uppercase
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strength += 0.15;
    }

    // Lowercase
    if (RegExp(r'[a-z]').hasMatch(password)) {
      strength += 0.15;
    }

    // Number
    if (RegExp(r'[0-9]').hasMatch(password)) {
      strength += 0.10;
    }

    // Special character
    if (RegExp(
      r'[!@#$%^&*(),.?":{}|<>]',
    ).hasMatch(password)) {
      strength += 0.10;
    }

    return strength.clamp(0, 1);
  }

  // ============================================================
  // PASSWORD STRENGTH TEXT
  // ============================================================

  String get _passwordStrengthText {
    final strength =
        _passwordStrength;

    if (strength == 0) {
      return '';
    }

    if (strength < 0.5) {
      return 'Weak password';
    }

    if (strength < 0.75) {
      return 'Good password';
    }

    return 'Strong password';
  }

  // ============================================================
  // PASSWORD STRENGTH COLOR
  // ============================================================

  Color _strengthColor(
    BuildContext context,
  ) {
    final strength =
        _passwordStrength;

    if (strength < 0.5) {
      return Colors.red;
    }

    if (strength < 0.75) {
      return Colors.orange;
    }

    return Colors.green;
  }

  // ============================================================
  // SAVE / UPDATE PASSWORD
  // ============================================================

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final success =
        await authProvider.updatePassword(
      currentPassword:
          _currentPasswordController.text,
      newPassword:
          _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      authProvider.clearError();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password changed successfully.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      // Return to Profile screen.
      Navigator.of(context).pop();

      return;
    }

    final message =
        authProvider.errorMessage ??
            'Unable to change password.';

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );

    authProvider.clearError();
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> _forgotPassword() async {
    FocusScope.of(context).unfocus();

    final authProvider =
        context.read<AuthProvider>();

    final email =
        authProvider.user?.email?.trim() ?? '';

    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'No email address is associated with this account.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final shouldSend =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Forgot password?',
          ),
          content: Text(
            'We will send a password reset link to:\n\n$email',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Send Link',
              ),
            ),
          ],
        );
      },
    );

    if (shouldSend != true ||
        !mounted) {
      return;
    }

    final success =
        await authProvider.forgotPassword(
      email: email,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      authProvider.clearError();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Password reset link sent to $email.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final message =
        authProvider.errorMessage ??
            'Unable to send password reset email.';

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );

    authProvider.clearError();
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================

  String? _validateCurrentPassword(
    String? value,
  ) {
    final password =
        value ?? '';

    if (password.isEmpty) {
      return 'Current password is required';
    }

    return null;
  }

  String? _validatePassword(
    String? value,
  ) {
    final password =
        value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(
    String? value,
  ) {
    final confirmPassword =
        value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (confirmPassword !=
        _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final authProvider =
        context.watch<AuthProvider>();

    final isLoading =
        authProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .unfocus();
          },

          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(20),

                    decoration:
                        BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(
                        alpha: 0.08,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Container(
                          width: 52,
                          height: 52,

                          decoration:
                              BoxDecoration(
                            color:
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(
                                  alpha: 0.12,
                                ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),

                          child: Icon(
                            Icons
                                .lock_reset_outlined,
                            size: 28,
                            color:
                                Theme.of(context)
                                    .colorScheme
                                    .primary,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Text(
                          'Create a new password',
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          'Use a strong password to keep '
                          'your GoCare account secure.',
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    Theme.of(
                                  context,
                                )
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // CURRENT PASSWORD
                  // ==================================================

                  Text(
                    'Current Password',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  TextFormField(
                    controller:
                        _currentPasswordController,

                    obscureText:
                        _hideCurrentPassword,

                    textInputAction:
                        TextInputAction.next,

                    autofillHints: const [
                      AutofillHints.password,
                    ],

                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter current password',

                      prefixIcon:
                          const Icon(
                        Icons.lock_outline,
                      ),

                      suffixIcon:
                          IconButton(
                        tooltip:
                            _hideCurrentPassword
                                ? 'Show password'
                                : 'Hide password',

                        onPressed: () {
                          setState(() {
                            _hideCurrentPassword =
                                !_hideCurrentPassword;
                          });
                        },

                        icon: Icon(
                          _hideCurrentPassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),

                    validator:
                        _validateCurrentPassword,
                  ),

                  // ==================================================
                  // FORGOT PASSWORD
                  // ==================================================

                  const SizedBox(
                    height: 6,
                  ),

                  Align(
                    alignment:
                        Alignment.centerRight,

                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : _forgotPassword,

                      child: const Text(
                        'Forgot your current password?',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // ==================================================
                  // NEW PASSWORD
                  // ==================================================

                  Text(
                    'New Password',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  TextFormField(
                    controller:
                        _passwordController,

                    obscureText:
                        _hidePassword,

                    textInputAction:
                        TextInputAction.next,

                    autofillHints: const [
                      AutofillHints.newPassword,
                    ],

                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter new password',

                      prefixIcon:
                          const Icon(
                        Icons.lock_outline,
                      ),

                      suffixIcon:
                          IconButton(
                        tooltip: _hidePassword
                            ? 'Show password'
                            : 'Hide password',

                        onPressed: () {
                          setState(() {
                            _hidePassword =
                                !_hidePassword;
                          });
                        },

                        icon: Icon(
                          _hidePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),

                    validator:
                        _validatePassword,
                  ),

                  // ==================================================
                  // PASSWORD STRENGTH
                  // ==================================================

                  if (_passwordController
                      .text
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 12,
                    ),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),

                      child:
                          LinearProgressIndicator(
                        value:
                            _passwordStrength,

                        minHeight: 6,

                        backgroundColor:
                            Theme.of(context)
                                .dividerColor,

                        valueColor:
                            AlwaysStoppedAnimation<
                                Color>(
                          _strengthColor(
                            context,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      _passwordStrengthText,

                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            _strengthColor(
                          context,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 20,
                  ),

                  // ==================================================
                  // CONFIRM PASSWORD
                  // ==================================================

                  Text(
                    'Confirm Password',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  TextFormField(
                    controller:
                        _confirmController,

                    obscureText:
                        _hideConfirmPassword,

                    textInputAction:
                        TextInputAction.done,

                    autofillHints: const [
                      AutofillHints.newPassword,
                    ],

                    onFieldSubmitted: (_) {
                      if (!isLoading) {
                        _save();
                      }
                    },

                    decoration:
                        InputDecoration(
                      hintText:
                          'Confirm new password',

                      prefixIcon:
                          const Icon(
                        Icons
                            .lock_reset_outlined,
                      ),

                      suffixIcon:
                          IconButton(
                        tooltip:
                            _hideConfirmPassword
                                ? 'Show password'
                                : 'Hide password',

                        onPressed: () {
                          setState(() {
                            _hideConfirmPassword =
                                !_hideConfirmPassword;
                          });
                        },

                        icon: Icon(
                          _hideConfirmPassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),

                    validator:
                        _validateConfirmPassword,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ==================================================
                  // PASSWORD REQUIREMENTS
                  // ==================================================

                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(16),

                    decoration:
                        BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(
                        alpha: 0.45,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          'Password requirements',
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        _RequirementRow(
                          text:
                              'At least 6 characters',

                          fulfilled:
                              _passwordController
                                      .text
                                      .length >=
                                  6,
                        ),

                        _RequirementRow(
                          text:
                              'Use uppercase and lowercase letters',

                          fulfilled:
                              RegExp(
                            r'(?=.*[a-z])(?=.*[A-Z])',
                          ).hasMatch(
                            _passwordController
                                .text,
                          ),
                        ),

                        _RequirementRow(
                          text:
                              'Include at least one number',

                          fulfilled:
                              RegExp(
                            r'[0-9]',
                          ).hasMatch(
                            _passwordController
                                .text,
                          ),
                        ),

                        _RequirementRow(
                          text:
                              'Include at least one special character',

                          fulfilled:
                              RegExp(
                            r'[!@#$%^&*(),.?":{}|<>]',
                          ).hasMatch(
                            _passwordController
                                .text,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  // ==================================================
                  // UPDATE BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 54,

                    child:
                        ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : _save,

                      style:
                          ElevatedButton
                              .styleFrom(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2.5,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children: [
                                Icon(
                                  Icons
                                      .check_circle_outline,
                                ),

                                SizedBox(
                                  width: 8,
                                ),

                                Text(
                                  'Update Password',

                                  style:
                                      TextStyle(
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // SECURITY NOTE
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons
                            .verified_user_outlined,
                        size: 18,
                        color:
                            Theme.of(context)
                                .colorScheme
                                .primary,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child: Text(
                          'Your password is securely handled '
                          'by Firebase Authentication.',
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .bodySmall,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// REQUIREMENT ROW
// ================================================================

class _RequirementRow
    extends StatelessWidget {
  const _RequirementRow({
    required this.text,
    required this.fulfilled,
  });

  final String text;
  final bool fulfilled;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 8,
      ),

      child: Row(
        children: [
          Icon(
            fulfilled
                ? Icons.check_circle
                : Icons.radio_button_unchecked,

            size: 17,

            color: fulfilled
                ? Colors.green
                : Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              text,

              style: TextStyle(
                fontSize: 13,

                color: fulfilled
                    ? Colors.green
                    : Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}