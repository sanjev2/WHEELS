import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/booking/presentation/model/booking_draft.dart';
import '../../../../core/api/api_clients.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/esewa_initiate_entity.dart';

final esewaRemoteDatasourceProvider = Provider<EsewaRemoteDatasource>((ref) {
  return EsewaRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class EsewaRemoteDatasource {
  final ApiClient _apiClient;

  EsewaRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<EsewaInitiateEntity> initiateEsewaPayment(BookingDraft draft) async {
    final res = await _apiClient.post(
      ApiEndpoints.EsewaInitiate,
      data: {
        "client": "mobile",

        "total_amount": draft.totalPrice.toString(),
        "booking": {
          "carId": draft.carId,
          "packageId": draft.packageId,
          "packageTitle": draft.packageTitle,
          "category": draft.category,
          "basePrice": draft.basePrice,
          "durationMins": draft.durationMins,
          "selectedOilType": draft.selectedOilType,
          "selectedAddons": draft.selectedAddons,
          "providerId": draft.providerId,
          "providerName": draft.providerName,
          "totalPrice": draft.totalPrice,
        },
      },
    );

    if (res.data is Map && res.data["success"] == true) {
      final data = Map<String, dynamic>.from(res.data["data"]);

      final fieldsRaw = Map<String, dynamic>.from(data["fields"]);
      final fields = <String, String>{};
      fieldsRaw.forEach((key, value) => fields[key] = value.toString());

      return EsewaInitiateEntity(
        orderId: data["orderId"].toString(),
        transactionUuid: data["transaction_uuid"].toString(),
        esewaUrl: data["esewaUrl"].toString(),
        fields: fields,
      );
    }

    throw Exception(res.data["message"] ?? "Esewa initiate failed");
  }
}
