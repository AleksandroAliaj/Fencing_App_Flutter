import 'package:flutter/material.dart';
import 'shop_screen.dart';
import 'intervention_request_screen.dart';

class ArmeriaScreen extends StatelessWidget {
  const ArmeriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Armeria'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopScreen()),
                );
              },
              child: const Text('Shop'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InterventionRequestScreen()),
                );
              },
              child: const Text('Richiesta di Intervento'),
            ),
          ],
        ),
      ),
    );
  }
}
