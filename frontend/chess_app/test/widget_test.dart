import 'package:flutter_test/flutter_test.dart';
import 'package:chess_app/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ChessApp());
    expect(find.text('Chess Tournament Manager'), findsOneWidget);
  });
}
