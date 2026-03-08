import 'package:equatable/equatable.dart';

class EsewaInitiateEntity extends Equatable {
  final String orderId;
  final String transactionUuid;
  final String esewaUrl;
  final Map<String, String> fields;

  const EsewaInitiateEntity({
    required this.orderId,
    required this.transactionUuid,
    required this.esewaUrl,
    required this.fields,
  });

  @override
  List<Object?> get props => [orderId, transactionUuid, esewaUrl, fields];
}
