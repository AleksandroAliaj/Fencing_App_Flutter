// ignore_for_file: library_private_types_in_public_api, sort_child_properties_last, use_build_context_synchronously

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
          title: const Text('Attenzione', style: TextStyle(color: Colors.black)),
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
        title: const Text('Fencing', style: TextStyle(color: Colors.black)),
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
                labelStyle: const TextStyle(color: Colors.black),
                errorStyle: const TextStyle(color: Colors.red),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(color: Colors.black),
              onChanged: (value) => _validateInputs(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError,
                labelStyle: const TextStyle(color: Colors.black),
                errorStyle: const TextStyle(color: Colors.red),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.black),
              onChanged: (value) => _validateInputs(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Entra', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: const Text('Google', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(0, 50),  // Altezza fissa, larghezza adattiva
                      padding: EdgeInsets.zero,  // Rimuove il padding interno
                    ),
                    onPressed: () {
                      setState(() {
                        _showGoogleOptions = !_showGoogleOptions;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    child: const Text('Registrati', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(0, 50),  // Altezza fissa, larghezza adattiva
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
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Registrati con Google', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GoogleSignInScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('Entra con Google', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
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