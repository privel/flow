import 'package:flow/core/theme/app_ext.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/core/utils/provider/notification_provider.dart';
import 'package:flow/data/models/notification_model.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/pages/account_page/account_layout.dart';
import 'package:flow/presentation/widgets/history_widget.dart';
import 'package:flow/presentation/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Stream<List<NotificationModel>> _notificationStream;

  /// Шаг 1: Изменим Stream для фильтрации
  late Stream<List<NotificationModel>> _activeNotificationsStream;
  late Stream<List<NotificationModel>> _historyNotificationsStream;

  @override
  void initState() {
    super.initState();
    final userId =
        Provider.of<AuthProvider>(context, listen: false).user?.uid ?? '';
    final provider = Provider.of<NotificationProvider>(context, listen: false);

    _activeNotificationsStream = provider
        .watchNotifications(userId)
        .map((list) => list.where((n) => n.action == null).toList());

    _historyNotificationsStream = provider
        .watchNotifications(userId)
        .map((list) => list.where((n) => n.action != null).toList());

    _notificationStream = provider.watchNotifications(userId);
  }
  // @override
  // void initState() {
  //   super.initState();
  //   final userId = Provider.of<AuthProvider>(context, listen: false).user?.uid ?? '';
  //   final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
  //   _notificationStream = notificationProvider.watchNotifications(userId);
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final auth = Provider.of<AuthProvider>(context, listen: false);
  //     final notificationProvider =
  //         Provider.of<NotificationProvider>(context, listen: false);
  //     final userId = auth.user?.uid ?? '';
  //     if (userId.isNotEmpty) {
  //       notificationProvider.loadNotifications(userId);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userId = context.read<AuthProvider>().user?.uid ?? '';
    final notificationProvider = context.read<NotificationProvider>();
    final boardProvider = context.read<BoardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).notification,
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              radius: 20,
              onTapDown: (TapDownDetails details) async {
                final tapPosition = details.globalPosition;

                final value = await showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    tapPosition.dx,
                    tapPosition.dy + 10,
                    tapPosition.dx,
                    tapPosition.dy,
                  ),
                  items: [
                    PopupMenuItem(
                      value: 'history',
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SizedBox(
                        height: 36,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).notificationHistory,
                              style: AccountLayout.CardSubTitle.copyWith(
                                color: Theme.of(context)
                                    .extension<AppColorsExtension>()
                                    ?.mainText,
                              ),
                            ),
                            const Icon(Icons.history_rounded),
                          ],
                        ),
                      ),
                    ),
                    const PopupMenuItem(
                      enabled: false,
                      height: 1,
                      padding: EdgeInsets.zero,
                      child: Divider(
                        thickness: 0.4,
                        height: 1,
                        color: Colors.grey,
                        indent: 5,
                        endIndent: 5,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'read',
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SizedBox(
                        height: 36,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).readAll,
                              style: AccountLayout.CardSubTitle.copyWith(
                                color: Theme.of(context)
                                    .extension<AppColorsExtension>()
                                    ?.mainText,
                              ),
                            ),
                            const Icon(Icons.mark_chat_read_outlined),
                          ],
                        ),
                      ),
                    ),
                  ],
                );

                if (value == 'history') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (BuildContext context) {
                      return DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.8,
                        minChildSize: 0.3,
                        maxChildSize: 0.9,
                        builder: (context, scrollController) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: HistoryNotificationSheet(
                              stream: _historyNotificationsStream,
                              scrollController: scrollController,
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (value == 'read') {
                  await context
                      .read<NotificationProvider>()
                      .markAllAsRead(userId);
                  SnackBarHelper.show(context, S.of(context).markedAllAsRead,
                      type: SnackType.success);
                }
              },
              child: Icon(
                Icons.more_horiz_rounded,
                color: isDark ? Colors.white : const Color(0xFF1F1F1F),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: StreamBuilder<List<NotificationModel>>(
          // stream: _notificationStream,
          stream: _activeNotificationsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/image/whaleGreen.png", scale: 5),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).youDontHaveAnyNotifications,
                      style: TextStyle(
                        fontFamily: 'SFProText',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
              ),
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];

                  if (n.type == 'invitation') {
                    Widget trailingWidget;

                    if (n.action == 'accepted') {
                      trailingWidget =
                          const Icon(Icons.check_circle, color: Colors.green);
                    } else if (n.action == 'declined') {
                      trailingWidget =
                          const Icon(Icons.cancel, color: Colors.red);
                    } else {
                      trailingWidget = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await boardProvider.acceptInvite(
                                  n.metadata?['boardId'], userId);
                              await notificationProvider.setNotificationAction(
                                  n.id, 'accepted');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await notificationProvider.setNotificationAction(
                                  n.id, 'declined');
                            },
                          ),
                        ],
                      );
                    }

                    return buildNotificationTile(
                        n.title, n.description, trailingWidget, isDark);
                  }

                  return buildNotificationTile(
                    n.title,
                    n.description,
                    !n.isRead
                        ? const Icon(Icons.fiber_new, color: Colors.red)
                        : null,
                    isDark,
                    onTap: () async {
                      await notificationProvider.markAsRead(n.id);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildPopupItem(BuildContext context, String text, IconData icon) {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: AccountLayout.CardSubTitle.copyWith(
              color:
                  Theme.of(context).extension<AppColorsExtension>()?.mainText,
            ),
          ),
          Icon(icon),
        ],
      ),
    );
  }

  Widget buildNotificationTile(
      String title, String description, Widget? trailing, bool isDark,
      {VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
          fontFamily: 'SFProText',
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontFamily: 'SFProText',
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
