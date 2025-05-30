import 'package:flow/data/models/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NotificationProvider extends ChangeNotifier {
  final _notifications = <NotificationModel>[];

  List<NotificationModel> get notifications => _notifications;

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

  Future<void> markAsRead(String id) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .update({'isRead': true});
    _notifications.firstWhere((n) => n.id == id).isRead = true;
    notifyListeners();
  }

  Future<void> createNotification(NotificationModel model) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .add(model.toMap());
    await loadNotifications(model.userId); // Перезагрузи список
  }
}
