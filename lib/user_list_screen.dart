// user_list_screen.dart

// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String _searchQuery = '';
  String? _currentUserFacilityCode;

  @override
  void initState() {
    super.initState();
    _getCurrentUserFacilityCode();
  }

  Future<void> _getCurrentUserFacilityCode() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _currentUserFacilityCode = userData['facilityCode'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca un utente...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: _currentUserFacilityCode == null
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('facilityCode', isEqualTo: _currentUserFacilityCode)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading users: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(child: Text('No users found'));
                      }

                      final users = snapshot.data!.docs;

                      final filteredUsers = users.where((doc) {
                        final userData = doc.data() as Map<String, dynamic>;
                        final userName = '${userData['firstName']} ${userData['lastName']}'.toLowerCase();
                        final userEmail = userData['email'].toLowerCase();
                        return userName.contains(_searchQuery) || userEmail.contains(_searchQuery);
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final userData = filteredUsers[index].data() as Map<String, dynamic>;
                          final userId = filteredUsers[index].id;
                          final userName = '${userData['firstName']} ${userData['lastName']}';
                          final userEmail = userData['email'];

                          if (userId == user?.uid) {
                            return SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.black, width: 1),
                              ),
                              child: ListTile(
                                title: Text(userName, style: TextStyle(color: Colors.black)),
                                subtitle: Text(userEmail, style: TextStyle(color: Colors.black54)),
                                onTap: () => _startChat(context, userId, userEmail),
                                trailing: Icon(Icons.chat, color: Colors.black54),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context, String otherUserId, String otherUserEmail) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      _createPrivateChat(context, currentUser.uid, otherUserId, otherUserEmail);
    }
  }

  void _createPrivateChat(BuildContext context, String currentUserId, String otherUserId, String otherUserEmail) async {
    // Controlla se una chat privata esiste già
    final existingChat = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    final chatExists = existingChat.docs.any((doc) {
      final participants = doc['participants'] as List<dynamic>;
      return participants.contains(otherUserId) && participants.length == 2;
    });

    if (chatExists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La chat esiste già')));
      return;
    }

    // Ottieni l'email dell'utente corrente
    final currentUserData = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    final currentUserEmail = currentUserData['email'];

    // Crea una nuova chat
    await FirebaseFirestore.instance.collection('chats').add({
      'participants': [currentUserId, otherUserId],
      'participantEmails': {
        currentUserId: currentUserEmail,
        otherUserId: otherUserEmail,
      },
      'lastMessage': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat creata con successo')));
  }
}
