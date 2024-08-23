// ignore_for_file: use_super_parameters, avoid_print, use_build_context_synchronously, library_private_types_in_public_api, unnecessary_const

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          body: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildCategoryButton(
                context: context,
                icon: Icons.checkroom,
                label: 'Abbigliamento e Equipaggiamento di Base',
                onPressed: () => _navigateToCategory(context, 'Abbigliamento e Equipaggiamento di Base'),
              ),
              _buildCategoryButton(
                context: context,
                icon: Icons.security,
                label: 'Armi',
                onPressed: () => _navigateToCategory(context, 'Armi'),
              ),
              _buildCategoryButton(
                context: context,
                icon: Icons.build,
                label: 'Accessori per le Armi',
                onPressed: () => _navigateToCategory(context, 'Accessori per le Armi'),
              ),
              _buildCategoryButton(
                context: context,
                icon: Icons.shield,
                label: 'Protezioni e Accessori di Sicurezza',
                onPressed: () => _navigateToCategory(context, 'Protezioni e Accessori di Sicurezza'),
              ),
              _buildCategoryButton(
                context: context,
                icon: Icons.work,
                label: 'Borse e Custodie',
                onPressed: () => _navigateToCategory(context, 'Borse e Custodie'),
              ),
              _buildCategoryButton(
                context: context,
                icon: Icons.cleaning_services,
                label: 'Prodotti per la Cura e la Manutenzione',
                onPressed: () => _navigateToCategory(context, 'Prodotti per la Cura e la Manutenzione'),
              ),
              _buildCategoryButton(
                context: context,
                icon: Icons.emoji_objects,
                label: 'Gadget',
                onPressed: () => _navigateToCategory(context, 'Gadget'),
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

  Widget _buildCategoryButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.black, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 40),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
                //subtitle: Text('${data['price'] ?? 'N/A'} €'),
                subtitle: Text('${(data['price'] as num).toDouble()} €'),

                trailing: userRole.toLowerCase() == 'staff'
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteProduct(context, document.id);
                        },
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        title: data['title'] ?? 'No title',
                        description: data['description'] ?? 'No description',
                        //price: data['price'] ?? 'N/A',
                        price: (data['price'] as num).toDouble(),
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
      // floatingActionButton: userRole.toLowerCase() == 'staff'
      //     ? FloatingActionButton.extended(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => EditProductsScreen(
      //                 category: category,
      //                 facilityCode: facilityCode,
      //               ),
      //             ),
      //           );
      //         },
      //         //label: const Text('Modifica'),
      //         icon: const Icon(Icons.edit),
      //       )
      //    : null,
    );
  }

  void _deleteProduct(BuildContext context, String productId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prodotto eliminato con successo')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante l\'eliminazione del prodotto: $e')),
      );
    }
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
      //appBar: AppBar(
      //  title: Text('Modifica ${widget.category}'),
      //  actions: [
      //    IconButton(
      //      icon: const Icon(Icons.delete),
      //      onPressed: selectedProducts.isNotEmpty ? _deleteSelectedProducts : null,
      //    ),
      //  ],
      //),
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
                //subtitle: Text('${data['price'] ?? 'N/A'} €'),
                subtitle: Text('${(data['price'] as num).toDouble()} €'),

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
        title: const Text('Dettaglio Prodotto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            const Divider(height: 32, thickness: 2),
            Text(
              'Descrizione:',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.black87,
                    height: 1.5,
                  ),
            ),
            const Divider(height: 32, thickness: 2),
            Text(
              'Prezzo:',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$price €',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: const Text('Prodotto disponibile in struttura'),
              // child: ElevatedButton(
              //   onPressed: () {
              //     // Logica per l'acquisto del prodotto
              //   },
              //   child: const Text('Compra Ora'),
              // ),
            ),
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
                //onSaved: (value) => _price = double.parse(value!),
                onSaved: (value) => _price = double.parse(value!).toDouble(),
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