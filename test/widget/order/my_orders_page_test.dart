import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';
import 'package:wheels_flutter/features/order/domain/usecases/get_order_usecase.dart';
import 'package:wheels_flutter/features/order/presentation/pages/my_order_page.dart';
import 'package:wheels_flutter/features/order/presentation/provider/order_provider.dart';

class MockGetMyOrdersUsecase extends Mock implements GetMyOrdersUsecase {}

OrderEntity makeOrder({
  String id = 'o1',
  String packageTitle = 'Premium Wash',
  String category = 'SUV',
  String providerName = 'Garage A',
  double totalPrice = 2500,
  String status = 'PAID',
}) {
  return OrderEntity(
    id: id,
    packageTitle: packageTitle,
    category: category,
    providerName: providerName,
    totalPrice: totalPrice,
    status: status,
    createdAt: DateTime.parse('2025-01-10T10:00:00.000Z'),
    paidAt: null,
    transactionUuid: null,
    transactionCode: null,
  );
}

Future<void> pumpOrdersPage(
  WidgetTester tester, {
  required MockGetMyOrdersUsecase usecase,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [getMyOrdersUsecaseProvider.overrideWithValue(usecase)],
      child: const MaterialApp(home: MyOrdersPage()),
    ),
  );

  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows empty state when no orders', (tester) async {
    final usecase = MockGetMyOrdersUsecase();

    when(() => usecase()).thenAnswer((_) async => const Right([]));

    await pumpOrdersPage(tester, usecase: usecase);

    expect(find.text('No orders yet'), findsOneWidget);
  });

  testWidgets('shows error state on failure', (tester) async {
    final usecase = MockGetMyOrdersUsecase();

    when(
      () => usecase(),
    ).thenAnswer((_) async => Left(ApiFailure(message: 'Failed to load')));

    await pumpOrdersPage(tester, usecase: usecase);

    expect(find.text("Couldn’t load your orders"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows loaded orders', (tester) async {
    final usecase = MockGetMyOrdersUsecase();

    when(() => usecase()).thenAnswer(
      (_) async => Right([
        makeOrder(packageTitle: 'Premium Wash', status: 'PAID'),
        makeOrder(
          id: 'o2',
          packageTitle: 'Interior Clean',
          status: 'COMPLETED',
        ),
      ]),
    );

    await pumpOrdersPage(tester, usecase: usecase);

    expect(find.text('Premium Wash'), findsOneWidget);
    expect(find.text('Interior Clean'), findsOneWidget);
    expect(find.text('Your Orders'), findsWidgets);
  });

  testWidgets('search filters orders', (tester) async {
    final usecase = MockGetMyOrdersUsecase();

    when(() => usecase()).thenAnswer(
      (_) async => Right([
        makeOrder(packageTitle: 'Premium Wash'),
        makeOrder(id: 'o2', packageTitle: 'Interior Clean'),
      ]),
    );

    await pumpOrdersPage(tester, usecase: usecase);

    await tester.enterText(find.byType(TextField), 'Interior');
    await tester.pumpAndSettle();

    expect(find.text('Interior Clean'), findsOneWidget);
    expect(find.text('Premium Wash'), findsNothing);
  });

  testWidgets('filter chip filters completed orders', (tester) async {
    final usecase = MockGetMyOrdersUsecase();

    when(() => usecase()).thenAnswer(
      (_) async => Right([
        makeOrder(packageTitle: 'Premium Wash', status: 'PAID'),
        makeOrder(
          id: 'o2',
          packageTitle: 'Interior Clean',
          status: 'COMPLETED',
        ),
      ]),
    );

    await pumpOrdersPage(tester, usecase: usecase);

    await tester.tap(find.text('Completed').last);
    await tester.pumpAndSettle();

    expect(find.text('Interior Clean'), findsOneWidget);
    expect(find.text('Premium Wash'), findsNothing);
  });
}
