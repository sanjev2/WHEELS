import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/core/services/hive/hive_services.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
//
