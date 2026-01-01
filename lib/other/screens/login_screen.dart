import 'package:flutter/material.dart';
import 'package:wheels_flutter/other/common/my_snackbar.dart';
import 'package:wheels_flutter/other/screens/dashboard_screen.dart';
import 'package:wheels_flutter/other/screens/signup_screen.dart';
import 'package:wheels_flutter/other/widgets/my_button.dart';
import 'package:wheels_flutter/other/widgets/my_textformfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const SignupScreen();
        },
      ),
    );
  }

  void goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const DashboardScreen();
        },
      ),
    );
  }

  void login() {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      mySnackBar(
        context: context,
        message: "Login successful!",
        color: Colors.green,
      );

      Future.delayed(const Duration(seconds: 1), () {
        goToDashboard();
      });
    }
  }

  String? validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) {
      return "Email cannot be empty";
    }
    if (!val.contains("@") || !val.contains(".com")) {
      return "Enter a valid email";
    }
    return null;
  }

  String? validatePassword(String? val) {
    if (val == null || val.isEmpty) {
      return "Password cannot be empty";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 80),

                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text(
                            'Welcome!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter Bold',
                              color: Colors.green,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text(
                            'Login to continue.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      MyTextFormField(
                        label: 'Email',
                        controller: emailController,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 16),

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
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: validatePassword,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            "Remember Me",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 52,
                        child: MyButton(onPressed: login, text: "Login"),
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: goToSignUp,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
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
