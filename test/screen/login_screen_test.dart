import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/pump_login.dart';

void main() {
  testWidgets('Login screen renders correctly', (tester) async {
    await pumpLoginPage(tester);

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Login with Face/Fingerprint'), findsOneWidget);
  });

  testWidgets(
    'Login validation: empty email + empty password shows both errors',
    (tester) async {
      await pumpLoginPage(tester);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    },
  );

  testWidgets('Login validation: email required when password is filled', (
    tester,
  ) async {
    await pumpLoginPage(tester);

    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsNothing);
  });

  testWidgets('Login validation: password required when email is filled', (
    tester,
  ) async {
    await pumpLoginPage(tester);

    await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Email is required'), findsNothing);
  });

  testWidgets('Login screen toggles password visibility', (tester) async {
    await pumpLoginPage(tester);

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
}
