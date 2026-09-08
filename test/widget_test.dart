import 'package:flutter_test/flutter_test.dart';
import 'package:glassnik/main.dart';

void main() {
  testWidgets(
    'Glassnik app launches',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const GlassnikApp(),
      );

      expect(
        find.byType(GlassnikApp),
        findsOneWidget,
      );
    },
  );
}
