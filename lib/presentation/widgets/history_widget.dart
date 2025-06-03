import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/notification_provider.dart';
import 'package:flow/data/models/notification_model.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryNotificationSheet extends StatefulWidget {
  final Stream<List<NotificationModel>> stream;
  final ScrollController scrollController;
  const HistoryNotificationSheet({
    super.key,
    required this.scrollController,
    required this.stream,
  });

  @override
  State<HistoryNotificationSheet> createState() =>
      _HistoryNotificationSheetState();
}

class _HistoryNotificationSheetState extends State<HistoryNotificationSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<NotificationProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).notificationHistory2,
                style: TextStyle(
                  fontFamily: 'SFProText',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final userId =
                      Provider.of<AuthProvider>(context, listen: false)
                          .user
                          ?.uid;
                  if (userId != null) {
                    await provider.clearHistoryNotifications(userId);
                  }
                },
                child: Text(
                  S.of(context).clearAll,
                  style: const TextStyle(
                    fontFamily: 'SFProText',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<NotificationModel>>(
            stream: widget.stream,
            builder: (context, snapshot) {
              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 70),
                    Image.asset("assets/image/fishGreenDark.png",
                        scale: 5),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).notificationHistoryIsEmpty,
                      style: TextStyle(
                        fontFamily: 'SFProText',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: history.length,
                controller: widget.scrollController,
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
