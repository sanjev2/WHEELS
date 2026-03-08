import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wheels_flutter/core/widgets/my_buttons.dart';

void main() {
  testWidgets('renders text and handles tap', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MyButton(onPressed: () => tapped++, text: 'Save'),
      ),
    ));

    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('shows loader when loading', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MyButton(onPressed: null, text: 'Save', isLoading: true),
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });
}
