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
        SnackBar(
          content: Text('Inserisci nome e cognome', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
      );
      return false;
    }
    if ((_role != 'Staff' || !_generateNewCode) && _facilityCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci il codice struttura', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Registrati con Google', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Cognome',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _role,
              dropdownColor: Colors.white,
              iconEnabledColor: Colors.black,
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
                  child: Text(value, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
            ),
            if (_role == 'Staff')
              Row(
                children: [
                  Checkbox(
                    value: _generateNewCode,
                    activeColor: Colors.black,
                    checkColor: Colors.white,
                    onChanged: (bool? value) {
                      setState(() {
                        _generateNewCode = value!;
                      });
                    },
                  ),
                  const Text('Genera un nuovo codice struttura', style: TextStyle(color: Colors.black)),
                ],
              ),
            if (_role != 'Staff' || !_generateNewCode)
              TextField(
                controller: _facilityCodeController,
                decoration: InputDecoration(
                  labelText: 'Codice struttura',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white)
                : const Text('Entra con Google', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
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
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Errore: ${e.toString()}', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.black,
                      ),
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
