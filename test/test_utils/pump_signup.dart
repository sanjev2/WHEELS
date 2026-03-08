import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:wheels_flutter/features/auth/presentation/pages/signup_page.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wheels_flutter/features/auth/presentation/view_model/auth_view_model.dart';

import 'mocks.dart';
import 'test_failure.dart';

Future<void> pumpSignupPage(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  registerTestFallbacks();

  final mockLogin = MockLoginUsecase();
  final mockRegister = MockRegisterUsecase();
  final mockGetCurrentUser = MockGetCurrentUserUsecase();
  final mockIsLoggedIn = MockIsLoggedInUsecase();
  final mockLogout = MockLogoutUsecase();

  when(
    () => mockLogin(any()),
  ).thenAnswer((_) async => Left(const MockFailure('Invalid credentials')));

  when(() => mockRegister(any())).thenAnswer((_) async => const Right(true));

  when(() => mockGetCurrentUser()).thenAnswer(
    (_) async => Right(
      const AuthEntity(
        userId: '1',
        name: 'Test User',
        email: 'test@test.com',
        contact: '9800000000',
        address: 'Kathmandu',
      ),
    ),
  );

  when(() => mockIsLoggedIn()).thenAnswer((_) async => const Right(false));
  when(() => mockLogout()).thenAnswer((_) async => const Right(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(
          (ref) => AuthViewModel(
            loginUsecase: mockLogin,
            registerUsecase: mockRegister,
            getCurrentUserUsecase: mockGetCurrentUser,
            isLoggedInUsecase: mockIsLoggedIn,
            logoutUsecase: mockLogout,
          ),
        ),
      ],
      child: const MaterialApp(home: SignupPage()),
    ),
  );

  await tester.pumpAndSettle();
}
