import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/chat_model.dart';
import '../../repositories/chat_repo.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repo = ChatRepository();

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  // 1. FOR THE INBOX
  Stream<List<ChatRoomModel>> get myInboxStream {
    return _repo.getMyChatRooms(currentUserId);
  }

  // 2. FOR THE ACTIVE CHAT: Send a message
  Future<void> sendChatMessage({
    required String receiverId,
    required String text,
    required String carId,
    required String carTitle,
    required String carImageUrl,
  }) async {
    if (text.trim().isEmpty) return;

    final roomId = _repo.getChatRoomId(currentUserId, receiverId, carId);
    
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

  // 3. FOR THE ACTIVE CHAT: Get real-time messages for one specific room
  Stream<List<MessageModel>> getMessages(String receiverId, String carId) {
    final roomId = _repo.getChatRoomId(currentUserId, receiverId, carId);
    return _repo.getMessages(roomId);
  }
}