import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test utils/pump_login.dart';

void main() {
  testWidgets('LoginPage: toggles password visibility', (tester) async {
    await pumpLoginPage(tester);

    // initial icon should be visibility_off
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    // after tap, should show visibility
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
}
