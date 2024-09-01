import 'package:fencing/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fencing/auth_service.dart';
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
  group('UserListScreen Tests', () {
    testWidgets('Test per ruolo Atleta', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const UserListScreen(),
          ),
        ),
      );

      expect(find.text('Cerca un utente...'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Test per ruolo Staff', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const UserListScreen(),
          ),
        ),
      );

      expect(find.text('Cerca un utente...'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Test funzionamento del campo di ricerca', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const UserListScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Mario');
      await tester.pump();

      expect(find.text('Mario'), findsOneWidget);
    });

    testWidgets('Test presenza del CircularProgressIndicator quando _currentUserFacilityCode è null', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const UserListScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}