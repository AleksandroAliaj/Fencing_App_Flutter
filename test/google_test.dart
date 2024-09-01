// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/google_sign_in.dart';

void main() {
  testWidgets('Test presenza del titolo Registrati con Google', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: GoogleSignInScreen()));
    expect(find.text('Registrati con Google'), findsOneWidget);
  });

  testWidgets('Test presenza dei campi di input', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: GoogleSignInScreen()));
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Cognome'), findsOneWidget);
  });

  testWidgets('Test presenza del dropdown per il ruolo', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: GoogleSignInScreen()));
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    
  });

  testWidgets('Test presenza del checkbox per generare nuovo codice', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: GoogleSignInScreen()));
    expect(find.byType(Checkbox), findsOneWidget);
    
  });

  testWidgets('Test presenza del bottone di registrazione', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: GoogleSignInScreen()));
    expect(find.text('Registrati'), findsNothing);
  });
  testWidgets('Test presenza del campo Email', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: GoogleSignInScreen()));
  expect(find.widgetWithText(TextField, 'Email'), findsNothing);
});

testWidgets('Test presenza del campo Password', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: GoogleSignInScreen()));
  expect(find.widgetWithText(TextField, 'Password'), findsNothing);
});

testWidgets('Test presenza del bottone Entra con Google', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: GoogleSignInScreen()));
  expect(find.text('Entra con Google'), findsOneWidget);
});

testWidgets('Test presenza del bottone Annulla', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: GoogleSignInScreen()));
  expect(find.text('Annulla'), findsNothing);
});

}