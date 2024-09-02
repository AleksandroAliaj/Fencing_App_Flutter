// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/training_screen.dart';
import 'package:provider/provider.dart';
import 'package:fencing/auth_service.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  Future<String?> getUserRole(String? uid) async {
    return 'Allenatore';
  }
}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    when(mockAuthService.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Provider<AuthService>(
        create: (_) => mockAuthService,
        child: TrainingScreen(),
      ),
    );
  }


  testWidgets('Test presenza del titolo Allenamento', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Allenamento'), findsOneWidget);
  });

  testWidgets('Test presenza delle tab', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Lezione privata'), findsOneWidget);
    expect(find.text('Assalti'), findsOneWidget);
    expect(find.text('Prep. atletica'), findsOneWidget);
  });

  testWidgets('Test presenza dei campi nella tab Lezione privata', (WidgetTester tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pumpAndSettle();

  await tester.tap(find.text('Lezione privata'));
  await tester.pumpAndSettle();

  
  await tester.tap(find.text('Aggiungi Lezione'));
  await tester.pumpAndSettle();

  expect(find.text('Nome Atleta'), findsOneWidget);
  expect(find.text('Cognome Atleta'), findsOneWidget);
  
});

testWidgets('Test presenza e funzionamento del bottone "Le Mie Lezioni"', (WidgetTester tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pumpAndSettle();

  await tester.tap(find.text('Lezione privata'));
  await tester.pumpAndSettle();

  
  expect(find.text('Le Mie Lezioni'), findsOneWidget);

  
  
});

testWidgets('Test presenza della tab Assalti', (WidgetTester tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pumpAndSettle();

  expect(find.text('Assalti'), findsOneWidget);
});

testWidgets('Test visualizzazione corretta per ruolo Allenatore', (WidgetTester tester) async {
  
  
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pumpAndSettle();

  await tester.tap(find.text('Assalti'));
  await tester.pumpAndSettle();

  expect(find.byType(CoachAssaltiView), findsOneWidget);
});

testWidgets('Test presenza dei bottoni per Allenatore nella tab Assalti', (WidgetTester tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pumpAndSettle();

  await tester.tap(find.text('Assalti'));
  await tester.pumpAndSettle();


  expect(find.text('Crea \nAssalto'), findsOneWidget);
  expect(find.text('Elenco \nAssalti'), findsOneWidget);
});

testWidgets('Test presenza dei campi nel form Crea Assalto per Allenatore', (WidgetTester tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pumpAndSettle();

  await tester.tap(find.text('Assalti'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Crea \nAssalto'));
  await tester.pumpAndSettle();

  expect(find.text('Libero'), findsOneWidget);
  expect(find.text('Simulazione Gara'), findsOneWidget);
  expect(find.text('A squadre'), findsOneWidget);
  expect(find.text('A tema'), findsOneWidget);

  await tester.tap(find.text('Libero'));
  await tester.pumpAndSettle();
  expect(find.text('Atleti:'), findsOneWidget);
  expect(find.text('Aggiungi Atleta'), findsOneWidget);
  expect(find.text('Crea Combattimento'), findsOneWidget);
  
});

testWidgets('Test presenza dei campi nel form Crea Assalto per Allenatore', (WidgetTester tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pumpAndSettle();

  await tester.tap(find.text('Assalti'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Crea \nAssalto'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Simulazione Gara'));
  await tester.pumpAndSettle();
  expect(find.text('Atleti:'), findsOneWidget);
  expect(find.text('Aggiungi Atleta'), findsOneWidget);
  expect(find.text('Crea Combattimento'), findsOneWidget);
  
});
testWidgets('Test presenza del bottone Aggiungi Allenamento', (WidgetTester tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pumpAndSettle();

  expect(find.text('Aggiungi Allenamento'), findsNothing);
});

testWidgets('Test presenza del bottone Elenco Allenamenti', (WidgetTester tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pumpAndSettle();

  expect(find.text('Elenco Allenamenti'), findsNothing);
});





}