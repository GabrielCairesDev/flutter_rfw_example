import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rfw_example/main.dart';

void main() {
  testWidgets('carrega UI remota RFW e incrementa contador', (tester) async {
    await tester.pumpWidget(const RfwExampleApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Olá, Gabriel'), findsOneWidget);
    expect(find.textContaining('0 vezes'), findsOneWidget);

    await tester.tap(find.text('Incrementar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 vezes'), findsOneWidget);
  });
}
