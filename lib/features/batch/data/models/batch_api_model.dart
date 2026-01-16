import 'package:wheels_flutter/features/batch/domain/entities/batch_entity.dart';

class BatchApiModel {
  final String? batchId;
  final String batchName;
  final String? status;
  final DateTime? createdAt;

  BatchApiModel({
    this.batchId,
    required this.batchName,
    this.status,
    this.createdAt,
  });

  // To JSON
  Map<String, dynamic> toJson() {
    return {"batchName": batchName, "status": status};
  }

  // From JSON
  factory BatchApiModel.fromJson(Map<String, dynamic> json) {
    return BatchApiModel(
      batchId: json["_id"] as String,
      batchName: json["batchName"] as String,
      status: json["status"] as String?,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"] as String)
          : null,
    );
  }

  // To entity
  BatchEntity toEntity() {
    return BatchEntity(batchId: batchId, batchName: batchName, status: status);
  }

  // From entity
  factory BatchApiModel.fromEntity(BatchEntity entity) {
    return BatchApiModel(
      batchId: entity.batchId,
      batchName: entity.batchName,
      status: entity.status,
    );
  }

  // To entity list
  static List<BatchEntity> toEntityList(List<BatchApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
