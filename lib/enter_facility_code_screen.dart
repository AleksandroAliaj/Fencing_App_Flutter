import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'profile_screen.dart';

class EnterFacilityCodeScreen extends StatefulWidget {
  final String email;
  final String password;
  final String role;
  final String firstName;
  final String lastName;

  const EnterFacilityCodeScreen({
    super.key,
    required this.email,
    required this.password,
    required this.role,
    required this.firstName,
    required this.lastName,
  });

  @override
  _EnterFacilityCodeScreenState createState() => _EnterFacilityCodeScreenState();
}

class _EnterFacilityCodeScreenState extends State<EnterFacilityCodeScreen> {
  final TextEditingController _facilityCodeController = TextEditingController();

  @override
  void dispose() {
    _facilityCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Facility Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _facilityCodeController,
              decoration: const InputDecoration(labelText: 'Facility Code'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Register'),
              onPressed: () async {
                final String facilityCode = _facilityCodeController.text.trim();
                try {
                  bool codeExists = await Provider.of<AuthService>(context, listen: false)
                      .checkFacilityCodeExists(facilityCode);
                  if (codeExists) {
                    await Provider.of<AuthService>(context, listen: false)
                        .registerWithEmailAndPassword(
                          widget.email, 
                          widget.password, 
                          widget.role, 
                          widget.firstName, 
                          widget.lastName,
                          facilityCode: facilityCode
                        );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid facility code')),
                    );
                  }
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration failed: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}