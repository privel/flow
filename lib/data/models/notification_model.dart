class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? action;
  final bool isRead;
  

  /// Тип уведомления: invitation, deadline, info и т.д.
  final String type;

  /// Дополнительные данные: boardId, taskId, deadline и т.д.
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isRead,
    required this. action,
    required this.type,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'action': action,
      'type': type,
      'metadata': metadata,
    };
  }

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      action: map['action'],

      type: map['type'] ?? 'info',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  NotificationModel copyWith({
  String? id,
  String? userId,
  String? title,
  String? description,
  DateTime? timestamp,
  bool? isRead,
  String? action,
  String? type,
  Map<String, dynamic>? metadata,
}) {
  return NotificationModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    timestamp: timestamp ?? this.timestamp,
    isRead: isRead ?? this.isRead,
    action: action ?? this.action,
    type: type ?? this.type,
    metadata: metadata ?? this.metadata,
  );
}

}
