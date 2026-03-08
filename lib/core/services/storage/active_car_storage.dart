import 'package:shared_preferences/shared_preferences.dart';

class ActiveCarStorage {
  ActiveCarStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyActiveCarId = 'active_car_id';

  String? getActiveCarId() => _prefs.getString(_keyActiveCarId);

  Future<void> setActiveCarId(String id) async {
    await _prefs.setString(_keyActiveCarId, id);
  }

  Future<void> clearActiveCarId() async {
    await _prefs.remove(_keyActiveCarId);
  }
}
