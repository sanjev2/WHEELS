import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:wheels_flutter/core/constants/hive_constants.dart';
import '../../domain/entities/batch_entity.dart';

part 'batch_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.batchTypeId)
class BatchHiveModel {
  @HiveField(0)
  final String? batchId;

  @HiveField(1)
  final String batchName;

  @HiveField(2)
  final String? status;

  BatchHiveModel({String? batchId, required this.batchName, String? status})
    : batchId = batchId ?? const Uuid().v4(),
      status = status ?? 'active';

  // Convert Model to Batch Entity
  BatchEntity toEntity() {
    return BatchEntity(batchId: batchId, batchName: batchName, status: status);
  }

  // Convert Batch Entity to Model
  factory BatchHiveModel.fromEntity(BatchEntity entity) {
    return BatchHiveModel(
      batchId: entity.batchId,
      batchName: entity.batchName,
      status: entity.status,
    );
  }

  // Convert List of Models to List of Batch Entities
  static List<BatchEntity> toEntityList(List<BatchHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
