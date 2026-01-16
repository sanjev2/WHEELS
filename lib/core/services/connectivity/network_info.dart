// core/services/connectivity/network_info.dart
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(connectivity: Connectivity());
});

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({required Connectivity connectivity})
    : _connectivity = connectivity;

  @override
  Future<bool> get isConnected async {
    try {
      final result = await _connectivity.checkConnectivity();

      if (result == ConnectivityResult.none) {
        return false;
      }

      // Check actual internet connectivity
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        return await _checkIfInternetIsAvailable();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkIfInternetIsAvailable() async {
    try {
      final result = await InternetAddress.lookup(
        "google.com",
      ).timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
