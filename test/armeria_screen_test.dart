// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/armeria_screen.dart';

void main() {
  testWidgets('Test presenza titolo Armeria', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ArmeriaScreen()));
    expect(find.text('Armeria'), findsOneWidget);
  });

  testWidgets('Test presenza bottone Shop', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ArmeriaScreen()));
    expect(find.text('Shop'), findsOneWidget);
  });

  testWidgets('Test presenza bottone Richiesta di Intervento', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ArmeriaScreen()));
    expect(find.text('Richiesta di Intervento'), findsOneWidget);
  });

  testWidgets('Test presenza icone', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ArmeriaScreen()));
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    expect(find.byIcon(Icons.build), findsOneWidget);
  });
}