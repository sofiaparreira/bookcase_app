import 'package:bookcase/features/book_details/book_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('book details renders on a phone viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: BookDetailsPage()));

    expect(find.text('Tudo é Rio'), findsOneWidget);
    expect(find.text('Detalhes do livro'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
