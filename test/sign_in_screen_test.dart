// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/sign_in_screen.dart';
// Import the ProfileScreen

void main() {
  testWidgets('Test bottone di login', (WidgetTester tester) async {
    // Crea un widget per il test
    final widget = MaterialApp(
      home: Scaffold(
        body: SignInScreen(),
      ),
    );

    // Aggiungi il widget al tester
    await tester.pumpWidget(widget);

    // Trova il bottone di login
    final loginButtonFinder = find.text('Entra');

    // Verifica che il bottone sia presente
    expect(loginButtonFinder, findsOneWidget);

    // Simula un tap sul bottone
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

  });
  testWidgets('Test bottone di register', (WidgetTester tester) async {
    
    final widget = MaterialApp(
      home: Scaffold(
        body: SignInScreen(),
      ),
    );
    
    await tester.pumpWidget(widget);
    
    final registerFinder = find.text('Registrati');
    
    expect(registerFinder, findsOneWidget);
    
    await tester.tap(registerFinder);
    await tester.pumpAndSettle();

    expect(find.text('Registrati'), findsExactly(2));
  });
  testWidgets('Test bottone di google', (WidgetTester tester) async {
    
    final widget = MaterialApp(
      home: Scaffold(
        body: SignInScreen(),
      ),
    );
    
    await tester.pumpWidget(widget);
    
    final registerFinder = find.text('Google');
    
    expect(registerFinder, findsOneWidget);
    
    await tester.tap(registerFinder);
    await tester.pumpAndSettle();

    expect(find.text('Registrati con Google'), findsExactly(1));
    expect(find.text('Entra con Google'), findsExactly(1));

    final googleFinder = find.text('Registrati con Google');

    await tester.tap(googleFinder);
    await tester.pumpAndSettle();

    expect(find.text('Entra con Google'), findsExactly(1));
  });
  // Test per verificare la presenza dei campi "Email" e "Password"
  testWidgets('Test presenza dei campi Email e Password', (WidgetTester tester) async {
    // Crea un widget per il test
    final widget = MaterialApp(
      home: Scaffold(
        body: SignInScreen(),
      ),
    );

    // Aggiungi il widget al tester
    await tester.pumpWidget(widget);

    // Trova i campi di testo per "Email" e "Password"
    final emailFieldFinder = find.widgetWithText(TextField, 'Email');
    final passwordFieldFinder = find.widgetWithText(TextField, 'Password');

    // Verifica che i campi siano presenti
    expect(emailFieldFinder, findsOneWidget);
    expect(passwordFieldFinder, findsOneWidget);
  });

   // Test per verificare la presenza del pulsante "Allez"
  testWidgets('Test presenza del pulsante Allez', (WidgetTester tester) async {
    // Crea un widget per il test
    final widget = MaterialApp(
      home: Scaffold(
        body: SignInScreen(),
      ),
    );

    // Aggiungi il widget al tester
    await tester.pumpWidget(widget);

    // Trova il pulsante "Allez"
    final allezButtonFinder = find.widgetWithText(OutlinedButton, 'Allez');

    // Verifica che il pulsante sia presente
    expect(allezButtonFinder, findsOneWidget);
  });
  

}
