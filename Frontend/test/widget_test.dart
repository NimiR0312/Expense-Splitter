import 'package:flutter_test/flutter_test.dart';
import 'package:expense_splitter/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseSplitterApp());

    expect(find.byType(ExpenseSplitterApp), findsOneWidget);
  });
}