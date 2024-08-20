// intervention_request_screen.dart

// ignore_for_file: file_names, use_super_parameters, avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class InterventionRequestScreen extends StatelessWidget {
  const InterventionRequestScreen({Key? key}) : super(key: key);

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
            title: const Text('Richiesta di Intervento'),
          ),
          body: _buildBody(context, role, user?.uid),
        );
      },
    );
  }

Widget _buildBody(BuildContext context, String role, String? userId) {
  switch (role.toLowerCase()) {
    case 'atleta':
    case 'allenatore':
      return Center(
        child: _buildStyledButton(
          context,
          'Le Mie Richieste',
          Icons.list,
          () => _navigateToMyRequests(context, userId!),
        ),
      );
    case 'staff':
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStyledButton(
              context,
              'Nuova Richiesta',
              Icons.add_circle_outline,
              () => _navigateToNewRequest(context, userId!),
            ),
            _buildStyledButton(
              context,
              'Elenco Richieste',
              Icons.view_list,
              () => _navigateToRequestList(context),
            ),
          ],
        ),
      );
    default:
      return Center(child: Text('Ruolo non riconosciuto: $role'));
  }
}

Widget _buildStyledButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
  final double buttonSize = MediaQuery.of(context).size.width * 0.30;

  return Container(
    margin: const EdgeInsets.all(8.0),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: Colors.black, size: 35.0),
          const SizedBox(height: 6.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    ),
  );
}

  void _navigateToNewRequest(BuildContext context, String userId) async {
    final facilityCode = await _getFacilityCode(context, userId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewRequestScreen(facilityCode: facilityCode, userId: userId),
      ),
    );
  }

  void _navigateToMyRequests(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyRequestsScreen(userId: userId),
      ),
    );
  }

  void _navigateToRequestList(BuildContext context) async {
    final userId = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
    if (userId != null) {
      final facilityCode = await _getFacilityCode(context, userId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestListScreen(facilityCode: facilityCode),
        ),
      );
    }
  }

  Future<String> _getFacilityCode(BuildContext context, String userId) async {
    final userData = await Provider.of<AuthService>(context, listen: false).getUserData(userId);
    return userData['facilityCode'] as String;
  }
}

class NewRequestScreen extends StatefulWidget {
  final String facilityCode;
  final String userId;

  const NewRequestScreen({Key? key, required this.facilityCode, required this.userId}) : super(key: key);

  @override
  _NewRequestScreenState createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final TextEditingController _repairController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedUserId;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final userId = widget.userId; // Ottieni l'userId dall'oggetto widget
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  
    if (userDoc.exists) {
      final facilityCode = userDoc['facilityCode'];
    
      final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('facilityCode', isEqualTo: facilityCode)
        .get();
    
      setState(() {
        _users = snapshot.docs.map((doc) => {
          'id': doc.id,
          'firstName': doc['firstName'],
          'lastName': doc['lastName'],
        }).toList();
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_repairController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _selectedUserId != null) {
      final selectedUser = _users.firstWhere((user) => user['id'] == _selectedUserId);

      await FirebaseFirestore.instance.collection('intervention_requests').add({
        'repair': _repairController.text,
        'description': _descriptionController.text,
        'userId': _selectedUserId,
        'facilityCode': widget.facilityCode,
        'status': 'In riparazione',
        'timestamp': FieldValue.serverTimestamp(),
        'firstName': selectedUser['firstName'],
        'lastName': selectedUser['lastName'],
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuova Richiesta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _repairController,
              decoration: const InputDecoration(
                labelText: 'Cosa devi riparare?',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrivi il problema',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              hint: const Text('Seleziona l\'utente'),
              value: _selectedUserId,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUserId = newValue;
                });
              },
              items: _users.map<DropdownMenuItem<String>>((user) {
                return DropdownMenuItem<String>(
                  value: user['id'],
                  child: Text('${user['firstName']} ${user['lastName']}'),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRequest,
              child: const Text('Invia'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyRequestsScreen extends StatelessWidget {
  final String userId;

  const MyRequestsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le Mie Richieste'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('intervention_requests')
            .where('userId', isEqualTo: userId)
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
            return const Center(child: Text('Nessuna richiesta trovata'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['repair']),
                subtitle: Text(doc['description']),
                trailing: Text(doc['status']),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class RequestListScreen extends StatelessWidget {
  final String facilityCode;

  const RequestListScreen({Key? key, required this.facilityCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return FutureBuilder<String?>(
      future: authService.getUserRole(user?.uid),
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (roleSnapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading user role: ${roleSnapshot.error}')),
          );
        }

        if (!roleSnapshot.hasData || roleSnapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('User role not found')),
          );
        }

        final role = roleSnapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Elenco Richieste'),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('intervention_requests')
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
                return const Center(child: Text('Nessuna richiesta trovata'));
              }

              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(doc['userId']).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(title: Text('Loading...'));
                      }
                      if (userSnapshot.hasError) {
                        return ListTile(title: Text('Error: ${userSnapshot.error}'));
                      }
                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const ListTile(title: Text('User not found'));
                      }

                      final userData = userSnapshot.data!;
                      final firstName = userData['firstName'];
                      final lastName = userData['lastName'];
                      final status = doc['status'];

                      return ListTile(
                        title: Text(doc['repair']),
                        subtitle: Text('${doc['description']}\n$firstName $lastName'),
                        trailing: role.toLowerCase() == 'staff'
                            ? status == 'Riparato'
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Riparato',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final shouldDelete = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Conferma Eliminazione'),
                                              content: const Text('Sei sicuro di voler eliminare questa richiesta?'),
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
                                    ],
                                  )
                                : ElevatedButton(
                                    onPressed: () async {
                                      await doc.reference.update({'status': 'Riparato'});
                                    },
                                    child: const Text('Riparato'),
                                  )
                            : Text(status),
                      );
                    },
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
