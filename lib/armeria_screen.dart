import 'package:flutter/material.dart';
import 'shop_screen.dart';
import 'intervention_request_screen.dart';

class ArmeriaScreen extends StatelessWidget {
  const ArmeriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double buttonSize = isLandscape
        ? MediaQuery.of(context).size.width * 0.25  // Riduci la dimensione in landscape
        : MediaQuery.of(context).size.width * 0.35; // Dimensione normale in portrait

    return Scaffold(
      appBar: AppBar(
        title: const Text('Armeria'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSquareButton(
                    context: context,
                    buttonSize: buttonSize,
                    icon: Icons.shopping_cart,
                    label: 'Shop',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ShopScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 20), // Spazio tra i due bottoni
                  _buildSquareButton(
                    context: context,
                    buttonSize: buttonSize,
                    icon: Icons.build,
                    label: 'Richiesta di Intervento',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InterventionRequestScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton({
    required BuildContext context,
    required double buttonSize,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Colore di sfondo bianco
          side: const BorderSide(color: Colors.black, width: 2), // Bordo nero
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Angoli leggermente arrotondati
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 40), // Icona nera
            const SizedBox(height: 10), // Spazio tra l'icona e il testo
            Text(
              label,
              style: const TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
