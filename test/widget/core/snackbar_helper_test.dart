import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wheels_flutter/core/utils/snackbar_helper.dart';

void main() {
  testWidgets('showErrorSnackBar renders message', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () => showErrorSnackBar(context, 'Boom'),
            child: const Text('Show'),
          ),
        );
      }),
    ));

    await tester.tap(find.text('Show'));
    await tester.pump();

    expect(find.text('Boom'), findsOneWidget);
  });
}
