import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import '../test utils/pump_login.dart';

void main() {
  testWidgets('Login validation: email required when password is filled', (
    tester,
  ) async {
    await pumpLoginPage(tester);

    // Fill password only
    await tester.enterText(find.byType(TextFormField).last, '123456');

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsNothing);
  });
}
