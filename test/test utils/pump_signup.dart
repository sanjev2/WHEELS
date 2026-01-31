import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/features/auth/presentation/pages/signup_page.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wheels_flutter/features/auth/presentation/view_model/auth_view_model.dart';

import 'mocks.dart';

Future<void> pumpSignupPage(WidgetTester tester) async {
  // ✅ make screen big to avoid overflow in small test windows
  await tester.binding.setSurfaceSize(const Size(1200, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  registerAuthFakes();

  final mockLogin = MockLoginUsecase();
  final mockRegister = MockRegisterUsecase();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(
          (ref) => AuthViewModel(
            loginUsecase: mockLogin,
            registerUsecase: mockRegister,
          ),
        ),
      ],
      child: const MaterialApp(home: SignupPage()),
    ),
  );

  await tester.pumpAndSettle();
}
