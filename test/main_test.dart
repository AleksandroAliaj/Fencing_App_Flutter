import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:fencing/main.dart';
import 'package:fencing/auth_service.dart';
import 'package:fencing/sign_in_screen.dart';


// Mocking FirebaseAuth and AuthService
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
      // Arrange
      final mockAuthService = MockAuthService(userStream: Stream.value(null));

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: mockAuthService),
          ],
          child: const MaterialApp(home: AuthWrapper()),
        ),
      );

      // Permetti al widget tree di stabilizzarsi
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SignInScreen), findsOneWidget);
    });

  });
}
