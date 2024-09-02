import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fencing/auth_service.dart';
import 'package:fencing/profile_screen.dart';
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
  group('ProfileScreen Tests', () {
    testWidgets('Test presenza del titolo Profilo', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 
      expect(find.text('Profilo'), findsOneWidget);
    });

    testWidgets('Test presenza del campo Nome', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Nome'), findsNothing);
    });

    testWidgets('Test presenza del campo Cognome', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Cognome'), findsNothing);
    });

    testWidgets('Test presenza del campo Email', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Email'), findsNothing);
    });

    testWidgets('Test presenza del campo Ruolo', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Ruolo'), findsNothing);
    });

    testWidgets('Test presenza del bottone Modifica Profilo', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Modifica Profilo'), findsNothing);
    });
  });

  testWidgets('Test presenza del campo Telefono', (WidgetTester tester) async {
  final mockAuthService = MockAuthService('Atleta');
  when(mockAuthService.currentUser).thenReturn(null);

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<AuthService>(
        create: (_) => mockAuthService,
        child: const ProfileScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle(); 
  expect(find.text('Telefono'), findsNothing);
});

testWidgets('Test presenza del campo Indirizzo', (WidgetTester tester) async {
  final mockAuthService = MockAuthService('Atleta');
  when(mockAuthService.currentUser).thenReturn(null);

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<AuthService>(
        create: (_) => mockAuthService,
        child: const ProfileScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle(); 
  expect(find.text('Indirizzo'), findsNothing);
});

testWidgets('Test presenza del bottone Salva Modifiche', (WidgetTester tester) async {
  final mockAuthService = MockAuthService('Atleta');
  when(mockAuthService.currentUser).thenReturn(null);

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<AuthService>(
        create: (_) => mockAuthService,
        child: const ProfileScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle(); 
  expect(find.text('Salva Modifiche'), findsNothing);
});

testWidgets('Test presenza del bottone Annulla', (WidgetTester tester) async {
  final mockAuthService = MockAuthService('Atleta');
  when(mockAuthService.currentUser).thenReturn(null);

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<AuthService>(
        create: (_) => mockAuthService,
        child: const ProfileScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle(); 
  expect(find.text('Annulla'), findsNothing);
});
}