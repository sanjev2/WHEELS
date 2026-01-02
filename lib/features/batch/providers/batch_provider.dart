import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/core/providers/providers.dart';
import 'package:wheels_flutter/features/batch/data/datasources/batch_datasource.dart';
import 'package:wheels_flutter/features/batch/data/datasources/local/batch_local_datasource.dart';
import 'package:wheels_flutter/features/batch/data/repositories/batch_repositories_impl.dart';
import 'package:wheels_flutter/features/batch/domain/repositories/batch_repository.dart';
import 'package:wheels_flutter/features/batch/domain/usecases/create_batch_usecase.dart';
import 'package:wheels_flutter/features/batch/domain/usecases/delete_batch_usecase.dart';
import 'package:wheels_flutter/features/batch/domain/usecases/get_all_batches.dart';
import 'package:wheels_flutter/features/batch/domain/usecases/get_batch_byid.dart';
import 'package:wheels_flutter/features/batch/domain/usecases/update_batch_usecase.dart';
import 'package:wheels_flutter/features/batch/presentation/state/batch_state.dart';
import 'package:wheels_flutter/features/batch/presentation/view_model/batch_view_model.dart';

final batchDataSourceProvider = Provider<IBatchDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return BatchLocalDatasource(hiveService: hiveService);
});

final batchRepositoryProvider = Provider<IBatchRepository>((ref) {
  final dataSource = ref.read(batchDataSourceProvider);
  return BatchRepositoryImpl(dataSource);
});

final getAllBatchUsecaseProvider = Provider<GetAllBatchUsecase>((ref) {
  final repository = ref.read(batchRepositoryProvider);
  return GetAllBatchUsecase(batchRepository: repository);
});

final getBatchByIdUsecaseProvider = Provider<GetBatchByIdUsecase>((ref) {
  return GetBatchByIdUsecase(ref.read(batchRepositoryProvider));
});

final createBatchUsecaseProvider = Provider<CreateBatchUsecase>((ref) {
  return CreateBatchUsecase(ref.read(batchRepositoryProvider));
});

final updateBatchUsecaseProvider = Provider<UpdateBatchUsecase>((ref) {
  return UpdateBatchUsecase(ref.read(batchRepositoryProvider));
});

final deleteBatchUsecaseProvider = Provider<DeleteBatchUsecase>((ref) {
  return DeleteBatchUsecase(ref.read(batchRepositoryProvider));
});

final batchViewModelProvider =
    StateNotifierProvider<BatchViewModel, BatchState>((ref) {
      return BatchViewModel(
        getAllBatchUsecase: ref.read(getAllBatchUsecaseProvider),
        getBatchByIdUsecase: ref.read(getBatchByIdUsecaseProvider),
        createBatchUsecase: ref.read(createBatchUsecaseProvider),
        updateBatchUsecase: ref.read(updateBatchUsecaseProvider),
        deleteBatchUsecase: ref.read(deleteBatchUsecaseProvider),
      );
    });

    // 
