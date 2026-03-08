import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/main.dart';

void main() {
  testWidgets(
    'MyApp shows onboarding when startRouteProvider returns onboarding',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            startRouteProvider.overrideWith(
              (ref) async => StartRoute.onboarding,
            ),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
    },
  );
}
