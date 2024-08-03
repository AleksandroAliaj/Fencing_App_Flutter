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
  final TextEditingController _repeatPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _facilityCodeController = TextEditingController();
  String _role = 'Staff';
  bool _generateNewCode = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _repeatPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _facilityCodeController.dispose();
    super.dispose();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _validateEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _validateInputs() {
    setState(() {
      _emailError = _validateEmail(_emailController.text) ? null : 'Invalid email format';
      _passwordError = _passwordController.text.length >= 6 ? null : 'Password must be at least 6 characters';
      _repeatPasswordError = _passwordController.text == _repeatPasswordController.text ? null : 'Passwords do not match';
    });
  }

  bool _isFormValid() {
    _validateInputs();
    return _emailError == null && _passwordError == null && _repeatPasswordError == null;
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
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailError,
              ),
              onChanged: (value) => _validateInputs(),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError,
              ),
              obscureText: true,
              onChanged: (value) => _validateInputs(),
            ),
            TextField(
              controller: _repeatPasswordController,
              decoration: InputDecoration(
                labelText: 'Repeat Password',
                errorText: _repeatPasswordError,
              ),
              obscureText: true,
              onChanged: (value) => _validateInputs(),
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
                if (_isFormValid()) {
                  final String email = _emailController.text.trim();
                  final String password = _passwordController.text.trim();
                  final String firstName = _firstNameController.text.trim();
                  final String lastName = _lastNameController.text.trim();
                  setState(() {
                    _isLoading = true;
                  });
                  _showLoadingDialog();
                  try {
                    if (_role == 'Staff') {
                      String? facilityCode = _generateNewCode ? null : _facilityCodeController.text.trim();
                      String registeredFacilityCode = await Provider.of<AuthService>(context, listen: false)
                          .registerWithEmailAndPassword(email, password, _role, firstName, lastName, facilityCode: facilityCode);
                      Navigator.of(context).pop(); // Close the loading dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FacilityCodeScreen(facilityCode: registeredFacilityCode),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop(); // Close the loading dialog
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
                    Navigator.of(context).pop(); // Close the loading dialog
                    _showErrorDialog('Registration failed: ${e.toString()}');
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                } else {
                  _showErrorDialog('Please fix the errors in red before submitting.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
