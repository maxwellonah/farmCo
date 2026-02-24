import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/app/app.dart';

void main() {
  testWidgets('onboarding flow reaches role selection', (WidgetTester tester) async {
    await tester.pumpWidget(const FarmConnectApp());

    expect(find.text('FarmConnect NG'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Language Selection'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('I am a...'), findsOneWidget);
  });
}
