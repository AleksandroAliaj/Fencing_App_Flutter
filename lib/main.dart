// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'armeria_screen.dart';
import 'auth_service.dart';
import 'chat_selection_screen.dart';
import 'news_list_screen.dart';
import 'ranking_screen.dart';
import 'sign_in_screen.dart';
import 'profile_screen.dart';
import 'training_screen.dart';
import 'calendar_screen.dart';
import 'user_list_screen.dart';
import 'score_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAE5cj4wl19m782QOlz_dm6-zmLXM4PT9M",
      authDomain: "scherma-f2d5e.firebaseapp.com",
      projectId: "scherma-f2d5e",
      storageBucket: "scherma-f2d5e.appspot.com",
      messagingSenderId: "99064000925",
      appId: "1:99064000925:web:ea278c34849ce42ca37f74",
      measurementId: "G-Z4YW4DEWJW",
    ),
  );
  }

  runApp( const FencingApp());
}

class FencingApp extends StatelessWidget {
  const FencingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
  title: 'Fencing',
  theme: ThemeData(
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      elevation: 0, // Rimuove l'ombra sotto l'AppBar
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
  ),
  home: const AuthWrapper(),
),

    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Provider.of<AuthService>(context).user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const HomeScreen(); // Utente autenticato
        } else {
          return const SignInScreen(); // Utente non autenticato
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;

  static const List<Widget> _widgetOptions = <Widget>[
    ArmeriaScreen(),
    ChatSelectionScreen(),
    TrainingScreen(),
    RankingScreen(),
    CalendarScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logOut() async {
    try {
      await Provider.of<AuthService>(context, listen: false).signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  leading: Builder(
    builder: (BuildContext context) {
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      );
    },
  ),
),

      drawer: Drawer(
        
      child: ListView(
        
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
          
      ListTile(
        leading: const Icon(Icons.person, color: Colors.black),
        title: const Text('Profilo', style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Elenco utenti'),
              onTap: () {
              Navigator.pop(context); 
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserListScreen()),
    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.numbers),
              title: const Text('Segna punteggio'),
              onTap: () {Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScoreScreen()),
              );
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('News'),
              onTap: () {
              Navigator.pop(context); 
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsListScreen()),
              );
              },
            ),
            const Divider(color: Colors.black), // Separatore
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.black),
        title: const Text('Log Out', style: TextStyle(color: Colors.black)),
        onTap: () async {
          await _logOut();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        },
      ),
    ],
  ),
),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
  items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.build),
      label: 'Armeria',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      label: 'Chat',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.fitness_center),
      label: 'Allenamento',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.star),
      label: 'Ranking',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Calendario',
    ),
  ],
  currentIndex: _selectedIndex,
  selectedItemColor: Colors.black, // Colore icona selezionata
  unselectedItemColor: Colors.grey, // Colore icona non selezionata
  onTap: _onItemTapped,
  
),

    );
  }
}