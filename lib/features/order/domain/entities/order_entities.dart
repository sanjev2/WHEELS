import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
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

  const OrderEntity({
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

  @override
  List<Object?> get props => [
    id,
    packageTitle,
    category,
    providerName,
    totalPrice,
    status,
    createdAt,
    paidAt,
    transactionUuid,
    transactionCode,
  ];
}
