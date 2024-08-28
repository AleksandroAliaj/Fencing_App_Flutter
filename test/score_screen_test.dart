// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/score_screen.dart'; 

void main() {
  testWidgets('Test presenza dei campi di input e punteggi iniziali', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScoreScreen()));

    
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Nome Giocatore 1'), findsOneWidget);
    expect(find.text('Nome Giocatore 2'), findsOneWidget);

    
    expect(find.text('0'), findsNWidgets(2)); 
  });


  testWidgets('Test incremento punteggi e terminazione partita', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScoreScreen()));

    
    final player1ButtonFinder = find.text('+1 punto').at(0);
    final player2ButtonFinder = find.text('+1 punto').at(1);

    
    await tester.tap(player1ButtonFinder);
    await tester.pump(); 
    expect(find.text('1'), findsOneWidget);

    
    await tester.tap(player2ButtonFinder);
    await tester.pump(); 
    expect(find.text('1'), findsNWidgets(2)); 

    
    for (int i = 0; i < 15; i++) {
      await tester.tap(player1ButtonFinder);
      await tester.pump();
    }

    
    expect(find.text('Giocatore 1 ha vinto!'), findsOneWidget);
  });

  testWidgets('Test funzionamento del timer', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScoreScreen()));

    
    final startButtonFinder = find.text('Avvia');
    await tester.tap(startButtonFinder);
    await tester.pump(Duration(seconds: 1)); 

    
    expect(find.textContaining('02:'), findsOneWidget);
  });
}
