import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/features/auth/domain/usecases/is_login_usecase.dart';

import '../../test_utils/mocks.dart';

void main() {
  test('calls repository isUserLoggedIn', () async {
    final repository = MockAuthRepository();
    final usecase = IsLoggedInUsecase(authRepository: repository);
    when(
      () => repository.isUserLoggedIn(),
    ).thenAnswer((_) async => const Right(true));

    final result = await usecase();

    expect(result, const Right(true));
    verify(() => repository.isUserLoggedIn()).called(1);
  });
}
