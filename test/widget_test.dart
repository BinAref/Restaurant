import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_ordering_app/main.dart';

void main() {
  testWidgets('Language selection screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RestaurantOrderingApp());

    // Verify that language selection screen loads
    expect(find.text('Restaurant Ordering'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('Türkçe'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    // Tap on Arabic language
    await tester.tap(find.text('العربية'));
    await tester.pump();

    // Verify that Next button appears
    expect(find.text('التالي'), findsOneWidget);
  });
}
