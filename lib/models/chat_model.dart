import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead; 

  MessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastUpdate;
  
  // Marketplace Specific Fields
  final String carId; 
  final String carTitle;
  final String carImageUrl;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastUpdate,
    required this.carId,
    required this.carTitle,
    required this.carImageUrl,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatRoomModel(
      id: docId,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastUpdate: (map['lastUpdate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      carId: map['carId'] ?? '',
      carTitle: map['carTitle'] ?? 'Vehicle',
      carImageUrl: map['carImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastUpdate': FieldValue.serverTimestamp(),
      'carId': carId,
      'carTitle': carTitle,
      'carImageUrl': carImageUrl,
    };
  }
}