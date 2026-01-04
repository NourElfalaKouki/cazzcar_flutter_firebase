import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_model.dart';
import 'chat_vm.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String carId;
  final String carTitle;
  final String carImageUrl;

  const ChatScreen({
    super.key, 
    required this.receiverId, 
    required this.carId,
    required this.carTitle,
    required this.carImageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.carImageUrl), radius: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.carTitle, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- MESSAGES LIST ---
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatVM.getMessages(widget.receiverId, widget.carId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final msgs = snapshot.data!;
                return ListView.builder(
                  reverse: true, // Newest messages at the bottom
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final isMe = msgs[index].senderId == chatVM.currentUserId;
                    return _buildChatBubble(msgs[index], isMe, colorScheme);
                  },
                );
              },
            ),
          ),

          // --- INPUT AREA ---
          _buildInputArea(colorScheme, chatVM),
        ],
      ),
    );
  }

  Widget _buildChatBubble(MessageModel msg, bool isMe, ColorScheme colorScheme) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: isMe ? colorScheme.onPrimary : colorScheme.onSurface),
        ),
      ),
    );
  }

  Widget _buildInputArea(ColorScheme colorScheme, ChatViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () {
              vm.sendChatMessage(
                receiverId: widget.receiverId,
                text: _msgController.text,
                carId: widget.carId,
                carTitle: widget.carTitle,
                carImageUrl: widget.carImageUrl,
              );
              _msgController.clear();
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}