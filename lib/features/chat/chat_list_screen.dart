import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/chat_model.dart';
import 'chat_vm.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Messages"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ChatRoomModel>>(
        stream: chatVM.myInboxStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final rooms = snapshot.data ?? [];

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  const Text("No conversations yet."),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),
            itemBuilder: (context, index) {
              final room = rooms[index];
              
              // Identify the receiver (the person who is NOT the current user)
              final receiverId = room.participants.firstWhere((id) => id != chatVM.currentUserId);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    room.carImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      width: 60, height: 60, color: colorScheme.surfaceVariant,
                      child: const Icon(Icons.directions_car),
                    ),
                  ),
                ),
                title: Text(
                  room.carTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  room.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(room.lastUpdate),
                      style: TextStyle(fontSize: 12, color: colorScheme.outline),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverId: receiverId,
                        carId: room.carId,
                        carTitle: room.carTitle,
                        carImageUrl: room.carImageUrl,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}