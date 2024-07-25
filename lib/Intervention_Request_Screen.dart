import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class InterventionRequestScreen extends StatefulWidget {
  const InterventionRequestScreen({super.key});

  @override
  _InterventionRequestScreenState createState() => _InterventionRequestScreenState();
}

class _InterventionRequestScreenState extends State<InterventionRequestScreen> {
  final TextEditingController _repairController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _userRole;
  String? _facilityCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user != null) {
      final DocumentSnapshot userData = await Provider.of<AuthService>(context, listen: false).getUserData(user.uid);
      setState(() {
        _facilityCode = userData['facilityCode'];
        _userRole = userData['role'];
        _isLoading = false;
      });
    }
  }

  Future<void> _submitPost() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _repairController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _facilityCode != null) {
      await FirebaseFirestore.instance.collection('intervention_requests').add({
        'repair': _repairController.text,
        'description': _descriptionController.text,
        'userId': user.uid,
        'facilityCode': _facilityCode,
        'status': 'Pending',
      });
      _repairController.clear();
      _descriptionController.clear();
    }
  }

  @override
  void dispose() {
    _repairController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Richiesta di Intervento'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                if (_userRole == 'atleta' || _userRole == 'allenatore')
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _repairController,
                          decoration: const InputDecoration(
                            labelText: 'Cosa devi riparare?',
                          ),
                        ),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descrivi il problema',
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitPost,
                          child: const Text('Pubblica'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('intervention_requests')
                        .where('facilityCode', isEqualTo: _facilityCode)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No requests found'));
                      }
                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          return ListTile(
                            title: Text(doc['repair']),
                            subtitle: Text(doc['description']),
                            trailing: _userRole == 'staff'
                                ? ElevatedButton(
                                    onPressed: () {
                                      doc.reference.update({'status': 'Confirmed'});
                                    },
                                    child: const Text('Conferma'),
                                  )
                                : null,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}