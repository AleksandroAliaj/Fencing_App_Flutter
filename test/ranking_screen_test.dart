// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/ranking_screen.dart'; // Assicurati di usare il percorso corretto per RankingScreen
import 'package:fencing/search_screen.dart'; // Importa SearchScreen se necessario per i test

void main() {

  testWidgets('Test navigazione verso SearchScreen', (WidgetTester tester) async {
    // Definisci un mock per SearchScreen se necessario
    final widget = MaterialApp(
      home: RankingScreen(),
    );

    await tester.pumpWidget(widget);

    // Trova il pulsante per "Fioretto Femminile" e simula il click
    final buttonFinder = find.text('Fioretto Femminile');
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle(); // Aspetta la navigazione

    // Verifica che la schermata di ricerca con la categoria "Fioretto Femminile" sia visualizzata
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('Fioretto Femminile'), findsOneWidget);
  });

  testWidgets('Test navigazione', (WidgetTester tester) async {
    // Definisci un mock per SearchScreen se necessario
    final widget = MaterialApp(
      home: RankingScreen(),
    );

    await tester.pumpWidget(widget);

    // Trova il pulsante per "Fioretto Femminile" e simula il click
    final buttonFinder = find.text('Fioretto Maschile');
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle(); // Aspetta la navigazione

    // Verifica che la schermata di ricerca con la categoria "Fioretto Femminile" sia visualizzata
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('Fioretto Maschile'), findsOneWidget);
  });


  
}
