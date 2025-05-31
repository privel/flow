import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/notification_model.dart';
import 'package:flow/data/models/user_models.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  /// Загрузка уведомлений для конкретного пользователя
  Future<void> loadNotifications(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    _notifications.clear();
    for (var doc in snapshot.docs) {
      _notifications.add(NotificationModel.fromMap(doc.data(), doc.id));
    }
    notifyListeners();
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
    );

    await createNotification(notification);
  }

  /// Отметить уведомление как прочитанное
  Future<void> markAsRead(String id) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .update({'isRead': true});

    final notif = _notifications.firstWhere((n) => n.id == id,
        orElse: () => NotificationModel.empty());
    notif.isRead = true;
    notifyListeners();
  }

  /// Создать новое уведомление
  Future<void> createNotification(NotificationModel model) async {
    final doc = await FirebaseFirestore.instance
        .collection('notifications')
        .add(model.toMap());

    // Обновление ID, если нужно
    await doc.update({'id': doc.id});
    await loadNotifications(model.userId);
  }
}
