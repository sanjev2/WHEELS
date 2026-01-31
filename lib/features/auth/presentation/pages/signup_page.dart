import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/app/theme/color.dart';
import 'package:wheels_flutter/core/utils/snackbar_helper.dart';
import 'package:wheels_flutter/core/widgets/my_buttons.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:wheels_flutter/features/auth/presentation/pages/login_pages.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _contactFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _contactFocus.addListener(() => setState(() {}));
    _addressFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _contactFocus.dispose();
    _addressFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();

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

  String? _required(String? v, String msg) {
    if (v == null || v.trim().isEmpty) return msg;
    return null;
  }

  // ✅ BACKEND LOGIC UNCHANGED
  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(authViewModelProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          contact: _contactController.text.trim(),
          address: _addressController.text.trim(),
        );

    final authState = ref.read(authViewModelProvider);
    if (!mounted) return;

    if (authState.status == AuthStatus.registered) {
      mySnackBar(
        context: context,
        message: "Account created successfully!",
        color: Colors.green,
      );

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      mySnackBar(
        context: context,
        message: authState.errorMessage ?? "Signup failed. Please try again.",
        color: Colors.red,
      );
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 760;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  mainAxisAlignment:
                      MainAxisAlignment.start, // ✅ start from top
                  children: [
                    SizedBox(height: isSmall ? 70 : 70), // ✅ small top gap
                    // ✅ No logo here (as per your app), keep tight spacing
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
                              "Let's get started!",
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
                              "Create your account to get started",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 18),

                            _AnimatedField(
                              isFocused: _nameFocus.hasFocus,
                              glowColor: AppColors.primaryGreen,
                              child: TextFormField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                textInputAction: TextInputAction.next,
                                decoration: _pillDecoration(
                                  hint: "Full Name",
                                  icon: Icons.person_outline_rounded,
                                ),
                                validator: (v) =>
                                    _required(v, "Full name is required"),
                                onFieldSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_emailFocus),
                              ),
                            ),
                            const SizedBox(height: 12),

                            _AnimatedField(
                              isFocused: _emailFocus.hasFocus,
                              glowColor: AppColors.primaryGreen,
                              child: TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _pillDecoration(
                                  hint: "Email Address",
                                  icon: Icons.email_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Email is required";
                                  }
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(value.trim())) {
                                    return "Enter a valid email";
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_contactFocus),
                              ),
                            ),
                            const SizedBox(height: 12),

                            _AnimatedField(
                              isFocused: _contactFocus.hasFocus,
                              glowColor: AppColors.primaryGreen,
                              child: TextFormField(
                                controller: _contactController,
                                focusNode: _contactFocus,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                decoration: _pillDecoration(
                                  hint: "Contact Number",
                                  icon: Icons.phone_outlined,
                                ),
                                validator: (v) =>
                                    _required(v, "Contact number is required"),
                                onFieldSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_addressFocus),
                              ),
                            ),
                            const SizedBox(height: 12),

                            _AnimatedField(
                              isFocused: _addressFocus.hasFocus,
                              glowColor: AppColors.primaryGreen,
                              child: TextFormField(
                                controller: _addressController,
                                focusNode: _addressFocus,
                                textInputAction: TextInputAction.next,
                                decoration: _pillDecoration(
                                  hint: "Address",
                                  icon: Icons.location_on_outlined,
                                ),
                                validator: (v) =>
                                    _required(v, "Address is required"),
                                onFieldSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_passwordFocus),
                              ),
                            ),
                            const SizedBox(height: 12),

                            _AnimatedField(
                              isFocused: _passwordFocus.hasFocus,
                              glowColor: AppColors.primaryGreen,
                              child: TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                decoration: _pillDecoration(
                                  hint: "Password",
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return "Password is required";
                                  if (value.length < 6)
                                    return "Password must be at least 6 characters";
                                  return null;
                                },
                                onFieldSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_confirmFocus),
                              ),
                            ),
                            const SizedBox(height: 12),

                            _AnimatedField(
                              isFocused: _confirmFocus.hasFocus,
                              glowColor: AppColors.primaryGreen,
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmFocus,
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                decoration: _pillDecoration(
                                  hint: "Confirm Password",
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return "Please confirm your password";
                                  if (value != _passwordController.text)
                                    return "Passwords do not match";
                                  return null;
                                },
                                onFieldSubmitted: (_) =>
                                    isLoading ? null : _register(),
                              ),
                            ),

                            const SizedBox(height: 18),

                            MyButton(
                              onPressed: isLoading ? null : _register,
                              text: isLoading
                                  ? "Creating Account..."
                                  : "Create Account",
                              isLoading: isLoading,
                              height: 54,
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
                          "Already have an account? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: _goToLogin,
                          child: const Text(
                            "Login",
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
