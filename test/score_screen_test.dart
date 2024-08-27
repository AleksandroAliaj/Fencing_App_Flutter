// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/score_screen.dart'; // Assicurati di usare il percorso corretto per ScoreScreen

void main() {
  testWidgets('Test presenza dei campi di input e punteggi iniziali', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScoreScreen()));

    // Verifica la presenza dei campi di input per i nomi dei giocatori
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Nome Giocatore 1'), findsOneWidget);
    expect(find.text('Nome Giocatore 2'), findsOneWidget);

    // Verifica la presenza dei punteggi iniziali
    expect(find.text('0'), findsNWidgets(2)); // Due punteggi iniziali a 0
  });


  testWidgets('Test incremento punteggi e terminazione partita', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScoreScreen()));

    // Trova i pulsanti per incrementare il punteggio dei giocatori
    final player1ButtonFinder = find.text('+1 punto').at(0);
    final player2ButtonFinder = find.text('+1 punto').at(1);

    // Incrementa il punteggio del Giocatore 1
    await tester.tap(player1ButtonFinder);
    await tester.pump(); // Aggiorna lo stato
    expect(find.text('1'), findsOneWidget);

    // Incrementa il punteggio del Giocatore 2
    await tester.tap(player2ButtonFinder);
    await tester.pump(); // Aggiorna lo stato
    expect(find.text('1'), findsNWidgets(2)); // Verifica entrambi i punteggi

    // Simula il raggiungimento del punteggio massimo per terminare la partita
    for (int i = 0; i < 15; i++) {
      await tester.tap(player1ButtonFinder);
      await tester.pump();
    }

    // Verifica che il timer si sia fermato e che il messaggio di vittoria sia presente
    expect(find.text('Giocatore 1 ha vinto!'), findsOneWidget);
  });

  testWidgets('Test funzionamento del timer', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScoreScreen()));

    // Trova e clicca il pulsante di avvio del timer
    final startButtonFinder = find.text('Avvia');
    await tester.tap(startButtonFinder);
    await tester.pump(Duration(seconds: 1)); // Simula un secondo

    // Verifica che il tempo sul display sia diminuito
    expect(find.textContaining('02:'), findsOneWidget);
  });
}
