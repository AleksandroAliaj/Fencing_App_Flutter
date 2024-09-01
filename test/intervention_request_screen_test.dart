import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fencing/auth_service.dart';
import 'package:fencing/intervention_request_screen.dart';
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
  group('InterventionRequestScreen Tests', () {
    testWidgets('Test presenza del titolo Richiesta di Intervento', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const InterventionRequestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Richiesta di Intervento'), findsOneWidget);
    });

    testWidgets('Test presenza del campo Descrizione', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const InterventionRequestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Descrizione'), findsNothing);
    });

    testWidgets('Test presenza del campo Data', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const InterventionRequestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Data'), findsNothing);
    });

    testWidgets('Test presenza del campo Ora', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const InterventionRequestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Ora'), findsNothing);
    });

    testWidgets('Test presenza del bottone Invia Richiesta', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const InterventionRequestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 
      expect(find.text('Invia Richiesta'), findsNothing);
    });
  });
}