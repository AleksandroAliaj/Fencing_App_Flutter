import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Abbigliamento e Equipaggiamento di Base'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProductCategoryScreen(category: 'Abbigliamento e Equipaggiamento di Base')),
              );
            },
          ),
          ListTile(
            title: const Text('Armi'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductCategoryScreen(category: 'Armi')),
              );
            },
          ),
          ListTile(
            title: const Text('Accessori per le Armi'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductCategoryScreen(category: 'Accessori per le Armi')),
              );
            },
          ),
          ListTile(
            title: const Text('Protezioni e Accessori di Sicurezza'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductCategoryScreen(category: 'Protezioni e Accessori di Sicurezza')),
              );
            },
          ),
          ListTile(
            title: const Text('Borse e Custodie'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductCategoryScreen(category: 'Borse e Custodie')),
              );
            },
          ),
          ListTile(
            title: const Text('Prodotti per la Cura e la Manutenzione'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductCategoryScreen(category: 'Prodotti per la Cura e la Manutenzione')),
              );
            },
          ),
          ListTile(
            title: const Text('Gadget'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductCategoryScreen(category: 'Gadget')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProductCategoryScreen extends StatelessWidget {
  final String category;

  const ProductCategoryScreen({Key? key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: Center(
        child: Text('Prodotti disponibili per $category'),
        // Qui aggiungi il codice per visualizzare i prodotti disponibili
      ),
    );
  }
}
