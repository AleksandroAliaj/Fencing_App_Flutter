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

void main() {
  final platform = LocalPlatform();

  if (platform.isAndroid) {
    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      // Inizializza dotenv e Firebase
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

    testWidgets('Test della navigazione alla schermata Chat', (WidgetTester tester) async {
      // Crea una istanza mock di AuthService
      final authService = AuthService();

      // Simula un utente autenticato
      when(authService.user).thenAnswer((_) => Stream.value(MockUser()));

      // Costruisci la widget tree con MultiProvider
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: authService),
          ],
          child: const FencingApp(),
        ),
      );

      // Attendi che la schermata iniziale sia caricata
      await tester.pumpAndSettle();

      // Verifica se la schermata HomeScreen è stata caricata
      expect(find.byType(HomeScreen), findsOneWidget);

      // Simula il tap sull'icona "Chat" nella BottomNavigationBar
      await tester.tap(find.byIcon(Icons.chat));

      // Attendi che il frame si stabilizzi
      await tester.pumpAndSettle();

      // Verifica se la schermata ChatSelectionScreen è stata mostrata
      expect(find.byType(ChatSelectionScreen), findsOneWidget);
    });
  } else {
    // Ignora i test su piattaforme diverse da Android
    testWidgets('Test della navigazione alla schermata Chat', (WidgetTester tester) async {
      // Test non eseguito su piattaforme non Android
      print('Test skipped on non-Android platform.');
    });
  }
  
}

// Mock della classe User per il test
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';
}
