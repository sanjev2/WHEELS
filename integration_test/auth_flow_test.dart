import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/test_utils/pump_signup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('auth flow: signup validation mismatch password', (tester) async {
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
