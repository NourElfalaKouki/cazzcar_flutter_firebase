import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Needed for time formatting
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
  final ScrollController _scrollController = ScrollController();
  
  // FIX 1: Define the stream here so it persists across rebuilds (like keyboard opening)
  late Stream<List<MessageModel>> _messagesStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream ONCE. 
    // This prevents the chat from "blinking" every time you type.
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);
    _messagesStream = chatVM.getMessages(widget.receiverId, widget.carId);
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context, listen: false); // listen: false for actions
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            // FIX 3: Safe Image Loading
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: widget.carImageUrl.isNotEmpty 
                  ? NetworkImage(widget.carImageUrl) 
                  : null,
              child: widget.carImageUrl.isEmpty 
                  ? Icon(Icons.directions_car, size: 20, color: colorScheme.onPrimaryContainer) 
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.carTitle, 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Vehicle Inquiry",
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Container(
        color: colorScheme.surfaceContainerLowest, // Updated for newer Flutter/Material versions
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: _messagesStream, // Use the stable stream variable
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final msgs = snapshot.data ?? [];
                  
                  if (msgs.isEmpty) {
                    return _buildEmptyChat(colorScheme);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Chat starts from bottom
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      final msg = msgs[index];
                      // Check if the current user sent this message
                      final isMe = msg.senderId == chatVM.currentUserId;
                      return _buildChatBubble(msg, isMe, colorScheme);
                    },
                  );
                },
              ),
            ),
            _buildInputArea(colorScheme, chatVM),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(MessageModel msg, bool isMe, ColorScheme colorScheme) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          // FIX 2: Real Timestamp
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
            child: Text(
              _formatMessageTime(msg.timestamp), 
              style: TextStyle(fontSize: 10, color: colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ColorScheme colorScheme, ChatViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Message...",
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_msgController.text.trim().isEmpty) return;
              vm.sendChatMessage(
                receiverId: widget.receiverId,
                text: _msgController.text.trim(),
                carId: widget.carId,
                carTitle: widget.carTitle,
                carImageUrl: widget.carImageUrl,
              );
              _msgController.clear();
            },
            child: CircleAvatar(
              backgroundColor: colorScheme.primary,
              radius: 24,
              child: Icon(Icons.send_rounded, color: colorScheme.onPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            "Start the conversation",
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "Ask about the ${widget.carTitle}",
            style: TextStyle(color: colorScheme.outline, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Helper function for the timestamp
  String _formatMessageTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}