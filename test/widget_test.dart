import 'package:flutter_test/flutter_test.dart';
import 'package:lg_device/app/lg_hair_refresher_app.dart';

void main() {
  testWidgets('shows scan demo as the entry screen', (tester) async {
    await tester.pumpWidget(const LgHairRefresherApp());
    await tester.pumpAndSettle();

    expect(find.text('Hair Scan Demo'), findsOneWidget);
    expect(find.text('스캔 시작'), findsOneWidget);
  });
}
