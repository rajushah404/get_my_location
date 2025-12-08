import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_my_location/src/location_getter.dart';

void main() {
  testWidgets('Shows loading indicator when autoFetch is enabled',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: LocationGetter(),
        ),
      ),
    ));

    // Initial pump shows the loading indicator because autoFetch is true by default.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
