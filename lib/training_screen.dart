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

class PrivateLessonTab extends StatefulWidget {
  @override
  _PrivateLessonTabState createState() => _PrivateLessonTabState();
}

class _PrivateLessonTabState extends State<PrivateLessonTab> {
  bool _showCreateLesson = false;

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

        if (role == 'allenatore') {
          return _showCreateLesson
              ? CreateLessonScreen(onCancel: () {
                  setState(() {
                    _showCreateLesson = false;
                  });
                })
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showCreateLesson = true;
                        });
                      },
                      child: const Text('Aggiungi Lezione'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CoachLessonsScreen()),
                        );
                      },
                      child: const Text('Le Mie Lezioni'),
                    ),
                  ],
                );
        } else if (role == 'atleta') {
          return AthleteLesson();
        } else if (role == 'staff') {
          return StaffLessonView();
        } else {
          return const Center(child: Text('Ruolo non riconosciuto'));
        }
      },
    );
  }
}

class CreateLessonScreen extends StatefulWidget {
  final VoidCallback onCancel;

  const CreateLessonScreen({required this.onCancel});

  @override
  _CreateLessonScreenState createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _athleteName = '';
  String _athleteSurname = '';

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
      _formKey.currentState!.save();
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final userData = await authService.getUserData(user!.uid);

      await FirebaseFirestore.instance.collection('private_lessons').add({
        'date': Timestamp.fromDate(_selectedDate),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'athleteName': _athleteName,
        'athleteSurname': _athleteSurname,
        'facilityCode': userData['facilityCode'],
        'coachName': userData['firstName'],
        'coachSurname': userData['lastName'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lezione creata con successo')),
      );

      widget.onCancel();
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
              decoration: const InputDecoration(labelText: 'Nome Atleta'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci il nome dell\'atleta';
                }
                return null;
              },
              onSaved: (value) => _athleteName = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Cognome Atleta'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci il cognome dell\'atleta';
                }
                return null;
              },
              onSaved: (value) => _athleteSurname = value!,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: _submitLesson,
                  child: const Text('Crea Lezione'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CoachLessonsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: authService.getUserData(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error loading user data'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final coachName = userData['firstName'];
        final coachSurname = userData['lastName'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Le Mie Lezioni'),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('private_lessons')
                .where('coachName', isEqualTo: coachName)
                .where('coachSurname', isEqualTo: coachSurname)
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
                    subtitle: Text(
                      'Ora: ${data['time']}\nAtleta: ${data['athleteName']} ${data['athleteSurname']}',
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

class AthleteLesson extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: authService.getUserData(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error loading user data'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final athleteName = userData['firstName'];
        final athleteSurname = userData['lastName'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('private_lessons')
              .where('athleteName', isEqualTo: athleteName)
              .where('athleteSurname', isEqualTo: athleteSurname)
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
                  subtitle: Text('Ora: ${data['time']}\nCoach: ${data['coachName']} ${data['coachSurname']}'),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class StaffLessonView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: authService.getUserData(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error loading user data'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final facilityCode = userData['facilityCode'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('private_lessons')
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
              return const Center(child: Text('Nessuna lezione privata programmata'));
            }

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final date = (data['date'] as Timestamp).toDate();
                return ListTile(
                  title: Text('Lezione del ${date.day}/${date.month}/${date.year}'),
                  subtitle: Text(
                    'Ora: ${data['time']}\nAtleta: ${data['athleteName']} ${data['athleteSurname']}\nCoach: ${data['coachName']} ${data['coachSurname']}',
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
