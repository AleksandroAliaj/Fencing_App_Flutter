import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'auth_service.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

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

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Calendario'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Eventi'),
                  Tab(text: 'Scadenziario'),
                  Tab(text: 'Agenda'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Center(child: Text('Eventi')), // Placeholder
                _buildScadenziarioTab(context, role),
                AgendaTab(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScadenziarioTab(BuildContext context, String role) {
    if (role.toLowerCase() == 'staff') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToAddDeadline(context),
              child: const Text('Inserisci Scadenza'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToDeadlineList(context),
              child: const Text('Elenco Scadenze'),
            ),
          ],
        ),
      );
    } else {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      return DeadlineList(userId: user?.uid);
    }
  }

  void _navigateToAddDeadline(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDeadlineScreen()),
    );
  }

  void _navigateToDeadlineList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeadlineListScreen()),
    );
  }
}

class AddDeadlineScreen extends StatefulWidget {
  @override
  _AddDeadlineScreenState createState() => _AddDeadlineScreenState();
}

class _AddDeadlineScreenState extends State<AddDeadlineScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  Future<void> _submitDeadline() async {
    if (_firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _deadlineController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('deadlines').add({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'text': _deadlineController.text,
        'status': 'Pending',
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserisci Scadenza'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Cognome',
              ),
            ),
            TextField(
              controller: _deadlineController,
              decoration: const InputDecoration(
                labelText: 'Scadenza',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitDeadline,
              child: const Text('Invia'),
            ),
          ],
        ),
      ),
    );
  }
}

class DeadlineListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elenco Scadenze'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('deadlines').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nessuna scadenza trovata'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['text']),
                subtitle: Text('${doc['firstName']} ${doc['lastName']}'),
                trailing: doc['status'] == 'Confirmed'
                    ? const Text('Confirmed', style: TextStyle(color: Colors.green))
                    : ElevatedButton(
                        onPressed: () async {
                          await doc.reference.update({'status': 'Confirmed'});
                        },
                        child: const Text('Conferma'),
                      ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class DeadlineList extends StatelessWidget {
  final String? userId;

  const DeadlineList({Key? key, required this.userId}) : super(key: key);

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
        final firstName = userData['firstName'];
        final lastName = userData['lastName'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('deadlines')
              .where('firstName', isEqualTo: firstName)
              .where('lastName', isEqualTo: lastName)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Nessuna scadenza trovata'));
            }

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return ListTile(
                  title: Text(doc['text']),
                  subtitle: Text(doc['status']),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class AgendaTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Agenda Tab Placeholder'),
      ),
    );
  }
}
