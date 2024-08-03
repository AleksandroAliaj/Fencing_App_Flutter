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
                    Navigator.of(context).pop(); // Close the loading dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  } else {
                    Navigator.of(context).pop(); // Close the loading dialog
                    _showErrorDialog('Invalid facility code');
                  }
                } catch (e) {
                  Navigator.of(context).pop(); // Close the loading dialog
                  _showErrorDialog('Registration failed: ${e.toString()}');
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
