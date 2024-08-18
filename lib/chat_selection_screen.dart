// chat_selection_screen.dart

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
  bool _isEditMode = false; // Aggiungi questa variabile per gestire la modalità modifica

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Scaffold(
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
                ChatOption('Chat Globale', () => _navigateToChat(context, 'global')),
              ];

              if (role.toLowerCase() == 'atleta' || role.toLowerCase() == 'allenatore') {
                chatOptions.add(ChatOption('Chat Atleti e Allenatori', () => _navigateToChat(context, 'athletes_coaches')));
              }

              if (role.toLowerCase() == 'atleta') {
                chatOptions.add(ChatOption('Chat Atleti', () => _navigateToChat(context, 'athletes')));
              }

              // Aggiungi le chat private
              if (chatSnapshot.hasData) {
                for (var doc in chatSnapshot.data!.docs) {
                  final chatData = doc.data() as Map<String, dynamic>;
                  final otherUserId = (chatData['participants'] as List<dynamic>)
                      .firstWhere((id) => id != user?.uid);
                  chatOptions.add(ChatOption(
                    chatData['participantEmails'][otherUserId],
                    () => _navigateToChat(context, 'private', chatId: doc.id),
                    onDelete: _isEditMode ? () => _deletePrivateChat(context, doc.id) : null, // Mostra il tasto elimina solo in modalità modifica
                  ));
                }
              }

              return ListView.builder(
                itemCount: chatOptions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(chatOptions[index].title),
                    onTap: chatOptions[index].onTap,
                    trailing: chatOptions[index].onDelete != null
                        ? IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: chatOptions[index].onDelete,
                          )
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Stack(
        children: [
          // Positioned(
          //   bottom: 0,
          //   left: 60, // Posiziona il bottone modifica a sinistra
          //   child: FloatingActionButton(
          //     onPressed: _toggleEditMode, // Cambia modalità modifica
          //     child: const Icon(Icons.edit), // Icona per il bottone modifica
          //   ),
          // ),
          Positioned(
            bottom: 0,
            right: 30, // Posiziona il bottone aggiungi a destra
            child: FloatingActionButton(
              onPressed: () => _showCreateChatDialog(context),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode; // Cambia lo stato di modifica
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

      // Controlla se l'altro utente è lo stesso utente corrente
      if (otherFirstName == currentUserName && otherLastName == currentUserSurname) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Non puoi creare una chat con te stesso, digita il nome e cognome di un\'altra persona.'),
        ));
        return;
      }

      // Controlla se l'altro utente esiste
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

      // Controlla se una chat privata esiste già
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

      // Crea una nuova chat
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
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  ChatOption(this.title, this.onTap, {this.onDelete});
}
