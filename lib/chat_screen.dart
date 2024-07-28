// chat_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatType;
  final String? chatId;

  const ChatScreen({Key? key, required this.chatType, this.chatId}) : super(key: key);

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

  void _sendMessage() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _messageController.text.isNotEmpty) {
      if (widget.chatType == 'private') {
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({
          'text': _messageController.text,
          'sender': _userEmail,
          'timestamp': FieldValue.serverTimestamp(),
        });
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
          'lastMessage': _messageController.text,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
        });
      } else {
        FirebaseFirestore.instance.collection('messages').add({
          'text': _messageController.text,
          'sender': _userEmail,
          'timestamp': FieldValue.serverTimestamp(),
          'facilityCode': _facilityCode,
          'chatType': widget.chatType,
          'senderRole': _userRole,
        });
      }
      _messageController.clear();
    }
  }
}

class PrivateMessagesStream extends StatelessWidget {
  final String chatId;

  const PrivateMessagesStream({Key? key, required this.chatId}) : super(key: key);

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

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
          );

          messageBubbles.add(messageBubble);
        }
        return ListView(
          reverse: true,
          children: messageBubbles,
        );
      },
    );
  }
}

// ... (il resto del codice rimane invariato)

class MessagesStream extends StatelessWidget {
  final String facilityCode;
  final String chatType;
  final String userRole;

  const MessagesStream({Key? key, required this.facilityCode, required this.chatType, required this.userRole}) : super(key: key);

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
        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
          );

          messageBubbles.add(messageBubble);
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

    // Aggiungi l'ordinamento per timestamp alla fine
    return query.orderBy('timestamp', descending: true).snapshots();
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({Key? key, required this.sender, required this.text}) : super(key: key);

  final String sender;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            elevation: 5.0,
            color: Colors.blueAccent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
