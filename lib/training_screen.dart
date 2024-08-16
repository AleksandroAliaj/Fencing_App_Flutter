// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously, prefer_final_fields, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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
              Tab(text: 'Preparazione atletica'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PrivateLessonTab(),
            AssaltiTab(),
            AthleticPreparationTab(),
          ],
        ),
      ),
    );
  }
}

// Preparazione atletica

class AthleticPreparationTab extends StatelessWidget {
  const AthleticPreparationTab({Key? key}) : super(key: key);

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
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSquareButton(
                  context: context,
                  icon: Icons.fitness_center,
                  label: 'Nuova Preparazione',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NewPreparationScreen()),
                    );
                  },
                ),
                const SizedBox(width: 20), // Spazio tra i due bottoni
                _buildSquareButton(
                  context: context,
                  icon: Icons.list,
                  label: 'Elenco Preparazioni',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PreparationListScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        } else if (role == 'atleta') {
          return const AthletePreparationView();
        } else {
          return const Center(child: Text('Ruolo non autorizzato'));
        }
      },
    );
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
          backgroundColor: Colors.white, // Colore di sfondo bianco
          side: const BorderSide(color: Colors.black, width: 2), // Bordo nero
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Angoli arrotondati
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 40), // Icona nera
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
}

class NewPreparationScreen extends StatefulWidget {
  const NewPreparationScreen({Key? key}) : super(key: key);

  @override
  _NewPreparationScreenState createState() => _NewPreparationScreenState();
}

class _NewPreparationScreenState extends State<NewPreparationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _athleteType;
  String? _workoutType;
  String? _workoutDetails;
  String? _athleteName;
  String? _athleteSurname;
  DateTime? _dueDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova Preparazione')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Seleziona Atleta'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tutti gli atleti')),
                  DropdownMenuItem(value: 'specific', child: Text('Atleta specifico')),
                ],
                onChanged: (value) {
                  setState(() {
                    _athleteType = value;
                  });
                },
                validator: (value) => value == null ? 'Seleziona un opzione' : null,
              ),
              if (_athleteType == 'specific') ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nome Atleta'),
                  validator: (value) => value!.isEmpty ? 'Inserisci il nome' : null,
                  onSaved: (value) => _athleteName = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Cognome Atleta'),
                  validator: (value) => value!.isEmpty ? 'Inserisci il cognome' : null,
                  onSaved: (value) => _athleteSurname = value,
                ),
              ],
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo di Allenamento'),
                items: const [
                  DropdownMenuItem(value: 'velocità', child: Text('Allenamento di Velocità')),
                  DropdownMenuItem(value: 'resistenza', child: Text('Allenamento di Resistenza')),
                  DropdownMenuItem(value: 'forza', child: Text('Allenamento di Forza')),
                  DropdownMenuItem(value: 'flessibilità', child: Text('Allenamento di Flessibilità e Mobilità')),
                  DropdownMenuItem(value: 'scherma', child: Text('Allenamento Specifico per la Scherma')),
                  DropdownMenuItem(value: 'recupero', child: Text('Recupero e Prevenzione degli Infortuni')),
                ],
                onChanged: (value) {
                  setState(() {
                    _workoutType = value;
                  });
                },
                validator: (value) => value == null ? 'Seleziona un tipo di allenamento' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrizione dell\'Allenamento'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Inserisci la descrizione dell\'allenamento' : null,
                onSaved: (value) => _workoutDetails = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Data di Termine'),
                readOnly: true,
                controller: TextEditingController(
                  text: _dueDate != null ? DateFormat('dd/MM/yyyy').format(_dueDate!) : '',
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null && pickedDate != _dueDate) {
                    setState(() {
                      _dueDate = pickedDate;
                    });
                  }
                },
                validator: (value) => _dueDate == null ? 'Seleziona una data di termine' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPreparation,
                child: const Text('Invia'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPreparation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final userData = await authService.getUserData(user!.uid);

      await FirebaseFirestore.instance.collection('athletic_preparations').add({
        'coachName': userData['firstName'],
        'coachSurname': userData['lastName'],
        'facilityCode': userData['facilityCode'],
        'athleteType': _athleteType,
        'athleteName': _athleteName,
        'athleteSurname': _athleteSurname,
        'workoutType': _workoutType,
        'workoutDetails': _workoutDetails,
        'dueDate': _dueDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparazione Atletica Salvata')),
      );

      Navigator.pop(context);
    }
  }
}

class PreparationListScreen extends StatelessWidget {
  const PreparationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Elenco Preparazioni')),
      body: FutureBuilder<DocumentSnapshot>(
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

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('athletic_preparations')
                .where('coachName', isEqualTo: coachName)
                .where('coachSurname', isEqualTo: coachSurname)
                //.orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Nessuna preparazione atletica trovata'));
              }

              final now = DateTime.now();
              final validPreparations = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final dueDate = (data['dueDate'] as Timestamp).toDate();
                final isExpired = now.isAfter(dueDate.add(const Duration(days: 1)));

                if (isExpired) {
                  // Elimina la preparazione scaduta
                  doc.reference.delete();
                }

                return !isExpired;
              }).toList();

              if (validPreparations.isEmpty) {
                return const Center(child: Text('Nessuna preparazione atletica trovata'));
              }

              return ListView.builder(
                itemCount: validPreparations.length,
                itemBuilder: (context, index) {
                  final preparation = validPreparations[index];
                  final data = preparation.data() as Map<String, dynamic>;
                  final dueDate = (data['dueDate'] as Timestamp).toDate();

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data['workoutType']} - ${data['athleteType'] == 'all' ? 'Tutti gli atleti' : '${data['athleteName']} ${data['athleteSurname']}'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(data['workoutDetails']),
                          const SizedBox(height: 8),
                          Text(
                            'Data di termine: ${DateFormat('dd/MM/yyyy').format(dueDate)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AthletePreparationView extends StatelessWidget {
  const AthletePreparationView({Key? key}) : super(key: key);

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
        final facilityCode = userData['facilityCode'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('athletic_preparations')
              .where('facilityCode', isEqualTo: facilityCode)
              //.where('athleteType', whereIn: ['all', 'specific'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Nessuna preparazione atletica trovata'));
            }

            final now = DateTime.now();
            final validPreparations = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final dueDate = (data['dueDate'] as Timestamp).toDate();
              final isExpired = now.isAfter(dueDate.add(const Duration(days: 1)));

              if (isExpired) {
                // Elimina la preparazione scaduta
                doc.reference.delete();
              }

              return !isExpired && (data['athleteType'] == 'all' ||
                  (data['athleteType'] == 'specific' &&
                      data['athleteName'] == athleteName &&
                      data['athleteSurname'] == athleteSurname));
            }).toList();

            if (validPreparations.isEmpty) {
              return const Center(child: Text('Nessuna preparazione atletica trovata per te'));
            }

            return ListView.builder(
              itemCount: validPreparations.length,
              itemBuilder: (context, index) {
                final preparation = validPreparations[index];
                final data = preparation.data() as Map<String, dynamic>;
                final dueDate = (data['dueDate'] as Timestamp).toDate();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['workoutType'],
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(data['workoutDetails']),
                        const SizedBox(height: 8),
                        Text(
                          'Data di termine: ${DateFormat('dd/MM/yyyy').format(dueDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

//Assalti
class AssaltiTab extends StatefulWidget {
  const AssaltiTab({super.key});

  @override
  _AssaltiTabState createState() => _AssaltiTabState();
}

class _AssaltiTabState extends State<AssaltiTab> {
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
          return const CoachAssaltiView();
        } else if (role == 'atleta') {
          return const AthleteAssaltiView();
        } else if (role == 'staff') {
          return const StaffAssaltiView();
        } else {
          return const Center(child: Text('Ruolo non riconosciuto'));
        }
      },
    );
  }
}

class CoachAssaltiView extends StatelessWidget {
  const CoachAssaltiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSquareButton(
            context: context,
            icon: Icons.sports_martial_arts,
            label: 'Crea Combattimento',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateCombattimentoScreen()),
              );
            },
          ),
          const SizedBox(width: 20), // Spazio tra i due bottoni
          _buildSquareButton(
            context: context,
            icon: Icons.list_alt,
            label: 'Elenco Combattimenti',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CoachCombattimentiListScreen()),
              );
            },
          ),
        ],
      ),
    );
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
          backgroundColor: Colors.white, // Colore di sfondo bianco
          side: const BorderSide(color: Colors.black, width: 2), // Bordo nero
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Angoli arrotondati
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 40), // Icona nera
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
}


class CreateCombattimentoScreen extends StatelessWidget {
  const CreateCombattimentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crea Combattimento')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Libero'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateLiberoCombattimentoScreen()),
            ),
          ),
          ListTile(
            title: const Text('1 vs 1'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Create1vs1CombattimentoScreen()),
            ),
          ),
          ListTile(
            title: const Text('A squadre'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTeamCombattimentoScreen()),
            ),
          ),
          ListTile(
            title: const Text('A tema'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateThemedCombattimentoScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// combattimento a tema
class CreateThemedCombattimentoScreen extends StatefulWidget {
  const CreateThemedCombattimentoScreen({super.key});

  @override
  _CreateThemedCombattimentoScreenState createState() => _CreateThemedCombattimentoScreenState();
}

class _CreateThemedCombattimentoScreenState extends State<CreateThemedCombattimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _athletes = [];
  String _newAthleteName = '';
  String _newAthleteSurname = '';
  String _theme = '';

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

  void _addAthlete() {
    if (_newAthleteName.isNotEmpty && _newAthleteSurname.isNotEmpty) {
      setState(() {
        _athletes.add('$_newAthleteName $_newAthleteSurname');
        _newAthleteName = '';
        _newAthleteSurname = '';
      });
    }
  }

  Future<void> _submitCombattimento() async {
    if (_formKey.currentState!.validate() && _athletes.isNotEmpty && _theme.isNotEmpty) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final userData = await authService.getUserData(user!.uid);

      await FirebaseFirestore.instance.collection('combattimenti').add({
        'type': 'a tema',
        'date': Timestamp.fromDate(_selectedDate),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'athletes': _athletes,
        'facilityCode': userData['facilityCode'],
        'coachName': userData['firstName'],
        'coachSurname': userData['lastName'],
        'theme': _theme,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Combattimento a tema creato con successo')),
      );

      Navigator.pop(context);
    } else if (_athletes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aggiungi almeno un atleta')),
      );
    } else if (_theme.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci il tema del combattimento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crea Combattimento a Tema')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
            const SizedBox(height: 20),
            const Text('Atleti:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._athletes.map((athlete) => ListTile(title: Text(athlete))).toList(),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nome Atleta'),
              onChanged: (value) => _newAthleteName = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Cognome Atleta'),
              onChanged: (value) => _newAthleteSurname = value,
            ),
            ElevatedButton(
              onPressed: _addAthlete,
              child: const Text('Aggiungi Atleta'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Tema del Combattimento'),
              onChanged: (value) => _theme = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitCombattimento,
              child: const Text('Crea Combattimento'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemedCombattimentoDetailScreen extends StatelessWidget {
  final String combattimentoId;

  const ThemedCombattimentoDetailScreen({Key? key, required this.combattimentoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettagli Combattimento a Tema')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('combattimenti').doc(combattimentoId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Errore nel caricamento dei dettagli'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final athletes = data['athletes'] as List<dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Allenatore: ${data['coachName']} ${data['coachSurname']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Text(
                'Data: ${formatDate((data['date'] as Timestamp).toDate())}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Ora: ${data['time']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'Tema: ${data['theme']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              ...athletes.map((athlete) => ListTile(title: Text(athlete as String))),
            ],
          );
        },
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}


// combattimento a squadre
class CreateTeamCombattimentoScreen extends StatefulWidget {
  const CreateTeamCombattimentoScreen({super.key});

  @override
  _CreateTeamCombattimentoScreenState createState() => _CreateTeamCombattimentoScreenState();
}

class _CreateTeamCombattimentoScreenState extends State<CreateTeamCombattimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<Map<String, List<String>>> _teams = [];
  String _newAthleteName = '';
  String _newAthleteSurname = '';
  int _currentTeamIndex = 0;

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

  void _addTeam() {
    setState(() {
      _teams.add({'teamName': [], 'teamMembers': []});
      _currentTeamIndex = _teams.length - 1;
    });
  }

  void _addAthleteToCurrentTeam() {
    if (_newAthleteName.isNotEmpty && _newAthleteSurname.isNotEmpty) {
      setState(() {
        _teams[_currentTeamIndex]['teamMembers']!.add('$_newAthleteName $_newAthleteSurname');
        _newAthleteName = '';
        _newAthleteSurname = '';
      });
    }
  }

  Future<void> _submitCombattimento() async {
    if (_formKey.currentState!.validate() && _teams.isNotEmpty) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final userData = await authService.getUserData(user!.uid);

      // Flatten all team members into a single list
      List<String> athletes = _teams
          .expand((team) => team['teamMembers']!)
          .toList();

      await FirebaseFirestore.instance.collection('combattimenti').add({
        'type': 'squadre',
        'date': Timestamp.fromDate(_selectedDate),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'teams': _teams.map((team) => {
          'teamName': team['teamName'],
          'teamMembers': team['teamMembers']
        }).toList(),
        'athletes': athletes,
        'facilityCode': userData['facilityCode'],
        'coachName': userData['firstName'],
        'coachSurname': userData['lastName'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Combattimento creato con successo')),
      );

      Navigator.pop(context);
    } else if (_teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aggiungi almeno una squadra')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crea Combattimento a Squadre')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTeam,
              child: const Text('Aggiungi Squadra'),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < _teams.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Squadra ${i + 1}'),
                  ..._teams[i]['teamMembers']!.map((athlete) => ListTile(title: Text(athlete))).toList(),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nome Atleta'),
                    onChanged: (value) => _newAthleteName = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Cognome Atleta'),
                    onChanged: (value) => _newAthleteSurname = value,
                  ),
                  ElevatedButton(
                    onPressed: _addAthleteToCurrentTeam,
                    child: const Text('Aggiungi Atleta alla Squadra'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitCombattimento,
              child: const Text('Crea Combattimento'),
            ),
          ],
        ),
      ),
    );
  }
}

// 1 vs 1
class Create1vs1CombattimentoScreen extends StatefulWidget {
  const Create1vs1CombattimentoScreen({super.key});

  @override
  _Create1vs1CombattimentoScreenState createState() => _Create1vs1CombattimentoScreenState();
}

class _Create1vs1CombattimentoScreenState extends State<Create1vs1CombattimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _firstAthleteName = '';
  String _firstAthleteSurname = '';
  String _secondAthleteName = '';
  String _secondAthleteSurname = '';

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

  Future<void> _submitCombattimento() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final userData = await authService.getUserData(user!.uid);

      await FirebaseFirestore.instance.collection('combattimenti').add({
        'type': '1vs1',
        'date': Timestamp.fromDate(_selectedDate),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'athletes': [
          '$_firstAthleteName $_firstAthleteSurname',
          '$_secondAthleteName $_secondAthleteSurname',
        ],
        'facilityCode': userData['facilityCode'],
        'coachName': userData['firstName'],
        'coachSurname': userData['lastName'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Combattimento creato con successo')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crea Combattimento 1 vs 1')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
            const SizedBox(height: 20),
            const Text('Primo Atleta:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nome'),
              onChanged: (value) => _firstAthleteName = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Cognome'),
              onChanged: (value) => _firstAthleteSurname = value,
            ),
            const SizedBox(height: 20),
            const Text('Secondo Atleta:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nome'),
              onChanged: (value) => _secondAthleteName = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Cognome'),
              onChanged: (value) => _secondAthleteSurname = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitCombattimento,
              child: const Text('Crea Combattimento'),
            ),
          ],
        ),
      ),
    );
  }
}

// combattimento libero
class CreateLiberoCombattimentoScreen extends StatefulWidget {
  const CreateLiberoCombattimentoScreen({super.key});

  @override
  _CreateLiberoCombattimentoScreenState createState() => _CreateLiberoCombattimentoScreenState();
}

class _CreateLiberoCombattimentoScreenState extends State<CreateLiberoCombattimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _athletes = [];
  String _newAthleteName = '';
  String _newAthleteSurname = '';

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

  void _addAthlete() {
    if (_newAthleteName.isNotEmpty && _newAthleteSurname.isNotEmpty) {
      setState(() {
        _athletes.add('$_newAthleteName $_newAthleteSurname');
        _newAthleteName = '';
        _newAthleteSurname = '';
      });
    }
  }

  Future<void> _submitCombattimento() async {
    if (_formKey.currentState!.validate() && _athletes.isNotEmpty) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final userData = await authService.getUserData(user!.uid);

      await FirebaseFirestore.instance.collection('combattimenti').add({
        'type': 'libero',
        'date': Timestamp.fromDate(_selectedDate),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'athletes': _athletes,
        'facilityCode': userData['facilityCode'],
        'coachName': userData['firstName'],
        'coachSurname': userData['lastName'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Combattimento creato con successo')),
      );

      Navigator.pop(context);
    } else if (_athletes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aggiungi almeno un atleta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crea Combattimento Libero')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
            const SizedBox(height: 20),
            const Text('Atleti:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._athletes.map((athlete) => ListTile(title: Text(athlete))).toList(),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nome Atleta'),
              onChanged: (value) => _newAthleteName = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Cognome Atleta'),
              onChanged: (value) => _newAthleteSurname = value,
            ),
            ElevatedButton(
              onPressed: _addAthlete,
              child: const Text('Aggiungi Atleta'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitCombattimento,
              child: const Text('Crea Combattimento'),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// Helper widget to display a list of combattimenti
class CombattimentiList extends StatelessWidget {
  final Stream<QuerySnapshot> stream;

  const CombattimentiList({Key? key, required this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nessun combattimento programmato'));
        }

        final now = DateTime.now();
        final validCombattimenti = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final combattimentoDate = (data['date'] as Timestamp).toDate();
          final isExpired = now.isAfter(combattimentoDate.add(const Duration(days: 1)));

          if (isExpired) {
            // Elimina il combattimento scaduto
            doc.reference.delete();
          }

          return !isExpired;
        }).toList();

        if (validCombattimenti.isEmpty) {
          return const Center(child: Text('Nessun combattimento programmato'));
        }

        // Raggruppa i combattimenti per data
        final groupedCombattimenti = groupCombattimentiByDate(validCombattimenti);

        return ListView.builder(
          itemCount: groupedCombattimenti.length,
          itemBuilder: (context, index) {
            final date = groupedCombattimenti.keys.elementAt(index);
            final combattimenti = groupedCombattimenti[date]!;

            return ExpansionTile(
              title: Text(formatDate(date)),
              children: combattimenti.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final athletes = data['athletes'] as List<dynamic>? ?? [];
                final combattimentoId = doc.id;

                Widget trailingIcon;
                String? subtitle;
                if (data['type'] == 'a tema') {
                  trailingIcon = IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThemedCombattimentoDetailScreen(
                            combattimentoId: combattimentoId,
                          ),
                        ),
                      );
                    },
                  );
                  subtitle = 'Tema: ${data['theme']}\n'
                             'Allenatore: ${data['coachName']} ${data['coachSurname']}\n'
                             'Atleti: ${athletes.join(', ')}';
                } else if (data['type'] == 'squadre') {
                  trailingIcon = IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamCombattimentoDetailScreen(
                            combattimentoId: combattimentoId,
                          ),
                        ),
                      );
                    },
                  );
                  subtitle = 'Allenatore: ${data['coachName']} ${data['coachSurname']}\n'
                             'Atleti: ${athletes.join(', ')}';
                } else {
                  trailingIcon = const SizedBox.shrink();
                  subtitle = 'Allenatore: ${data['coachName']} ${data['coachSurname']}\n'
                             'Atleti: ${athletes.join(', ')}';
                }

                return ListTile(
                  title: Text('${data['type'].toString().capitalize()} - ${data['time']}'),
                  subtitle: Text(subtitle),
                  trailing: trailingIcon,
                );
              }).toList(),
            );
          },
        );
      }
    );
  }

  Map<DateTime, List<QueryDocumentSnapshot>> groupCombattimentiByDate(List<QueryDocumentSnapshot> docs) {
    final grouped = <DateTime, List<QueryDocumentSnapshot>>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      final dateWithoutTime = DateTime(date.year, date.month, date.day);
      if (!grouped.containsKey(dateWithoutTime)) {
        grouped[dateWithoutTime] = [];
      }
      grouped[dateWithoutTime]!.add(doc);
    }
    return Map.fromEntries(grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class TeamCombattimentoDetailScreen extends StatelessWidget {
  final String combattimentoId;

  const TeamCombattimentoDetailScreen({Key? key, required this.combattimentoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettagli Combattimento a Squadre')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('combattimenti').doc(combattimentoId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Errore nel caricamento dei dettagli'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final teams = data['teams'] as List<dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Allenatore: ${data['coachName']} ${data['coachSurname']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Text(
                'Data: ${formatDate((data['date'] as Timestamp).toDate())}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Ora: ${data['time']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              ...teams.map((team) {
                final teamName = team['teamName'] as List<dynamic>;
                final teamMembers = team['teamMembers'] as List<dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Squadra ${teamName.join(', ')}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ...teamMembers.map((member) => ListTile(title: Text(member as String))),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Update the CoachCombattimentiListScreen to use the CombattimentiList widget
class CoachCombattimentiListScreen extends StatelessWidget {
  const CoachCombattimentiListScreen({super.key});

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
          appBar: AppBar(title: const Text('Elenco Combattimenti')),
          body: CombattimentiList(
            stream: FirebaseFirestore.instance
                .collection('combattimenti')
                .where('coachName', isEqualTo: coachName)
                .where('coachSurname', isEqualTo: coachSurname)
                .snapshots(),
          ),
        );
      },
    );
  }
}

// Update the AthleteAssaltiView to use the CombattimentiList widget
class AthleteAssaltiView extends StatelessWidget {
  const AthleteAssaltiView({super.key});

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
        final athleteName = '${userData['firstName']} ${userData['lastName']}';

        return CombattimentiList(
          stream: FirebaseFirestore.instance
              .collection('combattimenti')
              .where('athletes', arrayContains: athleteName)
              .snapshots(),
        );
      },
    );
  }
}

// Update the StaffAssaltiView to use the CombattimentiList widget
class StaffAssaltiView extends StatelessWidget {
  const StaffAssaltiView({super.key});

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

        return CombattimentiList(
          stream: FirebaseFirestore.instance
              .collection('combattimenti')
              .where('facilityCode', isEqualTo: facilityCode)
              .snapshots(),
        );
      },
    );
  }
}

//Lezione privata
class PrivateLessonTab extends StatefulWidget {
  const PrivateLessonTab({Key? key}) : super(key: key);

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
      : Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSquareButton(
                context: context,
                icon: Icons.add,
                label: 'Aggiungi Lezione',
                onPressed: () {
                  setState(() {
                    _showCreateLesson = true;
                  });
                },
              ),
              const SizedBox(width: 20), // Spazio tra i due bottoni
              _buildSquareButton(
                context: context,
                icon: Icons.list,
                label: 'Le Mie Lezioni',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CoachLessonsScreen()),
                  );
                },
              ),
            ],
          ),
        );
        } else if (role == 'atleta') {
          return const AthleteLesson();
        } else if (role == 'staff') {
          return const StaffLessonView();
        } else {
          return const Center(child: Text('Ruolo non riconosciuto'));
        }
      },
    );
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
        backgroundColor: Colors.white, // Colore di sfondo bianco
        side: const BorderSide(color: Colors.black, width: 2), // Bordo nero
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Angoli arrotondati
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 40), // Icona nera
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


class CreateLessonScreen extends StatefulWidget {
  final VoidCallback onCancel;

  const CreateLessonScreen({super.key, required this.onCancel});

  @override
  _CreateLessonScreenState createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  List<DateTime> _selectedDates = [];
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _athleteName = '';
  String _athleteSurname = '';

  Future<void> _selectDates(BuildContext context) async {
    final List<DateTime>? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog<DateTime>(
          items: List<DateTime>.generate(
            365,
            (index) => DateTime.now().add(Duration(days: index)),
          ).map((date) => MultiSelectItem<DateTime>(date, DateFormat('dd/MM/yyyy').format(date))).toList(),
          initialValue: _selectedDates,
          onConfirm: (values) {
            setState(() {
              _selectedDates = values;
            });
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDates = picked;
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

      for (var date in _selectedDates) {
        await FirebaseFirestore.instance.collection('private_lessons').add({
          'date': Timestamp.fromDate(date),
          'time': '${_selectedTime.hour}:${_selectedTime.minute}',
          'athleteName': _athleteName,
          'athleteSurname': _athleteSurname,
          'facilityCode': userData['facilityCode'],
          'coachName': userData['firstName'],
          'coachSurname': userData['lastName'],
        });
      }

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
              title: const Text('Date'),
              subtitle: Text(
                _selectedDates.isEmpty
                    ? 'Nessuna data selezionata'
                    : _selectedDates.map((date) => DateFormat('dd/MM/yyyy').format(date)).join(', '),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDates(context),
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
  const CoachLessonsScreen({super.key});

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

              final now = DateTime.now();
              final validLessons = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final lessonDate = (data['date'] as Timestamp).toDate();
                final isExpired = now.isAfter(lessonDate.add(const Duration(days: 1)));

                if (isExpired) {
                  // Elimina la lezione scaduta
                  doc.reference.delete();
                }

                return !isExpired;
              }).toList();

              if (validLessons.isEmpty) {
                return const Center(child: Text('Nessuna lezione privata programmata'));
              }

              final groupedLessons = _groupLessonsByDate(validLessons);

              return ListView.builder(
                itemCount: groupedLessons.length,
                itemBuilder: (context, index) {
                  final date = groupedLessons.keys.elementAt(index);
                  final lessons = groupedLessons[date]!;

                  return ExpansionTile(
                    title: Text(_formatDate(date)),
                    children: lessons.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text('Lezione privata - ${data['time']}'),
                        subtitle: Text('Atleta: ${data['athleteName']} ${data['athleteSurname']}'),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Map<DateTime, List<QueryDocumentSnapshot>> _groupLessonsByDate(List<QueryDocumentSnapshot> docs) {
    final grouped = <DateTime, List<QueryDocumentSnapshot>>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      final dateWithoutTime = DateTime(date.year, date.month, date.day);
      if (!grouped.containsKey(dateWithoutTime)) {
        grouped[dateWithoutTime] = [];
      }
      grouped[dateWithoutTime]!.add(doc);
    }
    return Map.fromEntries(grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AthleteLesson extends StatelessWidget {
  const AthleteLesson({super.key});

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

            final now = DateTime.now();
            final validLessons = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final lessonDate = (data['date'] as Timestamp).toDate();
              final isExpired = now.isAfter(lessonDate.add(const Duration(days: 1)));

              if (isExpired) {
                // Elimina la lezione scaduta
                doc.reference.delete();
              }

              return !isExpired;
            }).toList();

            if (validLessons.isEmpty) {
              return const Center(child: Text('Nessuna lezione privata programmata'));
            }

            final groupedLessons = _groupLessonsByDate(validLessons);

            return ListView.builder(
              itemCount: groupedLessons.length,
              itemBuilder: (context, index) {
                final date = groupedLessons.keys.elementAt(index);
                final lessons = groupedLessons[date]!;

                return ExpansionTile(
                  title: Text(_formatDate(date)),
                  children: lessons.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Lezione privata - ${data['time']}'),
                      subtitle: Text('Coach: ${data['coachName']} ${data['coachSurname']}'),
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

  Map<DateTime, List<QueryDocumentSnapshot>> _groupLessonsByDate(List<QueryDocumentSnapshot> docs) {
    final grouped = <DateTime, List<QueryDocumentSnapshot>>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      final dateWithoutTime = DateTime(date.year, date.month, date.day);
      if (!grouped.containsKey(dateWithoutTime)) {
        grouped[dateWithoutTime] = [];
      }
      grouped[dateWithoutTime]!.add(doc);
    }
    return Map.fromEntries(grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class StaffLessonView extends StatelessWidget {
  const StaffLessonView({super.key});

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

            final groupedLessons = _groupLessonsByDate(snapshot.data!.docs);

            return ListView.builder(
              itemCount: groupedLessons.length,
              itemBuilder: (context, index) {
                final date = groupedLessons.keys.elementAt(index);
                final lessons = groupedLessons[date]!;

                return ExpansionTile(
                  title: Text(_formatDate(date)),
                  children: lessons.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Lezione privata - ${data['time']}'),
                      subtitle: Text(
                        'Atleta: ${data['athleteName']} ${data['athleteSurname']}\n'
                        'Coach: ${data['coachName']} ${data['coachSurname']}'
                      ),
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

  Map<DateTime, List<QueryDocumentSnapshot>> _groupLessonsByDate(List<QueryDocumentSnapshot> docs) {
    final grouped = <DateTime, List<QueryDocumentSnapshot>>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      final dateWithoutTime = DateTime(date.year, date.month, date.day);
      if (!grouped.containsKey(dateWithoutTime)) {
        grouped[dateWithoutTime] = [];
      }
      grouped[dateWithoutTime]!.add(doc);
    }
    return Map.fromEntries(grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
