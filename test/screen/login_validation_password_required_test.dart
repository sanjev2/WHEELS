import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import '../test utils/pump_login.dart';

void main() {
  testWidgets('Login validation: password required when email is filled', (
    tester,
  ) async {
    await pumpLoginPage(tester);

    // Fill email only
    await tester.enterText(find.byType(TextFormField).first, 'test@test.com');

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Email is required'), findsNothing);
  });
}
