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
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.black),
              SizedBox(width: 20),
              Text('Caricamento...', style: TextStyle(color: Colors.black)),
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
          backgroundColor: Colors.white,
          title: Text('Errore', style: TextStyle(color: Colors.black)),
          content: Text(message, style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
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
      _emailError = _validateEmail(_emailController.text) ? null : 'Email non valida';
      _passwordError = _passwordController.text.length >= 6 ? null : 'La password deve essere di almeno 6 caratteri';
      _repeatPasswordError = _passwordController.text == _repeatPasswordController.text ? null : 'Le password non corrispondono';
    });
  }

  bool _isFormValid() {
    _validateInputs();
    return _emailError == null && _passwordError == null && _repeatPasswordError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Registrati', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTextField(_firstNameController, 'Nome'),
            SizedBox(height: 20),
            _buildTextField(_lastNameController, 'Cognome'),
            SizedBox(height: 20),
            _buildTextField(_emailController, 'Email', errorText: _emailError),
            SizedBox(height: 20),
            _buildTextField(_passwordController, 'Password', isPassword: true, errorText: _passwordError),
            SizedBox(height: 20),
            _buildTextField(_repeatPasswordController, 'Ripeti la password', isPassword: true, errorText: _repeatPasswordError),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
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
                      child: Text(value, style: TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            if (_role == 'Staff') ...[
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _generateNewCode,
                    onChanged: (bool? value) {
                      setState(() {
                        _generateNewCode = value!;
                      });
                    },
                    activeColor: Colors.black,
                  ),
                  Text('Genera un nuovo codice struttura', style: TextStyle(color: Colors.black)),
                ],
              ),
              if (!_generateNewCode) ...[
                SizedBox(height: 20),  // Aggiunto spazio extra qui
                _buildTextField(_facilityCodeController, 'Codice Struttura esistente'),
              ],
            ],
            SizedBox(height: 30),
            ElevatedButton(
              child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Registrati', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
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
                    _showErrorDialog('Registrazione fallita: ${e.toString()}');
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                } else {
                  _showErrorDialog('Compila correttamente tutti i campi');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false, String? errorText}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        labelStyle: TextStyle(color: Colors.black),
        errorStyle: TextStyle(color: Colors.red),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      obscureText: isPassword,
      style: TextStyle(color: Colors.black),
      onChanged: (value) => _validateInputs(),
    );
  }
}