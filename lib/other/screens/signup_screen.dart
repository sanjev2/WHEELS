import 'package:flutter/material.dart';
import 'package:wheels_flutter/other/common/my_snackbar.dart';
import 'package:wheels_flutter/other/screens/login_screen.dart';
import 'package:wheels_flutter/other/widgets/my_button.dart';
import 'package:wheels_flutter/other/widgets/my_textformfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() {
    return _SignupScreenState();
  }
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    contactController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const LoginScreen();
        },
      ),
    );
  }

  void signUp() {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      mySnackBar(
        context: context,
        message: "Account created successfully!",
        color: Colors.green,
      );

      Future.delayed(const Duration(seconds: 2), () {
        goToLogin();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: const Text(
                                'Welcome!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontFamily: 'Inter Bold',
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: const Text(
                                'Sign up to get started.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          MyTextFormField(
                            label: 'Full Name',
                            controller: fullNameController,
                            validator: (String? val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Full Name cannot be empty";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          MyTextFormField(
                            label: 'Email',
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (String? val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Email cannot be empty";
                              }
                              if (!val.contains("@") || !val.contains(".com")) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          MyTextFormField(
                            label: 'Address',
                            controller: addressController,
                            validator: (String? val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Address cannot be empty";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          MyTextFormField(
                            label: 'Contact Number',
                            controller: contactController,
                            keyboardType: TextInputType.phone,
                            validator: (String? val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Contact Number cannot be empty";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (String? val) {
                              if (val == null || val.isEmpty) {
                                return "Password cannot be empty";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword =
                                        !obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (String? val) {
                              if (val == null || val.isEmpty) {
                                return "Confirm Password cannot be empty";
                              }
                              if (val != passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 52,
                            child: MyButton(onPressed: signUp, text: "Sign Up"),
                          ),

                          const Spacer(),

                          GestureDetector(
                            onTap: goToLogin,
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: 24),
                              child: Center(
                                child: Text(
                                  "Already have an account? Login",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
