// ignore_for_file: prefer_const_constructors

import 'package:fencing/enter_facility_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/facility_code_screen.dart';

void main() {
  testWidgets('Test presenza del titolo e del codice struttura', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: FacilityCodeScreen(facilityCode: '123456')));

    expect(find.text('Comunica il tuo codice!'), findsOneWidget);
    expect(find.text('Codice struttura:'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);
  });

  testWidgets('Test presenza del bottone "Vai al profilo"', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: FacilityCodeScreen(facilityCode: '123456')));

    expect(find.text('Vai al profilo'), findsOneWidget);
  });

  testWidgets('Test stile del testo del codice struttura', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: FacilityCodeScreen(facilityCode: '123456')));

    final textFinder = find.text('123456');
    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style?.fontSize, 30);
    expect(textWidget.style?.fontWeight, FontWeight.bold);
    expect(textWidget.style?.color, Colors.black);
  });



  testWidgets('Test presenza del titolo e del campo di input', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: EnterFacilityCodeScreen(
      email: 'test@example.com',
      password: 'password123',
      role: 'Atleta',
      firstName: 'John',
      lastName: 'Doe',
    )));

    expect(find.text('Inserisci il codice struttura'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Codice struttura'), findsOneWidget);
  });

  testWidgets('Test inserimento codice struttura', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: EnterFacilityCodeScreen(
      email: 'test@example.com',
      password: 'password123',
      role: 'Atleta',
      firstName: 'John',
      lastName: 'Doe',
    )));

    await tester.enterText(find.byType(TextField), '123456');
    expect(find.text('123456'), findsOneWidget);
  });

  testWidgets('Test stile del campo di input', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: EnterFacilityCodeScreen(
      email: 'test@example.com',
      password: 'password123',
      role: 'Atleta',
      firstName: 'John',
      lastName: 'Doe',
    )));

    final textFieldFinder = find.byType(TextField);
    final textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.decoration?.labelStyle?.color, Colors.black);
    expect(textField.decoration?.focusedBorder, isA<OutlineInputBorder>());
    expect(textField.decoration?.enabledBorder, isA<OutlineInputBorder>());
  });
}
