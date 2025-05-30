import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isRead,
  });
  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
