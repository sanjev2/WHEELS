import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheels_flutter/core/services/storage/user_session.dart';

void main() {
  late SharedPreferences prefs;
  late UserSessionService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = UserSessionService(sharedPreferences: prefs);
  });

  test('isLoggedIn is false initially', () {
    expect(service.isLoggedIn(), false);
  });

  test('saveUserSession stores all user data', () async {
    await service.saveUserSession(
      userId: 'u1',
      email: 'test@example.com',
      name: 'Test User',
      contact: '9800000000',
      address: 'Kathmandu',
      profilePicture: 'profile.png',
    );

    expect(service.isLoggedIn(), true);
    expect(service.getUserId(), 'u1');
    expect(service.getEmail(), 'test@example.com');
    expect(service.getName(), 'Test User');
    expect(service.getContact(), '9800000000');
    expect(service.getAddress(), 'Kathmandu');
    expect(service.getProfilePicture(), 'profile.png');
  });

  test('saveUserSession removes empty profile picture', () async {
    await service.saveUserSession(
      userId: 'u1',
      email: 'test@example.com',
      name: 'Test User',
      contact: '9800000000',
      address: 'Kathmandu',
      profilePicture: '',
    );

    expect(service.getProfilePicture(), isNull);
  });

  test('saveProfilePicture updates only profile picture', () async {
    await service.saveProfilePicture('new_pic.png');

    expect(service.getProfilePicture(), 'new_pic.png');
  });

  test('clearSession removes all stored values', () async {
    await service.saveUserSession(
      userId: 'u1',
      email: 'test@example.com',
      name: 'Test User',
      contact: '9800000000',
      address: 'Kathmandu',
      profilePicture: 'profile.png',
    );

    await service.clearSession();

    expect(service.isLoggedIn(), false);
    expect(service.getUserId(), isNull);
    expect(service.getEmail(), isNull);
    expect(service.getName(), isNull);
    expect(service.getContact(), isNull);
    expect(service.getAddress(), isNull);
    expect(service.getProfilePicture(), isNull);
  });

  test('getUserData returns stored map', () async {
    await service.saveUserSession(
      userId: 'u1',
      email: 'test@example.com',
      name: 'Test User',
      contact: '9800000000',
      address: 'Kathmandu',
      profilePicture: 'profile.png',
    );

    final data = service.getUserData();

    expect(data['userId'], 'u1');
    expect(data['email'], 'test@example.com');
    expect(data['name'], 'Test User');
    expect(data['contact'], '9800000000');
    expect(data['address'], 'Kathmandu');
    expect(data['profilePicture'], 'profile.png');
  });
}
