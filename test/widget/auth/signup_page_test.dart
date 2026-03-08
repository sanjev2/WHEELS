import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_signup.dart';

void main() {
  testWidgets('SignupPage renders basic UI', (tester) async {
    await pumpSignupPage(tester);

    expect(find.text("Let's get started!"), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
  });

  testWidgets('Signup validation shows required errors', (tester) async {
    await pumpSignupPage(tester);

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Contact number is required'), findsOneWidget);
    expect(find.text('Address is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
  });

  testWidgets('Signup mismatch password shows error', (tester) async {
    await pumpSignupPage(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test@test.com');
    await tester.enterText(fields.at(2), '9800000000');
    await tester.enterText(fields.at(3), 'Kathmandu');
    await tester.enterText(fields.at(4), '123456');
    await tester.enterText(fields.at(5), '654321');

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
