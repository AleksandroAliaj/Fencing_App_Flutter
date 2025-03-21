// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously, use_super_parameters, use_key_in_widget_constructors, unused_element, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'auth_service.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

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
                _buildEventiTab(context, role),
                _buildScadenziarioTab(context, role),
                AgendaTab(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventiTab(BuildContext context, String role) {
    if (role.toLowerCase() == 'staff') {
      return Center(
        child: Wrap(
          spacing: 20.0, 
          runSpacing: 20.0, 
          alignment: WrapAlignment.center, 
          children: [
            _buildActionButton(
              context,
              'Aggiungi Evento',
              Icons.add,
              () => _navigateToAddEvent(context),
            ),
            _buildActionButton(
              context,
              'Elenco Eventi',
              Icons.list,
              () => _navigateToEventList(context),
            ),
          ],
        ),
      );
    } else {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      return EventList(userId: user?.uid);
    }
  }

  Widget _buildScadenziarioTab(BuildContext context, String role) {
    if (role.toLowerCase() == 'staff') {
      return Center(
        child: Wrap(
          spacing: 20.0, 
          runSpacing: 20.0, 
          alignment: WrapAlignment.center, 
          children: [
            _buildActionButton(
              context,
              'Inserisci Scadenza',
              Icons.calendar_today,
              () => _navigateToAddDeadline(context),
            ),
            _buildActionButton(
              context,
              'Elenco Scadenze',
              Icons.list,
              () => _navigateToDeadlineList(context),
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

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.black, size: 40.0), 
            const SizedBox(height: 8.0), 
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

  void _navigateToAddEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEventScreen()),
    );
  }

  void _navigateToEventList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventListScreen()),
    );
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

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _locationController = TextEditingController();
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

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _submitEvent() async {
    if (_selectedDate != null && _selectedTime != null && _locationController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _facilityCode != null) {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      await FirebaseFirestore.instance.collection('events').add({
        'date': Timestamp.fromDate(dateTime),
        'location': _locationController.text,
        'description': _descriptionController.text,
        'facilityCode': _facilityCode,
      });
      Navigator.pop(context);
    } else {
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Errore"),
            content: const Text("Per favore, completa tutti i campi richiesti."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(_selectedDate == null ? 'Seleziona Data' : 'Data: ${_selectedDate!.toLocal()}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            ListTile(
              title: Text(_selectedTime == null ? 'Seleziona Ora' : 'Ora: ${_selectedTime!.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Luogo',
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
              onPressed: _submitEvent,
              child: const Text('Pubblica'),
            ),
          ],
        ),
      ),
    );
  }
}

class EventList extends StatelessWidget {
  final String? userId;

  const EventList({Key? key, required this.userId}) : super(key: key);

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
        final role = userData['role'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .where('facilityCode', isEqualTo: facilityCode)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Nessun evento trovato'));
            }

            
            final now = DateTime.now();
            final eventDocuments = snapshot.data!.docs;

            for (final doc in eventDocuments) {
              final date = (doc['date'] as Timestamp).toDate();
              if (date.add(const Duration(days: 1)).isBefore(now)) {
                
                doc.reference.delete();
              }
            }

            
            final validEventDocuments = eventDocuments.where((doc) {
              final date = (doc['date'] as Timestamp).toDate();
              return date.add(const Duration(days: 1)).isAfter(now);
            }).toList();

            return Padding(
              padding: const EdgeInsets.only(top: 16.0),  
              child: ListView.builder(
                itemCount: validEventDocuments.length,
                itemBuilder: (context, index) {
                  final doc = validEventDocuments[index];
                  final date = (doc['date'] as Timestamp).toDate();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildEventButton(
                      context: context,
                      icon: Icons.event,
                      title: doc['description'],
                      subtitle: '${date.day}-${date.month}-${date.year} @ ${date.hour}:${date.minute}\n${doc['location']}',
                      onPressed: () {
                        
                      },
                      onDelete: role.toLowerCase() == 'staff'
                          ? () => _showDeleteConfirmation(context, doc)
                          : null,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    VoidCallback? onDelete,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.black, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma Eliminazione'),
          content: const Text('Sei sicuro di voler eliminare questo evento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                await doc.reference.delete();
                Navigator.of(context).pop();
              },
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }
}

class EventListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: authService.getUserData(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }


        return Scaffold(
          appBar: AppBar(
            title: const Text('Elenco Eventi'),
          ),
          body: EventList(userId: user.uid),
        );
      },
    );
  }
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


class AddDeadlineScreen extends StatefulWidget {
  @override
  _AddDeadlineScreenState createState() => _AddDeadlineScreenState();
}

class _AddDeadlineScreenState extends State<AddDeadlineScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  DateTime? _selectedDate;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitDeadline() async {
    if (_firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _deadlineController.text.isNotEmpty &&
        _selectedDate != null &&
        _facilityCode != null) {
      await FirebaseFirestore.instance.collection('deadlines').add({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'text': _deadlineController.text,
        'status': 'Pending',
        'facilityCode': _facilityCode,
        'deadlineDate': Timestamp.fromDate(_selectedDate!),  
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
                labelText: 'Descrizione Scadenza',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(_selectedDate == null
                      ? 'Seleziona una data'
                      : 'Data selezionata: ${_selectedDate!.toLocal()}'),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Seleziona Data'),
                ),
              ],
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
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: authService.getUserData(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        final userData = snapshot.data!;
        final facilityCode = userData['facilityCode'];
        final role = userData['role'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Elenco Scadenze'),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('deadlines')
                .where('facilityCode', isEqualTo: facilityCode)
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

              final now = DateTime.now();
              final twelveMonthsAgo = now.subtract(const Duration(days: 200));

              final validDeadlines = snapshot.data!.docs.where((doc) {
                final deadlineDate = (doc['deadlineDate'] as Timestamp).toDate();
                if (deadlineDate.isBefore(twelveMonthsAgo)) {
                  doc.reference.delete();
                  return false;
                }
                return true;
              }).toList();

              return ListView.builder(
                itemCount: validDeadlines.length,
                itemBuilder: (context, index) {
                  final doc = validDeadlines[index];
                  return _buildDeadlineCard(
                    context: context,
                    text: doc['text'],
                    name: '${doc['firstName']} ${doc['lastName']}',
                    date: (doc['deadlineDate'] as Timestamp).toDate(),
                    status: doc['status'],
                    role: role,
                    onDelete: role.toLowerCase() == 'staff'
                        ? () => _showDeleteConfirmation(context, doc)
                        : null,
                    onConfirm: role.toLowerCase() == 'staff' && doc['status'] != 'Confirmed'
                        ? () => _confirmDeadline(context, doc)
                        : null,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDeadlineCard({
    required BuildContext context,
    required String text,
    required String name,
    required DateTime date,
    required String status,
    required String role,
    VoidCallback? onDelete,
    VoidCallback? onConfirm,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Text(
              '${date.day}-${date.month}-${date.year}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status == 'Confirmed' ? 'Confermato' : 'In attesa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: status == 'Confirmed' ? Colors.green : Colors.orange,
                  ),
                ),
                if (role.toLowerCase() == 'staff')
                  Row(
                    children: [
                      if (onConfirm != null)
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: onConfirm,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma Eliminazione'),
          content: const Text('Sei sicuro di voler eliminare questa scadenza?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                await doc.reference.delete();
                Navigator.of(context).pop();
              },
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeadline(BuildContext context, DocumentSnapshot doc) async {
    await doc.reference.update({'status': 'Confirmed'});
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
        final facilityCode = userData['facilityCode'];
        final role = userData['role'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('deadlines')
              .where('firstName', isEqualTo: firstName)
              .where('lastName', isEqualTo: lastName)
              .where('facilityCode', isEqualTo: facilityCode)
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

            final now = DateTime.now();
            final twelveMonthsAgo = now.subtract(const Duration(days: 200));

            
            final validDeadlines = snapshot.data!.docs.where((doc) {
              final deadlineDate = (doc['deadlineDate'] as Timestamp).toDate();
              if (deadlineDate.isBefore(twelveMonthsAgo)) {
                
                doc.reference.delete();
                return false;
              }
              return true;
            }).toList();

            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ListView.builder(
                itemCount: validDeadlines.length,
                itemBuilder: (context, index) {
                  final doc = validDeadlines[index];
                  final deadlineDate = (doc['deadlineDate'] as Timestamp).toDate();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildDeadlineButton(
                      context: context,
                      icon: Icons.event_note,
                      title: doc['text'],
                      subtitle: '${doc['firstName']} ${doc['lastName']}\n${deadlineDate.day}-${deadlineDate.month}-${deadlineDate.year}',
                      status: doc['status'],
                      onPressed: () {
                        
                      },
                      onDelete: role.toLowerCase() == 'staff'
                          ? () => _showDeleteConfirmation(context, doc)
                          : null,
                      onConfirm: role.toLowerCase() == 'staff' && doc['status'] != 'Confirmed'
                          ? () => _confirmDeadline(context, doc)
                          : null,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDeadlineButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required VoidCallback onPressed,
    VoidCallback? onDelete,
    VoidCallback? onConfirm,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.black, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
                if (status == 'Confirmed')
                  const Text(
                    'Confermato',
                    style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          if (onConfirm != null)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: onConfirm,
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma Eliminazione'),
          content: const Text('Sei sicuro di voler eliminare questa scadenza?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                await doc.reference.delete();
                Navigator.of(context).pop();
              },
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeadline(BuildContext context, DocumentSnapshot doc) async {
    await doc.reference.update({'status': 'Confirmed'});
  }
}

class AgendaTab extends StatefulWidget {
  @override
  _AgendaTabState createState() => _AgendaTabState();
}

class _AgendaTabState extends State<AgendaTab> {
  late ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadEvents();
  }

  void _loadEvents() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      final userData = await authService.getUserData(user.uid);
      final firstName = userData['firstName'];
      final lastName = userData['lastName'];
      final fullName = '$firstName $lastName';
      final role = userData['role'];
      final facilityCode = userData['facilityCode'];

      setState(() {
        _userRole = role; 
      });

      if (role.toLowerCase() == 'staff') {
        
        await _loadFacilityEvents(facilityCode);
      } else {
        
        await _loadPersonalEvents(firstName, lastName, fullName);
      }

      setState(() {
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    }
  }

  Future<void> _loadFacilityEvents(String facilityCode) async {
    
    final lessonsSnapshot = await FirebaseFirestore.instance
        .collection('private_lessons')
        .where('facilityCode', isEqualTo: facilityCode)
        .get();

   
    final combattimentiSnapshot = await FirebaseFirestore.instance
        .collection('combattimenti')
        .where('facilityCode', isEqualTo: facilityCode)
        .get();

   
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('facilityCode', isEqualTo: facilityCode)
        .get();

    _processEvents(lessonsSnapshot, 'lesson');
    _processEvents(combattimentiSnapshot, 'combattimento');
    _processEvents(eventsSnapshot, 'event');
  }

  Future<void> _loadPersonalEvents(String firstName, String lastName, String fullName) async {
    
    final lessonsSnapshot = await FirebaseFirestore.instance
        .collection('private_lessons')
        .where('athleteName', isEqualTo: firstName)
        .where('athleteSurname', isEqualTo: lastName)
        .get();

    final coachLessonsSnapshot = await FirebaseFirestore.instance
        .collection('private_lessons')
        .where('coachName', isEqualTo: firstName)
        .where('coachSurname', isEqualTo: lastName)
        .get();

    
    final combattimentiSnapshot = await FirebaseFirestore.instance
        .collection('combattimenti')
        .where('athletes', arrayContains: fullName)
        .get();

    final coachCombattimentiSnapshot = await FirebaseFirestore.instance
        .collection('combattimenti')
        .where('coachName', isEqualTo: firstName)
        .where('coachSurname', isEqualTo: lastName)
        .get();

    _processEvents(lessonsSnapshot, 'lesson');
    _processEvents(coachLessonsSnapshot, 'lesson');
    _processEvents(combattimentiSnapshot, 'combattimento');
    _processEvents(coachCombattimentiSnapshot, 'combattimento');
  }

  void _processEvents(QuerySnapshot snapshot, String eventType) {
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      final eventDate = DateTime(date.year, date.month, date.day);

      final event = Event(
        title: _getEventTitle(eventType, data),
        time: data['time'] ?? '',
        coachName: _getCoachName(data),
        athleteName: _getAthleteName(data),
        date: date,
        type: eventType,
      );

      if (_events[eventDate] == null) _events[eventDate] = [];
      _events[eventDate]!.add(event);
    }
  }

  String _getEventTitle(String eventType, Map<String, dynamic> data) {
    switch (eventType) {
      case 'lesson':
        return 'Lezione privata';
      case 'combattimento':
        return 'Combattimento ${data['type'] ?? ''}';
      case 'event':
        return data['description'] ?? 'Evento';
      default:
        return 'Evento';
    }
  }

  String _getCoachName(Map<String, dynamic> data) {
    return '${data['coachName'] ?? ''} ${data['coachSurname'] ?? ''}';
  }

  String _getAthleteName(Map<String, dynamic> data) {
    if (data['athletes'] != null) {
      return (data['athletes'] as List<dynamic>).join(', ');
    }
    return '${data['athleteName'] ?? ''} ${data['athleteSurname'] ?? ''}';
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents.value = _getEventsForDay(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Event>(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            markerDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: () => _showEventDetails(context, events[index]),
                      title: Text(events[index].title),
                      subtitle: _userRole.toLowerCase() != 'staff'
                          ? Text('Ora: ${events[index].time}\nAllenatore: ${events[index].coachName}\nAtleta: ${events[index].athleteName}')
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: _userRole.toLowerCase() != 'null'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Data: ${event.date.day}/${event.date.month}/${event.date.year}'),
                  Text('Ora: ${event.time}'),
                  Text('Allenatore: ${event.coachName}'),
                  Text('Atleta: ${event.athleteName}'),
                ],
              )
            : null,
        actions: [
          TextButton(
            child: const Text('Chiudi'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;
  final String time;
  final String coachName;
  final String athleteName;
  final DateTime date;
  final String type;

  const Event({
    required this.title,
    required this.time,
    required this.coachName,
    required this.athleteName,
    required this.date,
    required this.type,
  });
}

