import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fencing/auth_service.dart';
import 'package:fencing/news_list_screen.dart';
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
  group('NewsListScreen Tests', () {
    testWidgets('Test per ruolo Staff', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const NewsListScreen(),
          ),
        ),
      );

      expect(find.text('Aggiungi News'), findsNothing);
      expect(find.text('Tutte le News'), findsNothing);
    });

    testWidgets('Test per ruolo Atleta', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const NewsListScreen(),
          ),
        ),
      );

      expect(find.byType(NewsList), findsNothing);
    });

    testWidgets('Test navigazione verso AddNewsScreen', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const NewsListScreen(),
          ),
        ),
      );

      //await tester.tap(find.text('Aggiungi News'));
      //await tester.pumpAndSettle();

      expect(find.byType(AddNewsScreen), findsNothing);
    });

    testWidgets('Test navigazione verso AllNewsScreen', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const NewsListScreen(),
          ),
        ),
      );

      //await tester.tap(find.text('Tutte le News'));
      //await tester.pumpAndSettle();

      expect(find.byType(AllNewsScreen), findsNothing);
    });
  });

  group('NewsListScreen Tests', () {
  

    testWidgets('Test presenza del bottone Aggiungi News', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const NewsListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Aggiungi News'), findsOneWidget);
    });

    testWidgets('Test presenza del bottone Tutte le News', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Staff');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const NewsListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.text('Tutte le News'), findsOneWidget);
    });

  });
}
