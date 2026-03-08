import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/booking/domain/usecases/get_esewa_initiate_usecase.dart';
import 'package:wheels_flutter/features/booking/presentation/providers/booking_provoder.dart';
import 'package:wheels_flutter/features/booking/presentation/view%20model/booking_view_model.dart';
import 'package:wheels_flutter/features/packages/domain/usecases/get_package_usecase.dart';
import 'package:wheels_flutter/features/packages/presentation/page/package.presentation.dart';
import 'package:wheels_flutter/features/packages/presentation/provider/package_provider.dart';
import 'package:wheels_flutter/features/packages/presentation/view%20model/package_view_model.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

import '../test_utils/mocks.dart';

class MockGetPackagesUsecase extends Mock implements GetPackagesUsecase {}

class MockInitiateEsewaUsecase extends Mock implements InitiateEsewaUsecase {}

void main() {
  setUpAll(() {
    registerTestFallbacks();
  });
  testWidgets('packages screen shows retry on failure', (tester) async {
    final packageUsecase = MockGetPackagesUsecase();
    final bookingUsecase = MockInitiateEsewaUsecase();

    when(
      () => packageUsecase('SUV'),
    ).thenAnswer((_) async => const Left(ApiFailure(message: 'network')));
    when(
      () => bookingUsecase(any()),
    ).thenAnswer((_) async => const Left(ApiFailure(message: 'unused')));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getPackagesUsecaseProvider.overrideWithValue(packageUsecase),
          packageViewModelProvider.overrideWith(
            (ref) => PackageViewModel(usecase: packageUsecase),
          ),
          initiateEsewaUsecaseProvider.overrideWithValue(bookingUsecase),
          bookingViewModelProvider.overrideWith(
            (ref) => BookingViewModel(initiateEsewa: bookingUsecase),
          ),
        ],
        child: const MaterialApp(
          home: PackagesPage(carId: 'c1', category: 'SUV'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Couldn’t load packages'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
