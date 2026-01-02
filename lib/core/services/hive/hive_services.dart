import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/auth/data/models/auth_hive_model.dart';
import '../../../features/batch/data/models/batch_hive_model.dart';
import '../../../core/constants/hive_constants.dart';

class HiveService {
  bool _isInitialized = false; // internal flag

  late Box<AuthHiveModel> _userBox;
  late Box<BatchHiveModel> _batchBox;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BatchHiveModelAdapter());
    }

    // Open boxes
    _userBox = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    _batchBox = await Hive.openBox<BatchHiveModel>(
      HiveTableConstant.batchTable,
    );

    _isInitialized = true;
    print('✅ HiveService initialized successfully');
  }

  // Getter for Auth/User Box
  Box<AuthHiveModel> get userBox => _userBox;

  // Getter for Batch Box
  Box<BatchHiveModel> get batchBox => _batchBox;
}
