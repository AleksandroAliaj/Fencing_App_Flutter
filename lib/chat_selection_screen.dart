
// ignore_for_file: unnecessary_null_comparison, use_super_parameters, avoid_print, use_build_context_synchronously, library_private_types_in_public_api, unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'chat_screen.dart';

class ChatSelectionScreen extends StatefulWidget {
  const ChatSelectionScreen({Key? key}) : super(key: key);

  @override
  _ChatSelectionScreenState createState() => _ChatSelectionScreenState();
}

class _ChatSelectionScreenState extends State<ChatSelectionScreen> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        // actions: [
        //   IconButton(
        //     icon: Icon(_isEditMode ? Icons.done : Icons.edit),
        //     onPressed: _toggleEditMode,
        //   ),
        // ],
      ),
      body: FutureBuilder<String?>(
        future: authService.getUserRole(user?.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading user role: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User role not found'));
          }

          final role = snapshot.data!;
          print('User role: $role');

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('participants', arrayContains: user?.uid)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<ChatOption> chatOptions = [
                ChatOption('Chat Globale', Icons.public, () => _navigateToChat(context, 'global')),
              ];

              if (role.toLowerCase() == 'atleta' || role.toLowerCase() == 'allenatore') {
                chatOptions.add(ChatOption('Chat Atleti e Allenatori', Icons.group, () => _navigateToChat(context, 'athletes_coaches')));
              }

              if (role.toLowerCase() == 'atleta') {
                chatOptions.add(ChatOption('Chat Atleti', Icons.sports, () => _navigateToChat(context, 'athletes')));
              }

              if (chatSnapshot.hasData) {
                for (var doc in chatSnapshot.data!.docs) {
                  final chatData = doc.data() as Map<String, dynamic>;
                  final otherUserId = (chatData['participants'] as List<dynamic>)
                      .firstWhere((id) => id != user?.uid);
                  chatOptions.add(ChatOption(
                    chatData['participantEmails'][otherUserId],
                    Icons.person,
                    () => _navigateToChat(context, 'private', chatId: doc.id),
                    onDelete: _isEditMode ? () => _deletePrivateChat(context, doc.id) : null,
                  ));
                }
              }

              return ListView.builder(
                itemCount: chatOptions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildChatButton(
                      context: context,
                      icon: chatOptions[index].icon,
                      label: chatOptions[index].title,
                      onPressed: chatOptions[index].onTap,
                      onDelete: chatOptions[index].onDelete,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChatDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChatButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    VoidCallback? onDelete,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.black, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode; 
    });
  }

  void _deletePrivateChat(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Elimina chat"),
          content: const Text("Sei sicuro di voler eliminare questa chat? L'azione sarà irreversibile per entrambi gli utenti."),
          actions: [
            TextButton(
              child: const Text("Annulla"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Elimina"),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat eliminata con successo')));
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToChat(BuildContext context, String chatType, {String? chatId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatType: chatType, chatId: chatId),
      ),
    );
  }

  void _showCreateChatDialog(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Crea una nuova chat"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Inserire il nome e cognome della persona con cui vuoi iniziare una chat"),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(hintText: "Inserisci il nome"),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(hintText: "Inserisci il cognome"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Annulla"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Crea chat"),
              onPressed: () => _createPrivateChat(context, firstNameController.text, lastNameController.text),
            ),
          ],
        );
      },
    );
  }

  void _createPrivateChat(BuildContext context, String otherFirstName, String otherLastName) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    final userData = await authService.getUserData(currentUser!.uid);

    if (currentUser != null) {
      final currentUserName = userData['firstName'];
      final currentUserSurname = userData['lastName'];

      
      if (otherFirstName == currentUserName && otherLastName == currentUserSurname) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Non puoi creare una chat con te stesso, digita il nome e cognome di un\'altra persona.'),
        ));
        return;
      }

      
      final otherUserQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('firstName', isEqualTo: otherFirstName)
          .where('lastName', isEqualTo: otherLastName)
          .get();

      if (otherUserQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utente non trovato')));
        return;
      }

      final otherUserDoc = otherUserQuery.docs.first;
      final otherUserId = otherUserDoc.id;

      
      final existingChat = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser.uid)
          .get();

      final chatExists = existingChat.docs.any((doc) {
        final participants = doc['participants'] as List<dynamic>;
        return participants.contains(otherUserId) && participants.length == 2;
      });

      if (chatExists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La chat esiste già')));
        return;
      }

      
      await FirebaseFirestore.instance.collection('chats').add({
        'participants': [currentUser.uid, otherUserId],
        'participantEmails': {
          currentUser.uid: currentUser.email,
          otherUserId: otherUserDoc['email'],
        },
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat creata con successo')));
    }
  }
}

class ChatOption {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  ChatOption(this.title, this.icon, this.onTap, {this.onDelete});
}