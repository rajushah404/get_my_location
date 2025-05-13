import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_my_location/src/location_getter.dart';

void main() {
  testWidgets('Shows loading state initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LocationGetter()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
