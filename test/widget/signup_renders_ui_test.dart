import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test utils/pump_signup.dart';

void main() {
  testWidgets('SignupPage: renders basic UI', (tester) async {
    await pumpSignupPage(tester);

    expect(find.text("Let's get started!"), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);

    // 6 form fields
    expect(find.byType(TextFormField), findsNWidgets(6));
  });
}
