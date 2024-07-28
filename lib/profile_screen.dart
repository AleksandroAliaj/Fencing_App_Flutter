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
  String? _userId;
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
        _userId = user.uid;
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
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              ModalRoute.withName('/'),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_firstName != null && _lastName != null)
              Text('Name: $_firstName $_lastName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (_email != null) Text('Email: $_email'),
            if (_role != null) Text('Role: $_role'),
            if (_facilityCode != null) Text('Facility Code: $_facilityCode'),
            const SizedBox(height: 20),
            const Text(
              'Comunica il tuo ID agli allenatori e ai tuoi amici',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_userId != null)
              Row(
                children: [
                  Expanded(child: Text('ID: $_userId')),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(_userId!),
                    tooltip: 'Copia ID',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}