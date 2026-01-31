import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import '../test utils/pump_signup.dart';

void main() {
  testWidgets('Signup validation: mismatch password shows error', (
    tester,
  ) async {
    await pumpSignupPage(tester);

    final fields = find.byType(TextFormField);

    // name, email, contact, address, password, confirm password
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test@test.com');
    await tester.enterText(fields.at(2), '9800000000');
    await tester.enterText(fields.at(3), 'Kathmandu');
    await tester.enterText(fields.at(4), '123456');
    await tester.enterText(fields.at(5), '654321'); // mismatch

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
