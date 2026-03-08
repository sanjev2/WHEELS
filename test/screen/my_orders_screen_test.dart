import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';
import 'package:wheels_flutter/features/order/domain/usecases/get_order_usecase.dart';
import 'package:wheels_flutter/features/order/presentation/pages/my_order_page.dart';
import 'package:wheels_flutter/features/order/presentation/provider/order_provider.dart';

class MockGetMyOrdersUsecase extends Mock implements GetMyOrdersUsecase {}

OrderEntity makeOrder({String id = 'o1', String status = 'PAID'}) {
  return OrderEntity(
    id: id,
    packageTitle: 'Premium Wash',
    category: 'SUV',
    providerName: 'Garage A',
    totalPrice: 2500,
    status: status,
    createdAt: DateTime.parse('2025-01-10T10:00:00.000Z'),
    paidAt: null,
    transactionUuid: null,
    transactionCode: null,
  );
}

void main() {
  testWidgets('MyOrdersPage shows app bar and loaded content', (tester) async {
    final usecase = MockGetMyOrdersUsecase();

    when(() => usecase()).thenAnswer((_) async => Right([makeOrder()]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [getMyOrdersUsecaseProvider.overrideWithValue(usecase)],
        child: const MaterialApp(home: MyOrdersPage()),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Order history & status'), findsOneWidget);
    expect(find.text('Premium Wash'), findsOneWidget);
  });
}
