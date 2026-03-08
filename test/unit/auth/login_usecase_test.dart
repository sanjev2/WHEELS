import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/login_usecases.dart';

import '../../test_utils/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late LoginUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: repository);
  });

  test('forwards login params to repository', () async {
    final user = makeAuthEntity();
    when(
      () => repository.login('test@test.com', '123456'),
    ).thenAnswer((_) async => Right(user));

    final result = await usecase(
      const LoginParams(email: 'test@test.com', password: '123456'),
    );

    expect(result, Right(user));
    verify(() => repository.login('test@test.com', '123456')).called(1);
  });

  test('returns repository failure unchanged', () async {
    final failure = AuthFailure(message: 'oops');
    when(
      () => repository.login(any(), any()),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase(const LoginParams(email: 'a', password: 'b'));

    expect(result, Left(failure));
  });
}
