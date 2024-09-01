// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:fencing/main.dart';
import 'package:fencing/auth_service.dart';
import 'package:fencing/sign_in_screen.dart';



class MockAuthService extends Mock implements AuthService {
  final Stream<User?> userStream;

  MockAuthService({required this.userStream});

  @override
  Stream<User?> get user => userStream;

  @override
  Future<String?> getUserRole(String? userId) async {
    return 'Staff'; 
  }
}

class MockUser extends Mock implements User {}

void main() {
  group('FencingApp Widget Tests', () {
    testWidgets('Displays SignInScreen when not authenticated', (WidgetTester tester) async {
      
      final mockAuthService = MockAuthService(userStream: Stream.value(null));

      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: mockAuthService),
          ],
          child: const MaterialApp(home: AuthWrapper()),
        ),
      );

      
      await tester.pumpAndSettle();

     
      expect(find.byType(SignInScreen), findsOneWidget);
    });
    

testWidgets('Displays error message on authentication error', (WidgetTester tester) async {
  final mockAuthService = MockAuthService(userStream: Stream.error('Authentication Error'));

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: mockAuthService),
      ],
      child: const MaterialApp(home: AuthWrapper()),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Authentication Error'), findsNothing);
});

testWidgets('Displays loading indicator while authenticating', (WidgetTester tester) async {
  final mockAuthService = MockAuthService(userStream: Stream.empty());

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: mockAuthService),
      ],
      child: const MaterialApp(home: AuthWrapper()),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
    

  });
}
