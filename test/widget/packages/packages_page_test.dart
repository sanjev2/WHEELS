import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/booking/domain/entities/esewa_initiate_entity.dart';
import 'package:wheels_flutter/features/booking/domain/usecases/get_esewa_initiate_usecase.dart';
import 'package:wheels_flutter/features/booking/presentation/providers/booking_provoder.dart';
import 'package:wheels_flutter/features/booking/presentation/view%20model/booking_view_model.dart';
import 'package:wheels_flutter/features/packages/domain/usecases/get_package_usecase.dart';
import 'package:wheels_flutter/features/packages/presentation/page/package.presentation.dart';
import 'package:wheels_flutter/features/packages/presentation/provider/package_provider.dart';
import 'package:wheels_flutter/features/packages/presentation/view%20model/package_view_model.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

import '../../test_utils/mocks.dart';

class MockGetPackagesUsecase extends Mock implements GetPackagesUsecase {}

class MockInitiateEsewaUsecase extends Mock implements InitiateEsewaUsecase {}

void main() {
  setUpAll(() {
    registerTestFallbacks();
  });
  late MockGetPackagesUsecase packageUsecase;
  late MockInitiateEsewaUsecase bookingUsecase;

  setUp(() {
    packageUsecase = MockGetPackagesUsecase();
    bookingUsecase = MockInitiateEsewaUsecase();
  });

  Widget buildWidget() {
    return ProviderScope(
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
        home: PackagesPage(carId: 'car1', category: 'SUV'),
      ),
    );
  }

  testWidgets('shows package data when loaded', (tester) async {
    when(() => packageUsecase('SUV')).thenAnswer(
      (_) async => const Right([
        PackageEntity(
          id: 'p1',
          title: 'Premium Package',
          description: 'desc',
          category: 'SUV',
          price: 2500,
          durationMins: 45,
          engineOilTypes: ['5W30'],
          services: ['Wash'],
          addons: ['Wax'],
          isActive: true,
        ),
      ]),
    );
    when(
      () => bookingUsecase(any()),
    ).thenAnswer((_) async => const Left(ApiFailure(message: 'unused')));

    await tester.pumpWidget(buildWidget());
    await tester.pump();
    await tester.pump();

    expect(find.text('Choose a package'), findsOneWidget);
    expect(find.text('Premium Package'), findsOneWidget);
    expect(find.textContaining('Rs 2500'), findsOneWidget);
  });

  testWidgets('shows empty state when no packages', (tester) async {
    when(() => packageUsecase('SUV')).thenAnswer((_) async => const Right([]));
    when(
      () => bookingUsecase(any()),
    ).thenAnswer((_) async => const Left(ApiFailure(message: 'unused')));

    await tester.pumpWidget(buildWidget());
    await tester.pump();
    await tester.pump();

    expect(find.text('No packages found'), findsOneWidget);
  });

  testWidgets('tapping package opens oil and addon sheet', (tester) async {
    when(() => packageUsecase('SUV')).thenAnswer(
      (_) async => const Right([
        PackageEntity(
          id: 'p1',
          title: 'Premium Package',
          description: 'desc',
          category: 'SUV',
          price: 2500,
          durationMins: 45,
          engineOilTypes: ['5W30'],
          services: ['Wash'],
          addons: ['Wax'],
          isActive: true,
        ),
      ]),
    );
    when(
      () => bookingUsecase(any()),
    ).thenAnswer((_) async => const Left(ApiFailure(message: 'unused')));

    await tester.pumpWidget(buildWidget());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Premium Package'));
    await tester.pumpAndSettle();

    expect(find.text('Select one engine oil'), findsOneWidget);
    expect(find.text('5W30'), findsOneWidget);
  });
}
