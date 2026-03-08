import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/core/services/connectivity/network_info.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity connectivity;
  late NetworkInfo networkInfo;

  setUp(() {
    connectivity = MockConnectivity();
    networkInfo = NetworkInfo(connectivity: connectivity);
  });

  test('returns false when connectivity is none', () async {
    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => ConnectivityResult.none);

    final result = await networkInfo.isConnected;

    expect(result, false);
  });

  test('returns false when connectivity throws', () async {
    when(() => connectivity.checkConnectivity()).thenThrow(Exception('fail'));

    final result = await networkInfo.isConnected;

    expect(result, false);
  });
}
