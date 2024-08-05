import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'profile_screen.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  _GoogleSignInScreenState createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  String _role = 'Staff';
  bool _generateNewCode = true;
  final TextEditingController _facilityCodeController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _facilityCodeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both first and last names.')),
      );
      return false;
    }
    if ((_role != 'Staff' || !_generateNewCode) && _facilityCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the facility code.')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign In'),
      ),
      body: Padding(
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
            DropdownButton<String>(
              value: _role,
              onChanged: (String? newValue) {
                setState(() {
                  _role = newValue!;
                  if (_role != 'Staff') {
                    _generateNewCode = false;
                  }
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
            if (_role == 'Staff')
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
            if (_role != 'Staff' || !_generateNewCode)
              TextField(
                controller: _facilityCodeController,
                decoration: const InputDecoration(labelText: 'Facility Code'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: _isLoading ? CircularProgressIndicator() : const Text('Sign In with Google'),
              onPressed: () async {
                if (_validateInputs()) {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    String? facilityCode = (_role == 'Staff' && _generateNewCode) ? null : _facilityCodeController.text.trim();
                    String registeredFacilityCode = await authService.registerWithGoogle(
                      _role,
                      firstName: _firstNameController.text.trim(),
                      lastName: _lastNameController.text.trim(),
                      facilityCode: facilityCode,
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
