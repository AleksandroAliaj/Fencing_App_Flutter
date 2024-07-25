import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return FutureBuilder<String?>(
      future: authService.getUserRole(user?.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading user role: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('User role not found')),
          );
        }

        final role = snapshot.data!;
        print('User role: $role');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Shop'),
          ),
          body: ListView(
            children: <Widget>[
              ListTile(
                title: const Text('Abbigliamento e Equipaggiamento di Base'),
                onTap: () => _navigateToCategory(context, 'Abbigliamento e Equipaggiamento di Base'),
              ),
              ListTile(
                title: const Text('Armi'),
                onTap: () => _navigateToCategory(context, 'Armi'),
              ),
              ListTile(
                title: const Text('Accessori per le Armi'),
                onTap: () => _navigateToCategory(context, 'Accessori per le Armi'),
              ),
              ListTile(
                title: const Text('Protezioni e Accessori di Sicurezza'),
                onTap: () => _navigateToCategory(context, 'Protezioni e Accessori di Sicurezza'),
              ),
              ListTile(
                title: const Text('Borse e Custodie'),
                onTap: () => _navigateToCategory(context, 'Borse e Custodie'),
              ),
              ListTile(
                title: const Text('Prodotti per la Cura e la Manutenzione'),
                onTap: () => _navigateToCategory(context, 'Prodotti per la Cura e la Manutenzione'),
              ),
              ListTile(
                title: const Text('Gadget'),
                onTap: () => _navigateToCategory(context, 'Gadget'),
              ),
            ],
          ),
          floatingActionButton: role.toLowerCase() == 'staff'
              ? FloatingActionButton(
                  onPressed: () => _showAddProductDialog(context),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  void _navigateToCategory(BuildContext context, String category) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      final userData = await authService.getUserData(user.uid);
      final facilityCode = userData['facilityCode'];
      final userRole = userData['role'];
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductCategoryScreen(
            category: category,
            facilityCode: facilityCode,
            userRole: userRole,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile caricare la categoria. Riprova più tardi.')),
      );
    }
  }

  void _showAddProductDialog(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      final userData = await authService.getUserData(user.uid);
      final facilityCode = userData['facilityCode'];
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddProductDialog(facilityCode: facilityCode);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aggiungere il prodotto. Riprova più tardi.')),
      );
    }
  }
}

class ProductCategoryScreen extends StatelessWidget {
  final String category;
  final String facilityCode;
  final String userRole;

  const ProductCategoryScreen({
    Key? key,
    required this.category,
    required this.facilityCode,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('facilityCode', isEqualTo: facilityCode)
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Non ci sono prodotti disponibili in struttura'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['title'] ?? 'No title'),
                subtitle: Text('${data['price'] ?? 'N/A'} €'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        title: data['title'] ?? 'No title',
                        description: data['description'] ?? 'No description',
                        price: data['price'] ?? 'N/A',
                        category: category,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: userRole.toLowerCase() == 'staff'
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductsScreen(
                      category: category,
                      facilityCode: facilityCode,
                    ),
                  ),
                );
              },
              label: const Text('Modifica'),
              icon: const Icon(Icons.edit),
            )
          : null,
    );
  }
}

class EditProductsScreen extends StatefulWidget {
  final String category;
  final String facilityCode;

  const EditProductsScreen({
    Key? key,
    required this.category,
    required this.facilityCode,
  }) : super(key: key);

  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  Set<String> selectedProducts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica ${widget.category}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: selectedProducts.isNotEmpty ? _deleteSelectedProducts : null,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('facilityCode', isEqualTo: widget.facilityCode)
            .where('category', isEqualTo: widget.category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Non ci sono prodotti disponibili in questa categoria'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String productId = document.id;

              return CheckboxListTile(
                title: Text(data['title'] ?? 'No title'),
                subtitle: Text('${data['price'] ?? 'N/A'} €'),
                value: selectedProducts.contains(productId),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedProducts.add(productId);
                    } else {
                      selectedProducts.remove(productId);
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  void _deleteSelectedProducts() async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String productId in selectedProducts) {
        DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(productId);
        batch.delete(productRef);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prodotti eliminati con successo')),
      );

      setState(() {
        selectedProducts.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante l\'eliminazione dei prodotti: $e')),
      );
    }
  }
}
class ProductDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final String category;

  const ProductDetailScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: $category', style: Theme.of(context).textTheme.headline6),
            const SizedBox(height: 8),
            Text('Title: $title', style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 8),
            Text('Description: $description', style: Theme.of(context).textTheme.bodyText1),
            const SizedBox(height: 8),
            Text('Price: $price €', style: Theme.of(context).textTheme.bodyText1),
            const SizedBox(height: 16),
            Text('Prodotto disponibile in struttura', style: Theme.of(context).textTheme.bodyText1),

          ],
        ),
      ),
    );
  }
}

class AddProductDialog extends StatefulWidget {
  final String facilityCode;

  const AddProductDialog({Key? key, required this.facilityCode}) : super(key: key);

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  double _price = 0.0;
  String _category = 'Abbigliamento e Equipaggiamento di Base';

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      // Aggiunta del prodotto a Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'title': _title,
        'description': _description,
        'price': _price,
        'category': _category,
        'facilityCode': widget.facilityCode,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aggiungi Prodotto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Titolo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un titolo';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrizione'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci una descrizione';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Prezzo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un prezzo';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Inserisci un numero valido';
                  }
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: <String>[
                  'Abbigliamento e Equipaggiamento di Base',
                  'Armi',
                  'Accessori per le Armi',
                  'Protezioni e Accessori di Sicurezza',
                  'Borse e Custodie',
                  'Prodotti per la Cura e la Manutenzione',
                  'Gadget',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Annulla'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Pubblica'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              _addProduct();
            }
          },
        ),
      ],
    );
  }
}
