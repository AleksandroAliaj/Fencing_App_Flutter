import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Allenamento'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Lezione privata'),
              Tab(text: 'Assalti'),
              Tab(text: 'Preparazione atleti'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PrivateLessonTab(),
            Center(child: Text('Assalti')), // Placeholder
            Center(child: Text('Preparazione atleti')), // Placeholder
          ],
        ),
      ),
    );
  }
}

class PrivateLessonTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return FutureBuilder<String?>(
      future: authService.getUserRole(user?.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error loading user role'));
        }

        final role = snapshot.data!.toLowerCase();

        if (role == 'allenatore' || role == 'staff') {
          return CreateLessonScreen();
        } else if (role == 'atleta') {
          return AthleteLesson();
        } else {
          return const Center(child: Text('Ruolo non riconosciuto'));
        }
      },
    );
  }
}

class CreateLessonScreen extends StatefulWidget {
  @override
  _CreateLessonScreenState createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _athleteId = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitLesson() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Questo salverà il valore di _athleteId
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final userData = await authService.getUserData(user!.uid);

      await FirebaseFirestore.instance.collection('private_lessons').add({
        'date': Timestamp.fromDate(_selectedDate),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'athleteId': _athleteId, // Ora questo verrà salvato correttamente
        'facilityCode': userData['facilityCode'],
        'coachId': user.uid,
        'coachEmail': user.email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lezione creata con successo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'ID Atleta'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci l\'ID dell\'atleta';
                }
                return null;
              },
              onSaved: (value) => _athleteId = value!, // Questo salva il valore in _athleteId
            ),
            ListTile(
              title: const Text('Data'),
              subtitle: Text("${_selectedDate.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: const Text('Ora'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            ElevatedButton(
              onPressed: _submitLesson,
              child: const Text('Crea Lezione'),
            ),
          ],
        ),
      ),
    );
  }
}

class AthleteLesson extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('private_lessons')
          .where('athleteId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nessuna lezione privata programmata'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            return ListTile(
              title: Text('Lezione del ${date.day}/${date.month}/${date.year}'),
              subtitle: Text('Ora: ${data['time']}\nAllenatore: ${data['coachEmail']}'),
            );
          }).toList(),
        );
      },
    );
  }
}