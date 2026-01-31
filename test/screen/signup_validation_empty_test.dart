import 'package:flutter_test/flutter_test.dart';

import '../test utils/pump_signup.dart';

void main() {
  testWidgets('Signup validation: empty fields show required errors', (
    tester,
  ) async {
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
}
