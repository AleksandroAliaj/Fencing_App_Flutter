import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'facility_code_screen.dart';
import 'enter_facility_code_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _facilityCodeController = TextEditingController();
  String _role = 'Staff';
  bool _generateNewCode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _facilityCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            DropdownButton<String>(
              value: _role,
              onChanged: (String? newValue) {
                setState(() {
                  _role = newValue!;
                });
              },
              items: <String>['Staff', 'Allenatore', 'Atleta']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (_role == 'Staff') ...[
              Row(
                children: [
                  Checkbox(
                    value: _generateNewCode,
                    onChanged: (bool? value) {
                      setState(() {
                        _generateNewCode = value!;
                      });
                    },
                  ),
                  const Text('Generate new facility code'),
                ],
              ),
              if (!_generateNewCode)
                TextField(
                  controller: _facilityCodeController,
                  decoration: const InputDecoration(labelText: 'Existing Facility Code'),
                ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Register'),
              onPressed: () async {
                final String email = _emailController.text.trim();
                final String password = _passwordController.text.trim();
                final String firstName = _firstNameController.text.trim();
                final String lastName = _lastNameController.text.trim();
                try {
                  if (_role == 'Staff') {
                    String? facilityCode = _generateNewCode ? null : _facilityCodeController.text.trim();
                    String registeredFacilityCode = await Provider.of<AuthService>(context, listen: false)
                        .registerWithEmailAndPassword(email, password, _role, firstName, lastName, facilityCode: facilityCode);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacilityCodeScreen(facilityCode: registeredFacilityCode),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnterFacilityCodeScreen(
                          email: email,
                          password: password,
                          role: _role,
                          firstName: firstName,
                          lastName: lastName,
                        ),
                      ),
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