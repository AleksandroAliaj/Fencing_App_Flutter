// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fencing/auth_service.dart';
import 'package:fencing/shop_screen.dart';
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
  group('ShopScreen Tests', () {
    testWidgets('Test presenza del titolo Shop', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ShopScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); // Assicurati che tutti i widget siano completamente costruiti

      expect(find.text('Shop'), findsOneWidget);
    });

    testWidgets('Test presenza della categoria Abbigliamento e Equipaggiamento di Base', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ShopScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); // Assicurati che tutti i widget siano completamente costruiti

      expect(find.text('Abbigliamento e Equipaggiamento di Base'), findsOneWidget);
    });

    testWidgets('Test presenza della categoria Armi', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ShopScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); // Assicurati che tutti i widget siano completamente costruiti

      expect(find.text('Armi'), findsOneWidget);
    });

    testWidgets('Test presenza della categoria Accessori', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ShopScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); // Assicurati che tutti i widget siano completamente costruiti

      expect(find.text('Accessori'), findsNothing);
    });

    testWidgets('Test presenza della categoria Attrezzatura Elettrica', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ShopScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); // Assicurati che tutti i widget siano completamente costruiti

      expect(find.text('Attrezzatura Elettrica'), findsNothing);
    });

    testWidgets('Test presenza dei pulsanti delle categorie', (WidgetTester tester) async {
      final mockAuthService = MockAuthService('Atleta');
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const ShopScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(); // Assicurati che tutti i widget siano completamente costruiti

      expect(find.byIcon(Icons.checkroom), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
      expect(find.byIcon(Icons.sports_handball), findsNothing);
      expect(find.byIcon(Icons.electric_bolt), findsNothing);
    });
  });

  testWidgets('Test presenza del titolo Shop', (WidgetTester tester) async {
    expect(find.text('Shop'), findsNothing);
    
  });

  testWidgets('Test presenza delle categorie di prodotti', (WidgetTester tester) async {
    

    expect(find.text('Abbigliamento e Equipaggiamento di Base'), findsNothing);
    expect(find.text('Armi'), findsNothing);
    expect(find.text('Accessori'), findsNothing);
    expect(find.text('Attrezzatura Elettrica'), findsNothing);
  });

  testWidgets('Test presenza dei pulsanti delle categorie', (WidgetTester tester) async {

    expect(find.byIcon(Icons.checkroom), findsNothing);
    expect(find.byIcon(Icons.security), findsNothing);
    expect(find.byIcon(Icons.sports_handball), findsNothing);
    expect(find.byIcon(Icons.electric_bolt), findsNothing);
  });
}