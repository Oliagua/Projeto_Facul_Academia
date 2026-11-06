import 'package:flutter_test/flutter_test.dart';
import 'package:powerfit_mobile/main.dart';

void main() {
  testWidgets('login abre como tela inicial e valida campos vazios', (tester) async {
    await tester.pumpWidget(const PowerFitApp());

    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);

    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe o e-mail'), findsOneWidget);
    expect(find.text('Informe a senha'), findsOneWidget);
  });
}
