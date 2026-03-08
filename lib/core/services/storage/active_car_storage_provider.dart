import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/core/services/storage/shared_pref_provider.dart';
import 'package:wheels_flutter/core/services/storage/active_car_storage.dart';

final activeCarStorageProvider = Provider<ActiveCarStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ActiveCarStorage(prefs);
});
