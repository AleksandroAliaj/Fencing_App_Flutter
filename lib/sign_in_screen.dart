import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'register_screen.dart';
import 'profile_screen.dart';

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
      _passwordError = _passwordController.text.isNotEmpty ? null : 'Password cannot be empty';
    });
  }

  bool _isFormValid() {
    _validateInputs();
    return _emailError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
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
            const SizedBox(height: 20),
            ElevatedButton(
              child: _isLoading ? CircularProgressIndicator() : const Text('Sign In'),
              onPressed: () async {
                if (_isFormValid()) {
                  final String email = _emailController.text.trim();
                  final String password = _passwordController.text.trim();
                  setState(() {
                    _isLoading = true;
                  });
                  _showLoadingDialog();
                  try {
                    await Provider.of<AuthService>(context, listen: false).signInWithEmailAndPassword(email, password);
                    Navigator.of(context).pop(); // Close the loading dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  } catch (e) {
                    Navigator.of(context).pop(); // Close the loading dialog
                    _showErrorDialog('Authentication failed: ${e.toString()}');
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
            TextButton(
              child: const Text('Register'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
