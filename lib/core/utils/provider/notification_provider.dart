import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/notification_model.dart';
import 'package:flow/data/models/user_models.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Загрузка уведомлений для конкретного пользователя
  Future<void> loadNotifications(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    _notifications.clear();
    for (var doc in snapshot.docs) {
      _notifications.add(NotificationModel.fromMap(doc.id, doc.data()));
    }
    notifyListeners();
  }

  Future<void> setNotificationAction(String id, String action) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .update({
      'action': action,
      'isRead': true,
    });

    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        action: action,
        isRead: true,
      );
      notifyListeners();
    }
  }

  /// Отправить уведомление-приглашение
  Future<void> sendInvitationNotification({
    required String recipientId,
    required AppUser sender,
    required BoardModel board,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: recipientId,
      title: 'Новое приглашение в доску',
      description: '${sender.displayName} пригласил(а) вас в "${board.title}"',
      timestamp: DateTime.now(),
      isRead: false,
      action: null,
      type: 'invitation',
      metadata: {
        'boardId': board.id,
      },
    );

    await createNotification(notification);
  }

  /// Отметить уведомление как прочитанное
  Future<void> markAsRead(String id) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .update({'isRead': true});

    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Шаг 5: Добавим метод в NotificationProvider
Future<void> clearHistoryNotifications(String userId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('action', isNotEqualTo: null)
      .get();

  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }
  notifyListeners();
}


Future<void> markAllAsRead(String userId) async {
  final query = await FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false)
      .get();

  for (var doc in query.docs) {
    await doc.reference.update({'isRead': true});
  }

  // Обновляем локально, если ты хранишь список в памяти
  for (var i = 0; i < _notifications.length; i++) {
    if (_notifications[i].userId == userId && !_notifications[i].isRead) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  notifyListeners();
}

  /// Создать новое уведомление
  Future<void> createNotification(NotificationModel model) async {
    final doc = await FirebaseFirestore.instance
        .collection('notifications')
        .add(model.toMap());

    await doc.update({'id': doc.id});
    await loadNotifications(model.userId);
  }
}
