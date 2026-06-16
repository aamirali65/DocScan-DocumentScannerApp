import 'package:flutter_test/flutter_test.dart';
import 'package:docscan_flutter/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DocScanApp());
    expect(find.text('DocScan'), findsOneWidget);
    expect(find.text('Scan'), findsWidgets);
  });
}
