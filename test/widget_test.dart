import 'package:flutter_test/flutter_test.dart';
import 'package:furniture_billing/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FurnitureBillingApp());

    // Verify that the app title is displayed
    expect(find.text('Furniture Billing'), findsWidgets);
  });
}
