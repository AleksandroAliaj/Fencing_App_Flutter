// chat_screen.dart

// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatType;
  final String? chatId;

  const ChatScreen({super.key, required this.chatType, this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _facilityCode;
  String? _userRole;
  String? _userEmail;
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
        _userEmail = user.email;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getChatTitle()),
        actions: widget.chatType == 'private'
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteChatDialog(context),
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  child: widget.chatType == 'private'
                      ? PrivateMessagesStream(chatId: widget.chatId!)
                      : MessagesStream(facilityCode: _facilityCode!, chatType: widget.chatType, userRole: _userRole!),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your message...',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showDeleteChatDialog(BuildContext context) {
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
                await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).delete();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to chat selection screen
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat eliminata con successo')));
              },
            ),
          ],
        );
      },
    );
  }

  String _getChatTitle() {
    switch (widget.chatType) {
      case 'global':
        return 'Chat Globale';
      case 'athletes_coaches':
        return 'Chat Atleti e Allenatori';
      case 'athletes':
        return 'Chat Atleti';
      case 'private':
        return 'Chat Privata';
      default:
        return 'Chat';
    }
  }

  void _sendMessage() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null && _messageController.text.isNotEmpty) {
    final messageText = _messageController.text;
    final senderEmail = _userEmail;

    if (widget.chatType == 'private') {
      final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

      // Aggiungi il messaggio
      await chatRef.collection('messages').add({
        'text': messageText,
        'sender': senderEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Aggiorna l'ultimo messaggio e il timestamp
      await chatRef.update({
        'lastMessage': messageText,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });

      // Mantieni solo gli ultimi 100 messaggi
      final messageDocs = (await chatRef.collection('messages')
        .orderBy('timestamp')
        .get()).docs;

      if (messageDocs.length > 100) {
        final messagesToDelete = messageDocs.take(messageDocs.length - 100);
        for (var doc in messagesToDelete) {
          await doc.reference.delete();
        }
      }
    } else {
      final collectionRef = FirebaseFirestore.instance.collection('messages');
      
      // Aggiungi il messaggio
      await collectionRef.add({
        'text': messageText,
        'sender': senderEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'facilityCode': _facilityCode,
        'chatType': widget.chatType,
        'senderRole': _userRole,
      });

      // Mantieni solo gli ultimi 100 messaggi
      final messageQuerySnapshot = await collectionRef
        .where('facilityCode', isEqualTo: _facilityCode)
        .where('chatType', isEqualTo: widget.chatType)
        .orderBy('timestamp', descending: true)
        .get();

      final messageDocs = messageQuerySnapshot.docs;

      if (messageDocs.length > 100) {
        final messagesToDelete = messageDocs.take(messageDocs.length - 100);
        for (var doc in messagesToDelete) {
          await doc.reference.delete();
        }
      }
    }

    _messageController.clear();
  }
}



}

class PrivateMessagesStream extends StatelessWidget {
  final String chatId;

  const PrivateMessagesStream({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found'));
        }
        
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
        final messageText = message['text'];
        final messageSender = message['sender'];

        final currentUserEmail = Provider.of<AuthService>(context, listen: false).currentUser?.email;

        final messageBubble = MessageBubble(
          sender: messageSender,
          text: messageText,
          isMe: currentUserEmail == messageSender,
        );

  messageBubbles.add(messageBubble);
}

        
        // Limita il numero di messaggi a 100
        if (messages.length > 100) {
          final messagesToDelete = messages.skip(100);
          for (var doc in messagesToDelete) {
            doc.reference.delete();
          }
        }
        
        return ListView(
          reverse: true,
          children: messageBubbles,
        );
      },
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String facilityCode;
  final String chatType;
  final String userRole;

  const MessagesStream({super.key, required this.facilityCode, required this.chatType, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getMessageStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found'));
        }
        
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];
        final currentUserEmail = Provider.of<AuthService>(context, listen: false).currentUser?.email;
        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUserEmail == messageSender,
          );

          messageBubbles.add(messageBubble);
        }
        
        // Limita il numero di messaggi a 100
        if (messages.length > 100) {
          final messagesToDelete = messages.skip(100);
          for (var doc in messagesToDelete) {
            doc.reference.delete();
          }
        }
        
        return ListView(
          reverse: true,
          children: messageBubbles,
        );
      },
    );
  }

  Stream<QuerySnapshot> _getMessageStream() {
    Query query = FirebaseFirestore.instance
        .collection('messages')
        .where('facilityCode', isEqualTo: facilityCode)
        .where('chatType', isEqualTo: chatType);

    return query.orderBy('timestamp', descending: true).snapshots();
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.sender, required this.text, required this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0),
              bottomLeft: isMe ? const Radius.circular(10.0) : const Radius.circular(0.0),
              bottomRight: isMe ? const Radius.circular(0.0) : const Radius.circular(10.0),
            ),
            elevation: 5.0,
            color: isMe ? const Color.fromARGB(255, 250, 232, 167) : Colors.white,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black), // Contorno nero
                borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0),
              bottomLeft: isMe ? const Radius.circular(10.0) : const Radius.circular(0.0),
              bottomRight: isMe ? const Radius.circular(0.0) : const Radius.circular(10.0),
            ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: isMe ? Colors.black : Colors.black, // Testo bianco per i propri messaggi
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  
