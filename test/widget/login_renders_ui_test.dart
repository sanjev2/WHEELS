import 'package:flutter_test/flutter_test.dart';

import '../test utils/pump_login.dart';

void main() {
  testWidgets('LoginPage: renders basic UI', (tester) async {
    await pumpLoginPage(tester);

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
