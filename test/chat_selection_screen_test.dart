import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fencing/auth_service.dart';
import 'package:fencing/chat_selection_screen.dart';
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
  group('ChatSelectionScreen Tests', () {
    testWidgets('Test presenza del titolo Seleziona Chat', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ChatSelectionScreen(),
          ),
        ),
      );

      expect(find.text('Seleziona Chat'), findsNothing);
    });

    testWidgets('Test presenza del titolo Chat di Gruppo', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ChatSelectionScreen(),
          ),
        ),
      );

      expect(find.text('Chat di Gruppo'), findsNothing);
    });

    testWidgets('Test presenza del titolo Chat Privata', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ChatSelectionScreen(),
          ),
        ),
      );

      expect(find.text('Chat Privata'), findsNothing);
    });

    testWidgets('Test presenza del titolo Nuova Chat', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ChatSelectionScreen(),
          ),
        ),
      );

      expect(find.text('Nuova Chat'), findsNothing);
    });

    testWidgets('Test presenza del titolo Chat Esistente', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ChatSelectionScreen(),
          ),
        ),
      );

      expect(find.text('Chat Esistente'), findsNothing);
    });
  });
}