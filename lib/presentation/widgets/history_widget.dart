import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/notification_provider.dart';
import 'package:flow/data/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryNotificationSheet extends StatefulWidget {
  final Stream<List<NotificationModel>> stream;
  const HistoryNotificationSheet({super.key, required this.stream});

  @override
  State<HistoryNotificationSheet> createState() => _HistoryNotificationSheetState();
}

class _HistoryNotificationSheetState extends State<HistoryNotificationSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<NotificationProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('История уведомлений',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () async {
                  final userId = Provider.of<AuthProvider>(context, listen: false).user?.uid;
                  if (userId != null) {
                    await provider.clearHistoryNotifications(userId);
                  }
                },
                child: const Text('Очистить все'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<NotificationModel>>(
            stream: widget.stream,
            builder: (context, snapshot) {
              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return const Text('Нет уведомлений');
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final n = history[index];
                  return ListTile(
                    title: Text(n.title),
                    subtitle: Text(n.description),
                    trailing: Text(n.action ?? ''),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}