import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monetra/app/app.dart';

void main() {
  testWidgets('Monetra shows overview navigation on launch', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MonetraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Обзор'), findsOneWidget);
    expect(find.text('Записи'), findsOneWidget);
    expect(find.text('Monetra'), findsOneWidget);
  });
}
