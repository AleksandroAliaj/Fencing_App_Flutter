// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/ranking_screen.dart'; 
import 'package:fencing/search_screen.dart'; 

void main() {

  testWidgets('Test navigazione verso SearchScreen', (WidgetTester tester) async {
    
    final widget = MaterialApp(
      home: RankingScreen(),
    );

    await tester.pumpWidget(widget);

    
    final buttonFinder = find.text('Fioretto Femminile');
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle(); 

    
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('Fioretto Femminile'), findsOneWidget);
  });

  testWidgets('Test navigazione', (WidgetTester tester) async {
    
    final widget = MaterialApp(
      home: RankingScreen(),
    );

    await tester.pumpWidget(widget);

    
    final buttonFinder = find.text('Fioretto Maschile');
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle(); 

    
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('Fioretto Maschile'), findsOneWidget);
  });


  
}
