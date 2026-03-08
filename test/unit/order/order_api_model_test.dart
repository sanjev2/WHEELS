import 'package:flutter_test/flutter_test.dart';
import 'package:wheels_flutter/features/order/data/model/order_api_model.dart';

void main() {
  group('OrderApiModel', () {
    test('fromJson parses valid json correctly', () {
      final json = {
        "_id": "o1",
        "packageTitle": "Premium Wash",
        "category": "SUV",
        "providerName": "Garage A",
        "totalPrice": 2500,
        "status": "PAID",
        "createdAt": "2025-01-10T10:00:00.000Z",
        "paidAt": "2025-01-10T10:30:00.000Z",
        "transaction_uuid": "uuid123",
        "transaction_code": "txn123",
      };

      final model = OrderApiModel.fromJson(json);

      expect(model.id, "o1");
      expect(model.packageTitle, "Premium Wash");
      expect(model.category, "SUV");
      expect(model.providerName, "Garage A");
      expect(model.totalPrice, 2500);
      expect(model.status, "PAID");
      expect(model.transactionUuid, "uuid123");
      expect(model.transactionCode, "txn123");
      expect(model.paidAt, isNotNull);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        "_id": "o2",
        "packageTitle": "Basic Wash",
        "category": "SEDAN",
        "providerName": "Garage B",
        "totalPrice": "1500",
        "createdAt": "",
      };

      final model = OrderApiModel.fromJson(json);

      expect(model.id, "o2");
      expect(model.status, "PENDING_PAYMENT");
      expect(model.totalPrice, 1500.0);
      expect(model.paidAt, isNull);
      expect(model.transactionUuid, isNull);
      expect(model.transactionCode, isNull);
    });

    test('toEntity maps correctly', () {
      final model = OrderApiModel(
        id: "o3",
        packageTitle: "Detailing",
        category: "HATCHBACK",
        providerName: "Garage C",
        totalPrice: 3200,
        status: "COMPLETED",
        createdAt: DateTime.parse("2025-01-01T00:00:00.000Z"),
        paidAt: null,
        transactionUuid: null,
        transactionCode: null,
      );

      final entity = model.toEntity();

      expect(entity.id, "o3");
      expect(entity.packageTitle, "Detailing");
      expect(entity.status, "COMPLETED");
      expect(entity.totalPrice, 3200);
    });
  });
}
