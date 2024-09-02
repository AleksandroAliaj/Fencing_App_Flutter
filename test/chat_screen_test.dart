// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fencing/auth_service.dart';
import 'package:fencing/chat_screen.dart';
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
  group('ChatScreen Tests', () {
    testWidgets('Test presenza del titolo Chat', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ChatScreen(chatType: 'athletes_coaches'),
          ),
        ),
      );

      await tester.pump(Duration(seconds: 1)); 

      expect(find.text('Chat'), findsNothing);
    });

    testWidgets('Test presenza del campo di input messaggio', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ChatScreen(chatType: 'athletes_coaches'),
          ),
        ),
      );

      await tester.pump(Duration(seconds: 1)); 

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Scrivi un messaggio...'), findsNothing);
    });

    testWidgets('Test presenza del bottone Invia', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ChatScreen(chatType: 'athletes_coaches'),
          ),
        ),
      );

      await tester.pump(Duration(seconds: 1)); 

      expect(find.text('Invia'), findsNothing);
    });

    testWidgets('Test presenza del titolo Messaggi Recenti', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ChatScreen(chatType: 'athletes_coaches'),
          ),
        ),
      );

      await tester.pump(Duration(seconds: 1)); 

      expect(find.text('Messaggi Recenti'), findsNothing);
    });
  });

  
}
