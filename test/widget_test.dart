import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poultry_farm_management/app/app.dart';

void main() {
  testWidgets('app boots and shows splash screen title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PoultryFarmApp(enableAuthListener: false),
      ),
    );

    expect(find.text('Poultry Farm Manager'), findsOneWidget);
    expect(find.text('Manage your farm with confidence.'), findsOneWidget);
  });
}
