import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/notification_provider.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      final userId = auth.user?.uid ?? '';
      if (userId.isNotEmpty) {
        notificationProvider.loadNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notification",
          style: TextStyle(
            fontFamily: 'SFProText',
            fontWeight: FontWeight.bold,
            fontSize: 21,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1F1F1F) : const Color(0xFFD3D3D3),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:
              isDark ? const Color(0xFF1F1F1F) : const Color(0xFFD3D3D3),
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/image/logo/whale.png", scale: 5),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context).youDontHaveAnyNotifications,
                    style: TextStyle(
                      fontFamily: 'SFProText',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  title: Text(
                    n.title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SFProText',
                    ),
                  ),
                  subtitle: Text(
                    n.description,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontFamily: 'SFProText',
                    ),
                  ),
                  trailing: !n.isRead
                      ? const Icon(Icons.fiber_new, color: Colors.red)
                      : null,
                  onTap: () async {
                    await notificationProvider.markAsRead(n.id);
                    // Можно добавить переход, если есть boardId и нужен deep link
                  },
                );
              },
            ),
    );
  }
}

// class NotificationPage extends StatelessWidget {
//   final String userId;

//   const NotificationPage({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<NotificationProvider>(
//       builder: (context, provider, _) {
//         final notifications = provider.notifications;

//         return Scaffold(
//           appBar: AppBar(title: const Text("Уведомления")),
//           body: ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final note = notifications[index];
//               return ListTile(
//                 title: Text(note.title),
//                 subtitle: Text(note.description),
//                 trailing: note.isRead ? null : const Icon(Icons.fiber_new),
//                 onTap: () {
//                   provider.markAsRead(note.id);
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
