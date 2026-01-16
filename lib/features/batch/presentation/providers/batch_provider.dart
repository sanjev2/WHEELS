import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/core/providers/providers.dart';
import 'package:wheels_flutter/features/batch/data/datasources/batch_datasource.dart';
import 'package:wheels_flutter/features/batch/data/datasources/local/batch_local_datasource.dart';
import 'package:wheels_flutter/features/batch/data/repositories/batch_repositories_impl.dart';
import 'package:wheels_flutter/features/batch/domain/repositories/batch_repository.dart';
import 'package:wheels_flutter/features/batch/presentation/view_model/batch_view_model.dart';
import 'package:wheels_flutter/features/batch/presentation/state/batch_state.dart';

/// ------------------
/// DataSource Provider
/// ------------------
final batchDataSourceProvider = Provider<IBatchDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return BatchLocalDatasource(hiveService: hiveService);
});

/// ------------------
/// Repository Provider
/// ------------------
final batchRepositoryProvider = Provider<IBatchRepository>((ref) {
  final dataSource = ref.read(batchDataSourceProvider);
  return BatchRepositoryImpl(dataSource: dataSource);
});

/// ------------------
/// ViewModel Provider (Notifier ONLY)
/// ------------------
final batchViewModelProvider = NotifierProvider<BatchViewModel, BatchState>(
  () => BatchViewModel(),
);
