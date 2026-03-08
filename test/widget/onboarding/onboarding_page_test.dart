import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:wheels_flutter/features/onboarding/onboarding_page.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wheels_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:wheels_flutter/core/services/storage/onboarding_storage.dart';

import '../../test_utils/mocks.dart';

class MockOnboardingStorage extends Mock implements OnboardingStorage {}

void main() {
  setUpAll(() {
    registerTestFallbacks();
  });

  testWidgets('Onboarding renders and Skip navigates', (tester) async {
    final mockLogin = MockLoginUsecase();
    final mockRegister = MockRegisterUsecase();
    final mockGetCurrentUser = MockGetCurrentUserUsecase();
    final mockIsLoggedIn = MockIsLoggedInUsecase();
    final mockLogout = MockLogoutUsecase();
    final mockStorage = MockOnboardingStorage();

    when(() => mockStorage.markSeen()).thenAnswer((_) async {});
    when(() => mockIsLoggedIn()).thenAnswer((_) async => const Right(false));
    when(
      () => mockGetCurrentUser(),
    ).thenAnswer((_) async => Right(makeAuthEntity()));
    when(
      () => mockLogin(any()),
    ).thenAnswer((_) async => Right(makeAuthEntity()));
    when(() => mockRegister(any())).thenAnswer((_) async => const Right(true));
    when(() => mockLogout()).thenAnswer((_) async => const Right(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingStorageProvider.overrideWithValue(mockStorage),
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
        child: const MaterialApp(home: OnboardingPage()),
      ),
    );

    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    verify(() => mockStorage.markSeen()).called(1);
    expect(find.text('Welcome back!'), findsOneWidget);
  });
}
