

import 'package:fencing/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fencing/auth_service.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  Future<String?> getUserRole(String? uid) async {
    return 'Allenatore';
  }
}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    when(mockAuthService.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Provider<AuthService>(
        create: (_) => mockAuthService,
        child: const UserListScreen(),
      ),
    );
  }



  testWidgets('Test presenza del titolo Allenamento', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Cerca un utente...'), findsOneWidget);
  });


}