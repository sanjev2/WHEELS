import 'package:hive_flutter/hive_flutter.dart';
import 'package:wheels_flutter/features/trip/data/trip_hive_model.dart';

import '../../../core/constants/hive_constants.dart';

import '../../../features/auth/data/models/auth_hive_model.dart';
import '../../../features/batch/data/models/batch_hive_model.dart';
import '../../../features/car/data/models/car_hive_model.dart';

class HiveService {
  bool _isInitialized = false;

  late Box<AuthHiveModel> _userBox;
  late Box<BatchHiveModel> _batchBox;
  late Box<CarHiveModel> _carBox;
  late Box<TripHiveModel> _tripBox;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.batchTypeId)) {
      Hive.registerAdapter(BatchHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.carTypeId)) {
      Hive.registerAdapter(CarHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.tripTypeId)) {
      Hive.registerAdapter(TripHiveModelAdapter());
    }

    _userBox = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    _batchBox = await Hive.openBox<BatchHiveModel>(
      HiveTableConstant.batchTable,
    );
    _carBox = await Hive.openBox<CarHiveModel>(HiveTableConstant.carTable);
    _tripBox = await Hive.openBox<TripHiveModel>(HiveTableConstant.tripTable);

    _isInitialized = true;
    // ignore: avoid_print
    print("✅ HiveService initialized");
  }

  Box<AuthHiveModel> get userBox => _userBox;
  Box<BatchHiveModel> get batchBox => _batchBox;
  Box<CarHiveModel> get carBox => _carBox;
  Box<TripHiveModel> get tripBox => _tripBox;
}
