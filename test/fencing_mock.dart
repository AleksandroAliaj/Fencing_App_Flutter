import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class MockFencingServices {
  final FakeFirebaseFirestore fakeFirestore;

  MockFencingServices() : fakeFirestore = FakeFirebaseFirestore();

  Future<void> prepare() async {
    await fakeFirestore.collection('athletic_preparations').doc('example').set({
      'athleteName': 'Elisa',
      'athleteSurname': 'Galli',
      'athleteType': 'specific',
      'coachName': 'Davide',
      'coachSurname': 'Ferrari',
      'createdAt': Timestamp.fromDate(DateTime.parse('2024-08-25T14:09:52Z')),
      'dueDate': Timestamp.fromDate(DateTime.parse('2024-09-15T00:00:00Z')),
      'facilityCode': 'W0V3E2',
      'workoutDetails': '(20-30 minuti) Circuito di Alta Intensità (HIIT): 30 secondi di lavoro intenso seguiti da 30 secondi di recupero. Esempi: sprint su tapis roulant, burpees, salti in alto. Ripetere il circuito 4-6 volte. Interval Training con Bicicletta o Rower: Alternare 1-2 minuti di pedalata o remata ad alta intensità con 2-3 minuti di recupero. Ripetere per 20-30 minuti.',
      'workoutType': 'resistenza',
    });

    await fakeFirestore.collection('chats').doc('example').set({
      'lastMessage': 'ciao',
      'lastMessageTimestamp': Timestamp.fromDate(DateTime.parse('2024-08-22T12:33:03Z')),
      'participantEmails': {
        'FrKEL33zmAcaGM6kWS6YTcGplBf1': 'staff@gmail.com',
        'bMjbAmT7csfdH8pyh65AytkBYKx1': 'allenatore@gmail.com',
      },
      'participants': [
        'FrKEL33zmAcaGM6kWS6YTcGplBf1',
        'bMjbAmT7csfdH8pyh65AytkBYKx1',
      ],
    });

    await fakeFirestore.collection('combattimenti').doc('example').set({
      'athletes': ['Elisa Galli', 'Martina Esposito'],
      'coachName': 'Davide',
      'coachSurname': 'Ferrari',
      'date': Timestamp.fromDate(DateTime.parse('2024-09-08T00:00:00Z')),
      'facilityCode': 'W0V3E2',
      'time': '18:15',
      'type': 'simulazione gara',
    });

    await fakeFirestore.collection('deadlines').doc('example').set({
      'deadlineDate': Timestamp.fromDate(DateTime.parse('2024-09-30T00:00:00Z')),
      'facilityCode': 'W0V3E2',
      'firstName': 'Elisa',
      'lastName': 'Galli',
      'status': 'Pending',
      'text': 'Il pagamento delle quote associative va effettuato entro il 30 settembre 2024.',
    });

    await fakeFirestore.collection('events').doc('example').set({
      'date': Timestamp.fromDate(DateTime.parse('2024-09-15T16:30:00Z')),
      'description': 'Seminario di Tecniche di Scherma Avanzate',
      'facilityCode': 'W0V3E2',
      'location': 'Sala Tecnica',
    });

    await fakeFirestore.collection('intervention_requests').doc('example').set({
      'description': 'bucata',
      'facilityCode': 'ZB1LZU',
      'firstName': 'NomeAllenatore',
      'lastName': 'CognomeAllenatore',
      'repair': 'Maschera',
      'status': 'In riparazione',
      'timestamp': Timestamp.fromDate(DateTime.parse('2024-08-08T11:32:46Z')),
      'userId': 'bMjbAmT7csfdH8pyh65AytkBYKx1',
    });

    await fakeFirestore.collection('messages').doc('example').set({
      'chatType': 'athletes_coaches',
      'facilityCode': 'ZB1LZU',
      'sender': 'aleksandro.aliaj@gmail.com',
      'senderRole': 'Allenatore',
      'text': '6',
      'timestamp': Timestamp.fromDate(DateTime.parse('2024-08-08T13:06:18Z')),
    });

    await fakeFirestore.collection('news').doc('example').set({
      'description': 'Abbiamo recentemente rinnovato e aggiornato le nostre attrezzature da scherma per garantire la massima qualità e sicurezza.',
      'facilityCode': 'W0V3E2',
      'timestamp': Timestamp.fromDate(DateTime.parse('2024-08-25T14:13:54Z')),
      'title': 'Rinnovo e Aggiornamenti delle Attrezzature',
    });

    await fakeFirestore.collection('private_lessons').doc('example').set({
      'athleteName': 'Elisa',
      'athleteSurname': 'Galli',
      'coachName': 'Davide',
      'coachSurname': 'Ferrari',
      'date': Timestamp.fromDate(DateTime.parse('2024-09-16T13:54:28Z')),
      'facilityCode': 'W0V3E2',
      'time': '15:20',
    });

    await fakeFirestore.collection('products').doc('example').set({
      'category': 'Abbigliamento e Equipaggiamento di Base',
      'description': 'Giacca da scherma con protezioni integrate su torace, spalle e braccia. Realizzata in materiale resistente agli urti e confortevole per allenamenti prolungati. Certificata FIE.',
      'facilityCode': 'W0V3E2',
      'price': 200,
      'timestamp': Timestamp.fromDate(DateTime.parse('2024-08-25T13:16:20Z')),
      'title': 'Giacca da Scherma con Protezione',
    });

    await fakeFirestore.collection('users').doc('example').set({
      'email': 'martina.esposito@gmail.com',
      'facilityCode': 'W0V3E2',
      'firstName': 'Martina',
      'lastName': 'Esposito',
      'role': 'Atleta',
    });
  }
}