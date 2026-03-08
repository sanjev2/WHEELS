import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

class TripTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _sub;
  Position? _last;
  double _distanceMeters = 0.0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _sub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 5,
          ),
        ).listen((pos) {
          if (pos.accuracy > 50) return;

          if (_last != null) {
            final d = Geolocator.distanceBetween(
              _last!.latitude,
              _last!.longitude,
              pos.latitude,
              pos.longitude,
            );

            if (d >= 1 && d <= 200) {
              _distanceMeters += d;
            }
          }

          _last = pos;

          FlutterForegroundTask.sendDataToMain({
            "type": "distance",
            "distanceMeters": _distanceMeters,
          });
        });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _sub?.cancel();
    _sub = null;
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map && data["type"] == "reset") {
      _distanceMeters = 0.0;
      _last = null;
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/");
  }
}

@pragma('vm:entry-point')
void startTripTaskHandler() {
  FlutterForegroundTask.setTaskHandler(TripTaskHandler());
}
