import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'auth_service.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Center(child: Text('Scadenziario')), // Placeholder
            AgendaTab(),
          ],
        ),
      ),
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

      final querySnapshot = await FirebaseFirestore.instance
          .collection('private_lessons')
          .where('athleteName', isEqualTo: athleteName)
          .where('athleteSurname', isEqualTo: athleteSurname)
          .get();

      setState(() {
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          final date = (data['date'] as Timestamp).toDate();
          final eventDate = DateTime(date.year, date.month, date.day);
          final event = Event(
            title: 'Lezione privata',
            time: data['time'],
            coachName: '${data['coachName']} ${data['coachSurname']}',
            athleteName: '${data['athleteName']} ${data['athleteSurname']}',
            date: date,
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

    if (_selectedEvents.value.isNotEmpty) {
      _showEventDetails(context, _selectedEvents.value[0]);
    }
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

  const Event({
    required this.title,
    required this.time,
    required this.coachName,
    required this.athleteName,
    required this.date,
  });
}