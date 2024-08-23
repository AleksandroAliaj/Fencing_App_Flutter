// ignore_for_file: use_super_parameters, avoid_print, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({Key? key}) : super(key: key);

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
            title: const Text('News'),
          ),
          body: _buildNewsTab(context, role),
        );
      },
    );
  }

  Widget _buildNewsTab(BuildContext context, String role) {
    if (role.toLowerCase() == 'staff') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSquareButton(
                  context: context,
                  icon: Icons.add,
                  label: 'Aggiungi News',
                  onPressed: () => _navigateToAddNews(context),
                ),
                const SizedBox(width: 20),
                _buildSquareButton(
                  context: context,
                  icon: Icons.list,
                  label: 'Tutte le News',
                  onPressed: () => _navigateToNewsList(context),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      return NewsList(userId: user?.uid);
    }
  }

  Widget _buildSquareButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final double buttonSize = MediaQuery.of(context).size.width * 0.35;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 40),
            const SizedBox(height: 10),
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

  void _navigateToAddNews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNewsScreen()),
    );
  }

  void _navigateToNewsList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllNewsScreen()),
    );
  }
}

class AddNewsScreen extends StatefulWidget {
  @override
  _AddNewsScreenState createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _facilityCode;

  @override
  void initState() {
    super.initState();
    _loadFacilityCode();
  }

  Future<void> _loadFacilityCode() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      final userData = await authService.getUserData(user.uid);
      setState(() {
        _facilityCode = userData['facilityCode'];
      });
    }
  }

  Future<void> _submitNews() async {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _facilityCode != null) {
      await FirebaseFirestore.instance.collection('news').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'facilityCode': _facilityCode,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi News'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titolo',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitNews,
              child: const Text('Pubblica'),
            ),
          ],
        ),
      ),
    );
  }
}

class AllNewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: authService.getUserData(user!.uid), // Recupera i dati dell'utente
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading user data: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final facilityCode = userData['facilityCode']; // Recupera il facilityCode dell'utente

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tutte le News'),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('news')
                .where('facilityCode', isEqualTo: facilityCode) // Filtra per facilityCode
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Nessuna news trovata'));
              }

              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  return ListTile(
                    title: Text(doc['title']),
                    subtitle: Text(doc['description']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Conferma Eliminazione'),
                            content: const Text('Sei sicuro di voler eliminare questa news?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Annulla'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Elimina'),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete == true) {
                          await doc.reference.delete();
                        }
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }
}

class NewsList extends StatelessWidget {
  final String? userId;

  const NewsList({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<DocumentSnapshot>(
      future: authService.getUserData(userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User data not found'));
        }

        final userData = snapshot.data!;
        final facilityCode = userData['facilityCode'];

        return FutureBuilder<String?>(
          future: authService.getUserRole(userId),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (roleSnapshot.hasError) {
              return Center(child: Text('Error loading user role: ${roleSnapshot.error}'));
            }
            if (!roleSnapshot.hasData || roleSnapshot.data == null) {
              return const Center(child: Text('User role not found'));
            }

            final role = roleSnapshot.data!;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('news')
                  .where('facilityCode', isEqualTo: facilityCode)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nessuna news trovata'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['title']),
                      subtitle: Text(doc['description']),
                      trailing: role.toLowerCase() == 'staff'
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Conferma Eliminazione'),
                                    content: const Text('Sei sicuro di voler eliminare questa news?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Annulla'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Elimina'),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldDelete == true) {
                                  await doc.reference.delete();
                                }
                              },
                            )
                          : null,
                    );
                  }).toList(),
                );
              },
            );
          },
        );
      },
    );
  }
}
