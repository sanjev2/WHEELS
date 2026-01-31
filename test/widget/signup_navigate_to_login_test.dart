import 'package:flutter_test/flutter_test.dart';

import '../test utils/pump_signup.dart';

void main() {
  testWidgets('SignupPage: tapping Login navigates to LoginPage', (
    tester,
  ) async {
    await pumpSignupPage(tester);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Back on login screen
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
