import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toastification/toastification.dart';

void main() {
  testWidgets('aviso continua visível ao fechar a tela que o exibiu', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () {
                        AppAlert.success(context, 'Perfil atualizado.');
                        Navigator.pop(context);
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Abrir'), findsOneWidget);
    expect(find.text('Tudo certo!'), findsOneWidget);
    expect(find.text('Perfil atualizado.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Perfil atualizado.'), findsNothing);
  });

  testWidgets('um novo erro substitui o aviso anterior', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                TextButton(
                  onPressed: () =>
                      AppAlert.info(context, 'Em desenvolvimento.'),
                  child: const Text('Informar'),
                ),
                TextButton(
                  onPressed: () => AppAlert.error(context, 'Falha ao salvar.'),
                  child: const Text('Erro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Informar'));
    await tester.pumpAndSettle();
    expect(find.text('Em desenvolvimento.'), findsOneWidget);

    await tester.tap(find.text('Erro'));
    await tester.pumpAndSettle();
    expect(find.text('Em desenvolvimento.'), findsNothing);
    expect(find.text('Não foi possível concluir'), findsOneWidget);
    expect(find.text('Falha ao salvar.'), findsOneWidget);

    toastification.dismissAll();
    await tester.pumpAndSettle();
  });
}
