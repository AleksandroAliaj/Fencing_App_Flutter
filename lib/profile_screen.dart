import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _email;
  String? _role;
  String? _facilityCode;
  String? _firstName;
  String? _lastName;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user != null) {
      final DocumentSnapshot userData = await Provider.of<AuthService>(context, listen: false).getUserData(user.uid);
      setState(() {
        _email = userData['email'];
        _role = userData['role'];
        _facilityCode = userData['facilityCode'];
        _firstName = userData['firstName'];
        _lastName = userData['lastName'];
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID copiato negli appunti')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0, // Rimuove l'ombra sotto l'AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              ModalRoute.withName('/'),
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (_firstName != null && _lastName != null)
                Text(
                  '$_firstName $_lastName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              if (_email != null)
                Text(
                  'Email: $_email',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 10),
              if (_role != null)
                Text(
                  '$_role',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 10),
              if (_facilityCode != null)
                GestureDetector(
                  onTap: () => _copyToClipboard(_facilityCode!),
                  child: Text(
                    'Codice struttura: $_facilityCode',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black, // Colore blu per suggerire che è cliccabile
                      //decoration: TextDecoration.underline, // Sottolinea il testo
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),
              // ElevatedButton(
              //   onPressed: () {
              //     // Aggiungi qui eventuali azioni per modificare il profilo
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.black,
              //     padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              //   ),
              //   child: const Text(
              //     'Modifica Profilo',
              //     style: TextStyle(color: Colors.white),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
