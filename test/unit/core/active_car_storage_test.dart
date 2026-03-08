import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheels_flutter/core/services/storage/active_car_storage.dart';

void main() {
  late SharedPreferences prefs;
  late ActiveCarStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = ActiveCarStorage(prefs);
  });

  test('getActiveCarId returns null initially', () {
    expect(storage.getActiveCarId(), isNull);
  });

  test('setActiveCarId stores value', () async {
    await storage.setActiveCarId('car_1');

    expect(storage.getActiveCarId(), 'car_1');
  });

  test('clearActiveCarId removes value', () async {
    await storage.setActiveCarId('car_1');
    await storage.clearActiveCarId();

    expect(storage.getActiveCarId(), isNull);
  });
}
