import 'package:flutter_test/flutter_test.dart';

import '../test utils/pump_login.dart';

void main() {
  testWidgets(
    'Login validation: empty email + empty password shows both errors',
    (tester) async {
      await pumpLoginPage(tester);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    },
  );
}
