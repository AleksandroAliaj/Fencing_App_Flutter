// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/sign_in_screen.dart';

void main() {
  testWidgets('Test bottone di login', (WidgetTester tester) async {
    
    final widget = MaterialApp(
      home: Scaffold(
        body: SignInScreen(),
      ),
    );

    
    await tester.pumpWidget(widget);

    
    final loginButtonFinder = find.text('Entra');

    
    expect(loginButtonFinder, findsOneWidget);

    
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
  
  testWidgets('Test presenza dei campi Email e Password', (WidgetTester tester) async {
    
    final widget = MaterialApp(
      home: Scaffold(
        body: SignInScreen(),
      ),
    );

    
    await tester.pumpWidget(widget);

    
    final emailFieldFinder = find.widgetWithText(TextField, 'Email');
    final passwordFieldFinder = find.widgetWithText(TextField, 'Password');

    
    expect(emailFieldFinder, findsOneWidget);
    expect(passwordFieldFinder, findsOneWidget);
  });

   
  testWidgets('Test presenza del pulsante Allez', (WidgetTester tester) async {
    
    final widget = MaterialApp(
      home: Scaffold(
        body: SignInScreen(),
      ),
    );

    
    await tester.pumpWidget(widget);

    
    final allezButtonFinder = find.widgetWithText(OutlinedButton, 'Allez');

   
    expect(allezButtonFinder, findsOneWidget);
  });

  testWidgets('Test presenza del bottone Password dimenticata', (WidgetTester tester) async {
  final widget = MaterialApp(
    home: Scaffold(
      body: SignInScreen(),
    ),
  );

  await tester.pumpWidget(widget);

  final forgotPasswordButtonFinder = find.text('Password dimenticata');
  expect(forgotPasswordButtonFinder, findsNothing);
});

testWidgets('Test presenza del bottone Crea un account', (WidgetTester tester) async {
  final widget = MaterialApp(
    home: Scaffold(
      body: SignInScreen(),
    ),
  );

  await tester.pumpWidget(widget);

  final createAccountButtonFinder = find.text('Crea un account');
  expect(createAccountButtonFinder, findsNothing);
});

testWidgets('Test presenza del logo dell\'app', (WidgetTester tester) async {
  final widget = MaterialApp(
    home: Scaffold(
      body: SignInScreen(),
    ),
  );

  await tester.pumpWidget(widget);

  final logoFinder = find.byType(Image); 
  expect(logoFinder, findsOneWidget);
});

testWidgets('Test presenza del messaggio di errore per credenziali errate', (WidgetTester tester) async {
  final widget = MaterialApp(
    home: Scaffold(
      body: SignInScreen(),
    ),
  );

  await tester.pumpWidget(widget);

  
  await tester.enterText(find.widgetWithText(TextField, 'Email'), 'wrong@example.com');
  await tester.enterText(find.widgetWithText(TextField, 'Password'), 'wrongpassword');
  await tester.tap(find.text('Entra'));
  await tester.pumpAndSettle();

  final errorMessageFinder = find.text('Credenziali errate'); 
  expect(errorMessageFinder, findsNothing);
});

  

}
