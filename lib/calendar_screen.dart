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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToAddEvent(context),
              child: const Text('Aggiungi Evento'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToEventList(context),
              child: const Text('Elenco Eventi'),
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

  void _navigateToAddEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEventScreen()),
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
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
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

  Future<void> _submitEvent() async {
    if (_dateController.text.isNotEmpty && _timeController.text.isNotEmpty && _locationController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _facilityCode != null) {
      await FirebaseFirestore.instance.collection('events').add({
        'date': _dateController.text,
        'time': _timeController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'facilityCode': _facilityCode,
      });
      Navigator.pop(context);
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
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Data',
              ),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Ora',
              ),
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

        final userData = snapshot.data!;
        final facilityCode = userData['facilityCode'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Elenco Eventi'),
          ),
          body: StreamBuilder<QuerySnapshot>(
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

              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  return Dismissible(
                    key: Key(doc.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Conferma eliminazione"),
                            content: const Text("Sei sicuro di voler eliminare questo evento?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Annulla"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Elimina"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      FirebaseFirestore.instance.collection('events').doc(doc.id).delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Evento eliminato')),
                      );
                    },
                    child: ListTile(
                      title: Text(doc['description']),
                      subtitle: Text('${doc['date']} - ${doc['time']} @ ${doc['location']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Conferma eliminazione"),
                                content: const Text("Sei sicuro di voler eliminare questo evento?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Annulla"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("Elimina"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            await FirebaseFirestore.instance.collection('events').doc(doc.id).delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Evento eliminato')),
                            );
                          }
                        },
                      ),
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

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return ListTile(
                  title: Text(doc['description']),
                  subtitle: Text('${doc['date']} - ${doc['time']} @ ${doc['location']}'),
                );
              }).toList(),
            );
          },
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

  Future<void> _submitDeadline() async {
    if (_firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _deadlineController.text.isNotEmpty && _facilityCode != null) {
      await FirebaseFirestore.instance.collection('deadlines').add({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'text': _deadlineController.text,
        'status': 'Pending',
        'facilityCode': _facilityCode,
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
      },
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
        final facilityCode = userData['facilityCode'];

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

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return ListTile(
                  title: Text(doc['text']),
                  subtitle: Text('${doc['firstName']} ${doc['lastName']}'),
                  trailing: doc['status'] == 'Confirmed'
                      ? const Text('Confirmed', style: TextStyle(color: Colors.green))
                      : null,
                );
              }).toList(),
            );
          },
        );
      },
    );
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
      final athleteName = userData['firstName'];
      final athleteSurname = userData['lastName'];
      final fullName = '$athleteName $athleteSurname';

      // Load private lessons
      final lessonsSnapshot = await FirebaseFirestore.instance
          .collection('private_lessons')
          .where('athleteName', isEqualTo: athleteName)
          .where('athleteSurname', isEqualTo: athleteSurname)
          .get();

      // Load combattimenti
      final combattimentiSnapshot = await FirebaseFirestore.instance
          .collection('combattimenti')
          .where('athletes', arrayContains: fullName)
          .get();

      setState(() {
        // Process private lessons
        for (var doc in lessonsSnapshot.docs) {
          final data = doc.data();
          final date = (data['date'] as Timestamp).toDate();
          final eventDate = DateTime(date.year, date.month, date.day);
          final event = Event(
            title: 'Lezione privata',
            time: data['time'],
            coachName: '${data['coachName']} ${data['coachSurname']}',
            athleteName: '${data['athleteName']} ${data['athleteSurname']}',
            date: date,
            type: 'lesson',
          );

          if (_events[eventDate] == null) _events[eventDate] = [];
          _events[eventDate]!.add(event);
        }

        // Process combattimenti
        for (var doc in combattimentiSnapshot.docs) {
          final data = doc.data();
          final date = (data['date'] as Timestamp).toDate();
          final eventDate = DateTime(date.year, date.month, date.day);
          final event = Event(
            title: 'Combattimento ${data['type']}',
            time: data['time'],
            coachName: '${data['coachName']} ${data['coachSurname']}',
            athleteName: (data['athletes'] as List<dynamic>).join(', '),
            date: date,
            type: 'combattimento',
          );

          if (_events[eventDate] == null) _events[eventDate] = [];
          _events[eventDate]!.add(event);
        }
      });

      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    }
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
          calendarStyle: CalendarStyle(
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
                      subtitle: Text('Ora: ${events[index].time}\nAllenatore: ${events[index].coachName}\nAtleta: ${events[index].athleteName}'),
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
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Data: ${event.date.day}/${event.date.month}/${event.date.year}'),
            Text('Ora: ${event.time}'),
            Text('Allenatore: ${event.coachName}'),
            Text('Atleta: ${event.athleteName}'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Chiudi'),
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
