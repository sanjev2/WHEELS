import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_login.dart';

void main() {
  testWidgets('LoginPage renders basic UI', (tester) async {
    await pumpLoginPage(tester);

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('shows both validators when empty', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (tester) async {
    await pumpLoginPage(tester);

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
}
