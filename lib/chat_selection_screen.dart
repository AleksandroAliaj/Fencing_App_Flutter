import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'chat_screen.dart';

class ChatSelectionScreen extends StatelessWidget {
  const ChatSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return FutureBuilder<String?>(
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

        List<ChatOption> chatOptions;

        switch (role.toLowerCase()) {
          case 'atleta':
            chatOptions = [
              ChatOption('Chat Globale', () => _navigateToChat(context, 'global')),
              ChatOption('Chat Atleti e Allenatori', () => _navigateToChat(context, 'athletes_coaches')),
              ChatOption('Chat Atleti', () => _navigateToChat(context, 'athletes')),
            ];
            break;
          case 'allenatore':
            chatOptions = [
              ChatOption('Chat Globale', () => _navigateToChat(context, 'global')),
              ChatOption('Chat Atleti e Allenatori', () => _navigateToChat(context, 'athletes_coaches')),
              
            ];
            break;
          case 'staff':
            chatOptions = [
              ChatOption('Chat Globale', () => _navigateToChat(context, 'global')),
              
            ];
            break;
          default:
            return Center(child: Text('Ruolo non riconosciuto: $role'));
        }

        return ListView.builder(
          itemCount: chatOptions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(chatOptions[index].title),
              onTap: chatOptions[index].onTap,
            );
          },
        );
      },
    );
  }

  void _navigateToChat(BuildContext context, String chatType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatType: chatType),
      ),
    );
  }
}

class ChatOption {
  final String title;
  final VoidCallback onTap;

  ChatOption(this.title, this.onTap);
}