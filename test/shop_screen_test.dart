// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing/auth_service.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
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