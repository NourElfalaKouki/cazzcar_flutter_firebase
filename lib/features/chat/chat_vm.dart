import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/chat_model.dart';
import '../../repositories/chat_repo.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repo = ChatRepository();

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  // 1. INBOX STREAM
  Stream<List<ChatRoomModel>> get myInboxStream {
    if (currentUserId.isEmpty) return const Stream.empty();
    return _repo.getMyChatRooms(currentUserId);
  }

  // Helper: Ensures User A and User B always have the same Room ID (e.g., "A_B_CarID")
  String _generateChatRoomId(String u1, String u2, String carId) {
    List<String> users = [u1, u2];
    users.sort(); // Sort alphabetically so ID is consistent regardless of who sends
    return "${users[0]}_${users[1]}_$carId";
  }

  // 2. SEND MESSAGE
  Future<void> sendChatMessage({
    required String receiverId,
    required String text,
    required String carId,
    required String carTitle,
    required String carImageUrl,
  }) async {
    if (text.trim().isEmpty) return;

    final roomId = _generateChatRoomId(currentUserId, receiverId, carId);

    final message = MessageModel(
      senderId: currentUserId,
      text: text,
      timestamp: DateTime.now(),
    );

    final roomInfo = ChatRoomModel(
      id: roomId,
      participants: [currentUserId, receiverId],
      lastMessage: text,
      lastUpdate: DateTime.now(),
      carId: carId,
      carTitle: carTitle,
      carImageUrl: carImageUrl,
    );

    await _repo.sendMessage(roomId, message, roomInfo);
  }

  // 3. GET MESSAGES (This was missing!)
  Stream<List<MessageModel>> getMessages(String receiverId, String carId) {
    if (currentUserId.isEmpty) return const Stream.empty();
    
    // We recreate the Room ID using the exact same logic as when sending
    final roomId = _generateChatRoomId(currentUserId, receiverId, carId);
    
    return _repo.getMessages(roomId);
  }
}