import 'package:flutter_test/flutter_test.dart';
import 'package:moneytrace_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MoneyTraceApp());
    expect(find.byType(MoneyTraceApp), findsOneWidget);
  });
}
