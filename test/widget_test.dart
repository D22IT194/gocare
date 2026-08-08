import 'package:flutter_test/flutter_test.dart';

import 'package:gocare/app.dart';

void main() {
  testWidgets('GoCare app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GoCareApp());

    expect(find.text('GoCare'), findsOneWidget);
  });
}