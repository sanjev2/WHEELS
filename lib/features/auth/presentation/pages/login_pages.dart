import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/app/theme/color.dart';
import 'package:wheels_flutter/core/services/biometric/biometric_providers.dart';
import 'package:wheels_flutter/core/utils/snackbar_helper.dart';
import 'package:wheels_flutter/core/widgets/my_buttons.dart';
import 'package:wheels_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:wheels_flutter/features/auth/presentation/pages/signup_page.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:wheels_flutter/features/dashboard/dahsboard_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _bioLoading = false;
  bool _successShown = false;

  ProviderSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();

    _emailFocus.addListener(_rebuildOnFocus);
    _passwordFocus.addListener(_rebuildOnFocus);

    _authSub = ref.listenManual<AuthState>(authViewModelProvider, (prev, next) {
      if (!mounted) return;

      if (next.status == AuthStatus.error &&
          (next.errorMessage ?? '').trim().isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showErrorSnackBar(
            context,
            next.errorMessage!.replaceFirst('Exception: ', ''),
          );
        });
      }

      if (next.status == AuthStatus.authenticated && !_successShown) {
        _successShown = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          showSuccessSnackBar(context, 'Login successful!');

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
            (route) => false,
          );
        });
      }

      if (next.status == AuthStatus.unauthenticated ||
          next.status == AuthStatus.initial ||
          next.status == AuthStatus.error) {
        _successShown = false;
      }
    });
  }

  void _rebuildOnFocus() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _authSub?.close();

    _emailController.dispose();
    _passwordController.dispose();

    _emailFocus.removeListener(_rebuildOnFocus);
    _passwordFocus.removeListener(_rebuildOnFocus);

    _emailFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  InputDecoration _pillDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceGreen,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    _successShown = false;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref
        .read(authViewModelProvider.notifier)
        .login(email: email, password: password);

    final authState = ref.read(authViewModelProvider);

    if (authState.status == AuthStatus.authenticated &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      final credNotifier = ref.read(
        biometricCredentialControllerProvider.notifier,
      );

      await credNotifier.save(email: email, password: password);
      await credNotifier.refresh();
    }
  }

  Future<void> _loginWithBiometric() async {
    if (_bioLoading) return;

    FocusScope.of(context).unfocus();
    setState(() => _bioLoading = true);

    try {
      final enabled = ref.read(biometricEnabledProvider);
      if (!enabled) {
        showErrorSnackBar(
          context,
          'Enable biometric login from Settings first.',
        );
        return;
      }

      final store = ref.read(biometricSecureStoreProvider);
      final hasCreds = await store.hasCredentials();

      if (!hasCreds) {
        showErrorSnackBar(
          context,
          'No saved credentials found. Login once with email and password first.',
        );
        return;
      }

      final bio = ref.read(biometricServiceProvider);

      final supported = await bio.isSupported();
      if (!supported) {
        showErrorSnackBar(context, 'Biometric not available on this device.');
        return;
      }

      final enrolled = await bio.hasEnrolledBiometrics();
      if (!enrolled) {
        showErrorSnackBar(
          context,
          'No fingerprint or face is enrolled on this device.',
        );
        return;
      }

      final creds = await ref
          .read(biometricCredentialControllerProvider.notifier)
          .authenticateAndRead(bio);

      final email = (creds['email'] ?? '').trim();
      final password = creds['password'] ?? '';

      if (email.isEmpty || password.isEmpty) {
        showErrorSnackBar(
          context,
          'Saved biometric credentials are missing. Please login normally once again.',
        );
        return;
      }

      setState(() {
        _emailController.text = email;
        _passwordController.text = password;
      });

      _successShown = false;

      await ref
          .read(authViewModelProvider.notifier)
          .login(email: email, password: password);

      final authState = ref.read(authViewModelProvider);

      if (authState.status == AuthStatus.authenticated) {
        final credNotifier = ref.read(
          biometricCredentialControllerProvider.notifier,
        );

        await credNotifier.save(email: email, password: password);
        await credNotifier.refresh();
      }
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _bioLoading = false);
      }
    }
  }

  void _goToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupPage()),
    );
  }

  Future<void> _openForgotPasswordSheet() async {
    FocusScope.of(context).unfocus();

    final result = await showModalBottomSheet<_ForgotFlowResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (_) =>
          _ForgotPasswordSheet(initialEmail: _emailController.text.trim()),
    );

    if (!mounted) return;

    if (result == _ForgotFlowResult.done) {
      showSuccessSnackBar(context, 'Password updated. Please login.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final isBusy = isLoading || _bioLoading;

    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: SafeArea(
        top: true,
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: isSmall ? 4 : 8),
                    SizedBox(
                      height: 200,
                      child: Image.asset(
                        'assets/images/logo2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: isSmall ? 10 : 14),
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        18,
                        isSmall ? 18 : 22,
                        18,
                        18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: AppColors.borderLight.withOpacity(0.6),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 26,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              'Welcome back!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to continue',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            _AnimatedField(
                              isFocused: _emailFocus.hasFocus,
                              glowColor: AppColors.primaryGreen,
                              child: TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _pillDecoration(
                                  hint: 'Email Address',
                                  icon: Icons.email_outlined,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_passwordFocus),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _AnimatedField(
                              isFocused: _passwordFocus.hasFocus,
                              glowColor: AppColors.primaryGreen,
                              child: TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                decoration: _pillDecoration(
                                  hint: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () => setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    }),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Password is required';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) =>
                                    isBusy ? null : _login(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: isBusy
                                    ? null
                                    : _openForgotPasswordSheet,
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            MyButton(
                              onPressed: isBusy ? null : _login,
                              text: isLoading ? 'Logging in...' : 'Login',
                              isLoading: isLoading,
                              height: 54,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: isBusy ? null : _loginWithBiometric,
                                icon: _bioLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                        ),
                                      )
                                    : const Icon(Icons.fingerprint),
                                label: Text(
                                  _bioLoading
                                      ? 'Checking biometrics...'
                                      : 'Login with Face/Fingerprint',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.primaryGreen.withOpacity(
                                      0.35,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: _goToSignup,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 10 : 16),
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

class _AnimatedField extends StatelessWidget {
  final bool isFocused;
  final Color glowColor;
  final Widget child;

  const _AnimatedField({
    required this.isFocused,
    required this.glowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, isFocused ? -2 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: isFocused ? glowColor.withOpacity(0.10) : Colors.transparent,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

enum _ForgotStep { request, verify, reset }

enum _ForgotFlowResult { done }

class _ForgotPasswordSheet extends ConsumerStatefulWidget {
  final String initialEmail;
  const _ForgotPasswordSheet({required this.initialEmail});

  @override
  ConsumerState<_ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<_ForgotPasswordSheet> {
  _ForgotStep _step = _ForgotStep.request;

  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  String? _resetToken;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      showErrorSnackBar(context, 'Email is required');
      return;
    }

    setState(() => _loading = true);
    try {
      final int cooldown = await ref
          .read(authRemoteDatasourceProvider)
          .forgotPassword(email: email);

      if (!mounted) return;
      showSuccessSnackBar(
        context,
        'If the email exists, a code has been sent. Please wait $cooldown seconds before trying again.',
      );
      setState(() => _step = _ForgotStep.verify);
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (email.isEmpty) {
      showErrorSnackBar(context, 'Email is required');
      return;
    }
    if (code.isEmpty) {
      showErrorSnackBar(context, 'Verification code is required');
      return;
    }

    setState(() => _loading = true);
    try {
      final token = await ref
          .read(authRemoteDatasourceProvider)
          .verifyResetCode(email: email, code: code);

      if (!mounted) return;
      setState(() {
        _resetToken = token;
        _step = _ForgotStep.reset;
      });
      showSuccessSnackBar(context, 'Code verified. Set your new password.');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final token = _resetToken;
    final p1 = _newPassCtrl.text;
    final p2 = _confirmCtrl.text;

    if (token == null || token.isEmpty) {
      showErrorSnackBar(
        context,
        'Missing reset token. Please verify code again.',
      );
      setState(() => _step = _ForgotStep.verify);
      return;
    }

    if (p1.trim().length < 6) {
      showErrorSnackBar(context, 'New password must be at least 6 characters.');
      return;
    }
    if (p1 != p2) {
      showErrorSnackBar(context, 'Passwords do not match.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(authRemoteDatasourceProvider)
          .resetPassword(resetToken: token, newPassword: p1.trim());

      if (!mounted) return;
      Navigator.pop(context, _ForgotFlowResult.done);
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Forgot Password',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _step == _ForgotStep.request
                    ? 'Enter your email to receive a verification code.'
                    : _step == _ForgotStep.verify
                    ? 'Enter the 6-digit code sent to your email.'
                    : 'Create a new password for your account.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                enabled: !_loading && _step == _ForgotStep.request,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: AppColors.surfaceGreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_step == _ForgotStep.verify) ...[
                TextField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    hintText: 'Verification code',
                    filled: true,
                    fillColor: AppColors.surfaceGreen,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_step == _ForgotStep.reset) ...[
                TextField(
                  controller: _newPassCtrl,
                  enabled: !_loading,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'New password',
                    filled: true,
                    fillColor: AppColors.surfaceGreen,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmCtrl,
                  enabled: !_loading,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirm new password',
                    filled: true,
                    fillColor: AppColors.surfaceGreen,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _loading
                      ? null
                      : () {
                          if (_step == _ForgotStep.request) _requestCode();
                          if (_step == _ForgotStep.verify) _verifyCode();
                          if (_step == _ForgotStep.reset) _resetPassword();
                        },
                  child: Text(
                    _loading
                        ? 'Please wait...'
                        : _step == _ForgotStep.request
                        ? 'Send code'
                        : _step == _ForgotStep.verify
                        ? 'Verify code'
                        : 'Reset password',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (_step != _ForgotStep.request)
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() {
                          _step = _ForgotStep.request;
                          _resetToken = null;
                          _codeCtrl.clear();
                          _newPassCtrl.clear();
                          _confirmCtrl.clear();
                        }),
                  child: const Text(
                    'Start over',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
