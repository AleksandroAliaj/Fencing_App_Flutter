// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:fencing/main.dart';

import 'package:fencing/auth_service.dart';
import 'package:fencing/chat_selection_screen.dart';
import 'package:fencing/training_screen.dart';
import 'package:fencing/ranking_screen.dart';
import 'package:fencing/armeria_screen.dart';
import 'package:fencing/calendar_screen.dart';
import 'package:fencing/sign_in_screen.dart';

void main() {
  final platform = LocalPlatform();

  if (platform.isAndroid) {
    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      // Initialize dotenv and Firebase
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        print('Error loading .env file: $e');
      }
      print(dotenv.env['API_KEY']);
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          name: 'scherma',
          options: FirebaseOptions(
            apiKey: dotenv.env['API_KEY'] ?? '',
            authDomain: dotenv.env['AUTH_DOMAIN'] ?? '',
            projectId: dotenv.env['PROJECT_ID'] ?? '',
            storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
            messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
            appId: dotenv.env['APP_ID'] ?? '',
            measurementId: dotenv.env['MEASUREMENT_ID'] ?? '',
          ),
        );
      }
    });

    testWidgets('Test navigation to Training screen', (WidgetTester tester) async {
      final authService = AuthService();
      when(authService.user).thenAnswer((_) => Stream.value(MockUser()));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: authService),
          ],
          child: const FencingApp(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();

      expect(find.byType(TrainingScreen), findsOneWidget);
    });

    testWidgets('Test navigation to Ranking screen', (WidgetTester tester) async {
      final authService = AuthService();
      when(authService.user).thenAnswer((_) => Stream.value(MockUser()));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: authService),
          ],
          child: const FencingApp(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();

      expect(find.byType(RankingScreen), findsOneWidget);
    });

    testWidgets('Test navigation to Armeria screen', (WidgetTester tester) async {
      final authService = AuthService();
      when(authService.user).thenAnswer((_) => Stream.value(MockUser()));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: authService),
          ],
          child: const FencingApp(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.build));
      await tester.pumpAndSettle();

      expect(find.byType(ArmeriaScreen), findsOneWidget);
    });

    testWidgets('Test navigation to Calendar screen', (WidgetTester tester) async {
      final authService = AuthService();
      when(authService.user).thenAnswer((_) => Stream.value(MockUser()));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: authService),
          ],
          child: const FencingApp(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('Test unauthenticated user sees SignInScreen', (WidgetTester tester) async {
      final authService = AuthService();
      when(authService.user).thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: authService),
          ],
          child: const FencingApp(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
    });

  } else {
    // Skip tests on non-Android platforms
    testWidgets('Skip tests on non-Android platform', (WidgetTester tester) async {
      print('Tests skipped on non-Android platform.');
    });
  }
}

// Mock User class for testing
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';
}