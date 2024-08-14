import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'register_screen.dart';
import 'profile_screen.dart';
import 'google_sign_in.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  bool _showGoogleOptions = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          title: Text('Attenzione', style: TextStyle(color: Colors.black)),
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
      _passwordError = _passwordController.text.isNotEmpty ? null : 'La password non può essere vuota';
    });
  }

  bool _isFormValid() {
    _validateInputs();
    return _emailError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Fencing', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailError,
                labelStyle: TextStyle(color: Colors.black),
                errorStyle: TextStyle(color: Colors.red),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (value) => _validateInputs(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError,
                labelStyle: TextStyle(color: Colors.black),
                errorStyle: TextStyle(color: Colors.red),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              obscureText: true,
              style: TextStyle(color: Colors.black),
              onChanged: (value) => _validateInputs(),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Entra', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () async {
                if (_isFormValid()) {
                  final String email = _emailController.text.trim();
                  final String password = _passwordController.text.trim();
                  setState(() => _isLoading = true);
                  _showLoadingDialog();
                  try {
                    await Provider.of<AuthService>(context, listen: false).signInWithEmailAndPassword(email, password);
                    Navigator.of(context).pop(); // Close the loading dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  } catch (e) {
                    Navigator.of(context).pop(); // Close the loading dialog
                    _showErrorDialog('Autenticazione fallita: ${e.toString()}');
                  } finally {
                    setState(() => _isLoading = false);
                  }
                } else {
                  _showErrorDialog('Correggi gli errori in rosso prima di procedere.');
                }
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: Text('Google', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(0, 50),  // Altezza fissa, larghezza adattiva
                      padding: EdgeInsets.zero,  // Rimuove il padding interno
                    ),
                    onPressed: () {
                      setState(() {
                        _showGoogleOptions = !_showGoogleOptions;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    child: Text('Registrati', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(0, 50),  // Altezza fissa, larghezza adattiva
                      padding: EdgeInsets.zero,  // Rimuove il padding interno
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (_showGoogleOptions) ...[
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Registrati con Google', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GoogleSignInScreen()),
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text('Entra con Google', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () async {
                  setState(() => _isLoading = true);
                  _showLoadingDialog();
                  try {
                    await Provider.of<AuthService>(context, listen: false).signInWithGoogle();
                    Navigator.of(context).pop(); // Close the loading dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  } catch (e) {
                    Navigator.of(context).pop(); // Close the loading dialog
                    _showErrorDialog('Google Sign-In failed: ${e.toString()}');
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}