import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fencing/auth_service.dart';
import 'package:fencing/calendar_screen.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {
  final String role;

  MockAuthService(this.role);

  @override
  Future<String?> getUserRole(String? uid) async {
    return role;
  }
}

void main() {
  group('CalendarScreen Tests', () {
    testWidgets('Test presenza del titolo Aggiungi Evento', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const CalendarScreen(),
          ),
        ),
      );

      expect(find.text('Aggiungi Evento'), findsNothing);
    });

    testWidgets('Test presenza del titolo Tutti gli Eventi', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const CalendarScreen(),
          ),
        ),
      );

      expect(find.text('Tutti gli Eventi'), findsNothing);
    });

    testWidgets('Test presenza del titolo Nessun evento trovato', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const CalendarScreen(),
          ),
        ),
      );

      expect(find.text('Nessun evento trovato'), findsNothing);
    });

    testWidgets('Test presenza del titolo Seleziona Data', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const CalendarScreen(),
          ),
        ),
      );

      expect(find.text('Seleziona Data'), findsNothing);
    });

    testWidgets('Test presenza del titolo Descrizione Evento', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const CalendarScreen(),
          ),
        ),
      );

      expect(find.text('Descrizione Evento'), findsNothing);
    });

    testWidgets('Test presenza del bottone Aggiungi Evento', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const CalendarScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('Test presenza del calendario', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const CalendarScreen(),
          ),
        ),
      );

      expect(find.byType(CalendarDatePicker), findsNothing);
    });

testWidgets('Test presenza del bottone Salva Evento', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const CalendarScreen(),
          ),
        ),
      );

      expect(find.text('Salva Evento'), findsNothing);
    });

    testWidgets('Test presenza del campo Titolo Evento', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const CalendarScreen(),
          ),
        ),
      );

      expect(find.text('Titolo Evento'), findsNothing);
    });
    testWidgets('Test presenza del campo Luogo Evento', (WidgetTester tester) async {
  final mockAuthService = MockAuthService('Staff');
  when(mockAuthService.currentUser).thenReturn(null);

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<AuthService>(
        create: (_) => mockAuthService,
        child: const CalendarScreen(),
      ),
    ),
  );

  expect(find.text('Luogo Evento'), findsNothing);
});

testWidgets('Test presenza del campo Ora Inizio', (WidgetTester tester) async {
  final mockAuthService = MockAuthService('Staff');
  when(mockAuthService.currentUser).thenReturn(null);

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<AuthService>(
        create: (_) => mockAuthService,
        child: const CalendarScreen(),
      ),
    ),
  );

  expect(find.text('Ora Inizio'), findsNothing);
});

testWidgets('Test presenza del campo Ora Fine', (WidgetTester tester) async {
  final mockAuthService = MockAuthService('Staff');
  when(mockAuthService.currentUser).thenReturn(null);

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<AuthService>(
        create: (_) => mockAuthService,
        child: const CalendarScreen(),
      ),
    ),
  );

  expect(find.text('Ora Fine'), findsNothing);
});

testWidgets('Test presenza del bottone Annulla', (WidgetTester tester) async {
  final mockAuthService = MockAuthService('Staff');
  when(mockAuthService.currentUser).thenReturn(null);

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<AuthService>(
        create: (_) => mockAuthService,
        child: const CalendarScreen(),
      ),
    ),
  );

  expect(find.text('Annulla'), findsNothing);
});
  });
}