import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/features/splash/splash_page.dart';

void main() {
  testWidgets('SplashPage renders without crashing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: SplashPage())));
    await tester.pump();

    expect(find.byType(SplashPage), findsOneWidget);
  });
}
