import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/features/auth/domain/usecases/get_current_users.dart';

import '../../test_utils/mocks.dart';

void main() {
  test('calls repository getCurrentUser', () async {
    final repository = MockAuthRepository();
    final user = makeAuthEntity();
    final usecase = GetCurrentUserUsecase(authRepository: repository);
    when(() => repository.getCurrentUser()).thenAnswer((_) async => Right(user));

    final result = await usecase();

    expect(result, Right(user));
    verify(() => repository.getCurrentUser()).called(1);
  });
}
