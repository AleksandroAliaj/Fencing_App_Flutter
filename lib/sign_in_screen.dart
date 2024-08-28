
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
  late PageController _tutorialPageController;
  int _currentTutorialPage = 0;

  @override
  void initState() {
    super.initState();
    _tutorialPageController = PageController();
  }

  @override
  void dispose() {
    _tutorialPageController.dispose();
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

  void _showTutorialPopup() {
    
    _currentTutorialPage = 0;
    _tutorialPageController = PageController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _tutorialPageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentTutorialPage = index;
                          });
                        },
                        children: [
                          _buildTutorialPage(
                            Icons.sports,
                            'Benvenuto in Fencing!',
                            'Scopri le funzionalità dedicate al mondo della scherma.',
                          ),
                          _buildTutorialPage(
                            Icons.notifications_active,
                            'Rimani aggiornato',
                            'Accedi per non perderti eventi, news e messaggi.',
                          ),
                          _buildTutorialPage(
                            Icons.fitness_center,
                            'Gestisci i tuoi allenamenti',
                            'Monitora i tuoi allenamenti e scala le classifiche.',
                          ),
                          _buildTutorialPage(
                            Icons.explore,
                            'Pronto per iniziare?',
                            'Inizia ad esplorare l\'app!',
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Chiudi', style: TextStyle(color: Colors.black)),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(4, (index) => _buildPageIndicator(index)),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_currentTutorialPage < 3) {
                              _tutorialPageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            _currentTutorialPage < 3 ? 'Avanti' : 'Fine',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      
      setState(() {
        _currentTutorialPage = 0;
        _tutorialPageController = PageController();
      });
    });
  }
  
  Widget _buildTutorialPage(IconData icon, String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.black),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 8,
      width: _currentTutorialPage == index ? 16 : 8,
      decoration: BoxDecoration(
        color: _currentTutorialPage == index ? Colors.black : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    
                    Image.asset(
                      'assets/logo.png',
                      width: MediaQuery.of(context).size.width * 0.23, 
                      height: MediaQuery.of(context).size.width * 0.23 * (850 / 828), 
                    ),
                    const SizedBox(height: 30), 
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
                            Navigator.of(context).pop(); 
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          } catch (e) {
                            Navigator.of(context).pop(); 
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
                              minimumSize: const Size(0, 50),
                              padding: EdgeInsets.zero,
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
                              minimumSize: const Size(0, 50),
                              padding: EdgeInsets.zero,
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
                            Navigator.of(context).pop(); 
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          } catch (e) {
                            Navigator.of(context).pop(); 
                            _showErrorDialog('Google Sign-In failed: ${e.toString()}');
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    
                    Align(
                      alignment: Alignment.bottomRight,
                      child: OutlinedButton(
                        onPressed: _showTutorialPopup,  
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          backgroundColor: Colors.white,
                          minimumSize: const Size(120, 40),
                        ),
                        child: const Text(
                          'Allez',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
