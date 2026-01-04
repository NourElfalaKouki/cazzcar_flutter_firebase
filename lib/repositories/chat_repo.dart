import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Unique ID per Buyer/Seller/Car combination
  String getChatRoomId(String userA, String userB, String carId) {
    List<String> ids = [userA, userB];
    ids.sort(); 
    return "${ids[0]}_${ids[1]}_$carId";
  }

  // Send Message & Update Room Summary
  Future<void> sendMessage(String roomId, MessageModel message, ChatRoomModel roomInfo) async {
    final batch = _db.batch();

    // 1. Add message to the sub-collection
    DocumentReference msgRef = _db.collection('chats').doc(roomId).collection('messages').doc();
    batch.set(msgRef, message.toMap());

    // 2. Update/Create the Room Summary (for the Inbox)
    DocumentReference roomRef = _db.collection('chats').doc(roomId);
    batch.set(roomRef, roomInfo.toMap(), SetOptions(merge: true));

    await batch.commit();
  }

  Stream<List<MessageModel>> getMessages(String roomId) {
    return _db.collection('chats')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => MessageModel.fromMap(doc.data())).toList());
  }

  Stream<List<ChatRoomModel>> getMyChatRooms(String userId) {
  return _db.collection('chats')
      .where('participants', arrayContains: userId) 
      .orderBy('lastUpdate', descending: true)    
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ChatRoomModel.fromMap(doc.data(), doc.id))
          .toList());
          }
}