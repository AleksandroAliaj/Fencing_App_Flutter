// intervention_request_screen.dart

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
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToNewRequest(context, userId!),
              child: const Text('Nuova Richiesta'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToMyRequests(context, userId!),
              child: const Text('Le Mie Richieste'),
            ),
          ],
        );
      case 'staff':
        return Center(
          child: ElevatedButton(
            onPressed: () => _navigateToRequestList(context),
            child: const Text('Elenco Richieste'),
          ),
        );
      default:
        return Center(child: Text('Ruolo non riconosciuto: $role'));
    }
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

// Le altre classi (NewRequestScreen, MyRequestsScreen, RequestListScreen) rimangono invariate

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

  Future<void> _submitRequest() async {
    if (_repairController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      final userData = await Provider.of<AuthService>(context, listen: false).getUserData(widget.userId);
      await FirebaseFirestore.instance.collection('intervention_requests').add({
        'repair': _repairController.text,
        'description': _descriptionController.text,
        'userId': widget.userId,
        'facilityCode': widget.facilityCode,
        'status': 'In riparazione',
        'timestamp': FieldValue.serverTimestamp(),
        'firstName': userData['firstName'],
        'lastName': userData['lastName'],
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

                  return ListTile(
                    title: Text(doc['repair']),
                    subtitle: Text('${doc['description']}\n$firstName $lastName'),
                    trailing: doc['status'] == 'Confirmed'
                        ? const Text('Riparato', style: TextStyle(color: Colors.green))
                        : ElevatedButton(
                            onPressed: () async {
                              await doc.reference.update({'status': 'Confirmed'});
                            },
                            child: const Text('Riparato'),
                          ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
