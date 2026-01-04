import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/chat_model.dart';
import 'chat_vm.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // We store the stream here so it doesn't restart every time the screen updates
  late Stream<List<ChatRoomModel>> _inboxStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream ONCE when the screen loads
    final vm = Provider.of<ChatViewModel>(context, listen: false);
    _inboxStream = vm.myInboxStream;
  }

  @override
  Widget build(BuildContext context) {
    // We still need the VM for currentUserId, but we don't need the stream from it
    final chatVM = Provider.of<ChatViewModel>(context); 
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Messages"),
      ),
      body: StreamBuilder<List<ChatRoomModel>>(
        stream: _inboxStream, // Use the stable stream variable
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final rooms = snapshot.data ?? [];

          if (rooms.isEmpty) {
            return _buildEmptyState(colorScheme);
          }

          return ListView.builder(
            itemCount: rooms.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final room = rooms[index];
              
              // FIX: Safer logic to find the "other" person.
              // If we can't find them, default to 'Unknown' to prevent crashes.
              final receiverId = room.participants.firstWhere(
                (id) => id != chatVM.currentUserId,
                orElse: () => 'Unknown',
              );

              // If something is wrong with the ID, hide this row
              if (receiverId == 'Unknown') return const SizedBox.shrink();

              return _ChatInboxTile(
                room: room,
                receiverId: receiverId,
                colorScheme: colorScheme,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha(128),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.forum_outlined, size: 60, color: colorScheme.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            "No messages yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "When you contact sellers, your\nconversations will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ChatInboxTile extends StatelessWidget {
  final ChatRoomModel room;
  final String receiverId;
  final ColorScheme colorScheme;

  const _ChatInboxTile({
    super.key,
    required this.room,
    required this.receiverId,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 1. CAR THUMBNAIL
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    room.carImageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      width: 64, height: 64, 
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.directions_car, size: 30),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // 2. TEXT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.carTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 3. TIME AND ARROW
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(room.lastUpdate),
                  style: TextStyle(
                    fontSize: 12, 
                    color: colorScheme.primary, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(Icons.arrow_forward_ios, size: 12, color: colorScheme.outlineVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays < 7) {
      return DateFormat('E').format(date); 
    } else {
      return DateFormat('MMM d').format(date); 
    }
  }
}