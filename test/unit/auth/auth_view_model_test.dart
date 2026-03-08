import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:wheels_flutter/features/auth/presentation/view_model/auth_view_model.dart';

import '../../test_utils/mocks.dart';

void main() {
  late MockLoginUsecase loginUsecase;
  late MockRegisterUsecase registerUsecase;
  late MockGetCurrentUserUsecase getCurrentUserUsecase;
  late MockIsLoggedInUsecase isLoggedInUsecase;
  late MockLogoutUsecase logoutUsecase;
  late AuthViewModel viewModel;

  setUpAll(registerTestFallbacks);

  setUp(() {
    loginUsecase = MockLoginUsecase();
    registerUsecase = MockRegisterUsecase();
    getCurrentUserUsecase = MockGetCurrentUserUsecase();
    isLoggedInUsecase = MockIsLoggedInUsecase();
    logoutUsecase = MockLogoutUsecase();
    viewModel = AuthViewModel(
      loginUsecase: loginUsecase,
      registerUsecase: registerUsecase,
      getCurrentUserUsecase: getCurrentUserUsecase,
      isLoggedInUsecase: isLoggedInUsecase,
      logoutUsecase: logoutUsecase,
    );
  });

  test('initial state is initial', () {
    expect(viewModel.state, const AuthState());
  });

  test('init -> unauthenticated when user not logged in', () async {
    when(() => isLoggedInUsecase()).thenAnswer((_) async => const Right(false));

    await viewModel.init();

    expect(viewModel.state.status, AuthStatus.unauthenticated);
    expect(viewModel.state.authEntity, isNull);
    expect(viewModel.state.errorMessage, isNull);
    verify(() => isLoggedInUsecase()).called(1);
    verifyNever(() => getCurrentUserUsecase());
  });

  test('init -> authenticated when logged in and current user loads', () async {
    final user = makeAuthEntity();
    when(() => isLoggedInUsecase()).thenAnswer((_) async => const Right(true));
    when(() => getCurrentUserUsecase()).thenAnswer((_) async => Right(user));

    await viewModel.init();

    expect(viewModel.state.status, AuthStatus.authenticated);
    expect(viewModel.state.authEntity, user);
    expect(viewModel.state.errorMessage, isNull);
  });

  test('login failure -> error state', () async {
    when(
      () => loginUsecase(any()),
    ).thenAnswer((_) async => Left(AuthFailure(message: 'bad creds')));

    await viewModel.login(email: 'a@b.com', password: '123456');

    expect(viewModel.state.status, AuthStatus.error);
    expect(viewModel.state.errorMessage, 'bad creds');
  });

  test('login success -> init runs and authenticates', () async {
    final user = makeAuthEntity();
    when(() => loginUsecase(any())).thenAnswer((_) async => Right(user));
    when(() => isLoggedInUsecase()).thenAnswer((_) async => const Right(true));
    when(() => getCurrentUserUsecase()).thenAnswer((_) async => Right(user));

    await viewModel.login(email: 'a@b.com', password: '123456');

    verify(() => loginUsecase(any())).called(1);
    verify(() => isLoggedInUsecase()).called(1);
    verify(() => getCurrentUserUsecase()).called(1);
    expect(viewModel.state.status, AuthStatus.authenticated);
  });

  test('register success true -> registered state', () async {
    when(
      () => registerUsecase(any()),
    ).thenAnswer((_) async => const Right(true));

    await viewModel.register(
      name: 'Test',
      email: 'test@test.com',
      password: '123456',
      contact: '9800',
      address: 'KTM',
    );

    expect(viewModel.state.status, AuthStatus.registered);
    expect(viewModel.state.errorMessage, isNull);
  });

  test('register success false -> error state', () async {
    when(
      () => registerUsecase(any()),
    ).thenAnswer((_) async => const Right(false));

    await viewModel.register(
      name: 'Test',
      email: 'test@test.com',
      password: '123456',
      contact: '9800',
      address: 'KTM',
    );

    expect(viewModel.state.status, AuthStatus.error);
    expect(viewModel.state.errorMessage, 'Registration failed');
  });

  test('logout success clears user', () async {
    when(() => logoutUsecase()).thenAnswer((_) async => const Right(null));

    await viewModel.logout();

    expect(viewModel.state.status, AuthStatus.unauthenticated);
    expect(viewModel.state.authEntity, isNull);
  });
}
