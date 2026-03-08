import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:wheels_flutter/features/auth/data/models/auth_api_model.dart';

import '../../test_utils/mocks.dart';

void main() {
  late MockApiClient apiClient;
  late MockUserSessionService userSession;
  late AuthRemoteDatasource datasource;

  setUpAll(() {
    registerTestFallbacks();
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    apiClient = MockApiClient();
    userSession = MockUserSessionService();
    datasource = AuthRemoteDatasource(
      apiClient: apiClient,
      userSessionService: userSession,
    );

    when(
      () => userSession.saveUserSession(
        userId: any(named: 'userId'),
        email: any(named: 'email'),
        name: any(named: 'name'),
        contact: any(named: 'contact'),
        address: any(named: 'address'),
      ),
    ).thenAnswer((_) async {});

    when(() => userSession.saveProfilePicture(any())).thenAnswer((_) async {});
    when(() => userSession.clearSession()).thenAnswer((_) async {});
  });

  test('login extracts token and user, saves session', () async {
    when(
      () => apiClient.post(
        any(),
        data: any(named: 'data'),
        option: any(named: 'option'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/login'),
        data: {
          'success': true,
          'token': 'abc123',
          'user': {
            '_id': 'u1',
            'name': 'Test',
            'email': 'test@test.com',
            'contact': '9800',
            'address': 'KTM',
            'role': 'user',
          },
        },
      ),
    );

    final result = await datasource.login('  TEST@TEST.COM ', '123456');

    expect(result, isA<AuthApiModel>());
    verify(
      () => userSession.saveUserSession(
        userId: any(named: 'userId'),
        email: 'test@test.com',
        name: 'Test',
        contact: '9800',
        address: 'KTM',
      ),
    ).called(1);
  });

  test('getMe throws when token missing', () async {
    expect(datasource.getMe(), throwsA(isA<Exception>()));
  });

  test('logout clears session', () async {
    await datasource.logout();
    verify(() => userSession.clearSession()).called(1);
  });
}
