// ignore_for_file: library_private_types_in_public_api, sort_child_properties_last, use_build_context_synchronously

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
  bool _isLoading = false;

  @override
  void dispose() {
    _facilityCodeController.dispose();
    super.dispose();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
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
          title: const Text('Errore', style: TextStyle(color: Colors.black)),
          content: Text(message, style: const TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Inserisci il codice struttura', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _facilityCodeController,
              decoration: const InputDecoration(
                labelText: 'Codice struttura',
                labelStyle: TextStyle(color: Colors.black),
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
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Registrati', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                final String facilityCode = _facilityCodeController.text.trim();
                setState(() {
                  _isLoading = true;
                });
                _showLoadingDialog();
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
                    Navigator.of(context).pop(); 
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  } else {
                    Navigator.of(context).pop(); 
                    _showErrorDialog('Codice struttura non valido');
                  }
                } catch (e) {
                  Navigator.of(context).pop(); 
                  _showErrorDialog('Registrazione fallita: ${e.toString()}');
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
