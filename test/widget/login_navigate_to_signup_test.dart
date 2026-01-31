import 'package:flutter_test/flutter_test.dart';

import '../test utils/pump_login.dart';

void main() {
  testWidgets('LoginPage: tapping Sign Up navigates to SignupPage', (
    tester,
  ) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // On signup screen
    expect(find.text("Let's get started!"), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
