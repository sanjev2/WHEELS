import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';

class OrderApiModel {
  final String id;

  final String packageTitle;
  final String category;
  final String providerName;
  final double totalPrice;

  final String status;
  final DateTime createdAt;
  final DateTime? paidAt;

  final String? transactionUuid;
  final String? transactionCode;

  OrderApiModel({
    required this.id,
    required this.packageTitle,
    required this.category,
    required this.providerName,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.paidAt,
    required this.transactionUuid,
    required this.transactionCode,
  });

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      final s = v?.toString();
      if (s == null || s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return OrderApiModel(
      id: (json["_id"] ?? json["id"]).toString(),
      packageTitle: (json["packageTitle"] ?? "").toString(),
      category: (json["category"] ?? "").toString(),
      providerName: (json["providerName"] ?? "").toString(),
      totalPrice: (json["totalPrice"] is num)
          ? (json["totalPrice"] as num).toDouble()
          : double.tryParse(json["totalPrice"].toString()) ?? 0.0,
      status: (json["status"] ?? "PENDING_PAYMENT").toString(),
      createdAt: parseDate(json["createdAt"]) ?? DateTime.now(),
      paidAt: parseDate(json["paidAt"]),
      transactionUuid: json["transaction_uuid"]?.toString(),
      transactionCode: json["transaction_code"]?.toString(),
    );
  }

  OrderEntity toEntity() => OrderEntity(
    id: id,
    packageTitle: packageTitle,
    category: category,
    providerName: providerName,
    totalPrice: totalPrice,
    status: status,
    createdAt: createdAt,
    paidAt: paidAt,
    transactionUuid: transactionUuid,
    transactionCode: transactionCode,
  );
}
