import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/booking/domain/usecases/get_esewa_initiate_usecase.dart';
import 'package:wheels_flutter/features/booking/presentation/model/booking_draft.dart';
import 'package:wheels_flutter/features/booking/presentation/providers/booking_provoder.dart';
import 'package:wheels_flutter/features/booking/presentation/view%20model/booking_view_model.dart';
import 'package:wheels_flutter/features/provider/domain/usecases/get_provider_usecase.dart';
import 'package:wheels_flutter/features/provider/presentation/page/select_provider_page.dart';
import 'package:wheels_flutter/features/provider/presentation/providers/provider_provider.dart';
import 'package:wheels_flutter/features/provider/presentation/view%20model/provider_viewmodel.dart';

import '../test_utils/mocks.dart';

class MockGetProvidersUsecase extends Mock implements GetProvidersUsecase {}

class MockInitiateEsewaUsecase extends Mock implements InitiateEsewaUsecase {}

void main() {
  setUpAll(() {
    registerTestFallbacks();
  });
  testWidgets('provider screen shows no providers state', (tester) async {
    final providerUsecase = MockGetProvidersUsecase();
    final bookingUsecase = MockInitiateEsewaUsecase();
    final bookingVm = BookingViewModel(initiateEsewa: bookingUsecase)
      ..startDraft(
        const BookingDraft(
          carId: 'car1',
          category: 'SUV',
          packageId: 'p1',
          packageTitle: 'Premium',
          basePrice: 2500,
          durationMins: 45,
          selectedOilType: '5W30',
          selectedAddons: [],
          providerId: null,
          providerName: null,
        ),
      );

    when(() => providerUsecase('SUV')).thenAnswer((_) async => const Right([]));
    when(
      () => bookingUsecase(any()),
    ).thenAnswer((_) async => const Left(ApiFailure(message: 'unused')));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getProvidersUsecaseProvider.overrideWithValue(providerUsecase),
          providerViewModelProvider.overrideWith(
            (ref) => ProviderViewModel(usecase: providerUsecase),
          ),
          initiateEsewaUsecaseProvider.overrideWithValue(bookingUsecase),
          bookingViewModelProvider.overrideWith((ref) => bookingVm),
        ],
        child: const MaterialApp(home: ProviderSelectPage(category: 'SUV')),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('No providers found'), findsOneWidget);
  });
}
