import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/core/utils/provider/local_provider.dart';
import 'package:flow/core/utils/provider/notification_provider.dart';
import 'package:flow/core/utils/provider/theme_provider.dart';
import 'package:flow/core/utils/router/router.dart';
import 'package:flow/core/utils/supabase_service.dart';
import 'package:flow/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app.dart';

//App Check Android:  keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias

import 'dart:convert'; // Для jsonEncode/decode

// App Check Android: keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias

// ⚠️ Эта функция ДОЛЖНА БЫТЬ ФУНКЦИЕЙ ВЕРХНЕГО УРОВНЯ (вне main или любого класса)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Когда это вызывается, Firebase уже должен быть инициализирован
  // Не вызывайте Firebase.initializeApp() здесь повторно, если это не абсолютно необходимо для конкретных сервисов.
  // Для простого вывода в консоль не нужно.
  // Если у вас проблемы с Firebase в фоновом режиме, попробуйте раскомментировать:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('⚠️ BG message: ${message.messageId}');
  debugPrint('⚠️ BG message data: ${message.data}');

  // Если вы хотите показывать локальные уведомления для фоновых сообщений,
  // вам нужно будет инициализировать flutter_local_notifications здесь.
  // Обычно для фоновых сообщений достаточно того, что FCM сам отображает уведомление.
  // Однако, если уведомление не отображается автоматически, можете добавить:
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  // const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // flutterLocalNotificationsPlugin.show(
  //   message.hashCode,
  //   message.notification?.title,
  //   message.notification?.body,
  //   const NotificationDetails(
  //     android: AndroidNotificationDetails('flow_channel_id', 'Flow Notifications',
  //         channelDescription: 'Notifications from Flow app',
  //         importance: Importance.max, priority: Priority.high),
  //   ),
  //   payload: jsonEncode(message.data),
  // );
}

// Глобальный экземпляр для flutter_local_notifications (для сообщений в foreground)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint('⚠️ BG message: ${message.messageId}');
  }

  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        AndroidProvider.debug, // или  для билд версии playIntegrity
    webProvider:
        ReCaptchaV3Provider('6LcOWT0rAAAAAAsJEvF4SCJBIfymCREZSRABCwdB'),
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Замените на путь к вашей иконке

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Логика обработки нажатия на локальное уведомление
      debugPrint('onDidReceiveNotificationResponse: ${response.payload}');
      if (response.payload != null) {
        // final data = jsonDecode(response.payload!); // Раскомментируйте, если будете использовать payload
        // Здесь можно реализовать навигацию, например, используя GoRouter
        // if (data['type'] == 'invitation' && data['boardId'] != null) {
        //   GoRouter.of(globalNavigatorKey.currentContext!).go('/invite/${data['boardId']}');
        // }
      }
    },
  );

  final authProvider = AuthProvider();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // handleIncomingLinks();

  // Запрос разрешений на уведомления (особенно для iOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  debugPrint('User granted permission: ${settings.authorizationStatus}');

  // Получите FCM токен и сохраните его (как вы уже делаете)
  String? fcmToken = await messaging.getToken();
  debugPrint('FCM Token: $fcmToken');

  // Здесь должна быть ваша логика сохранения/обновления fcmToken
  // в документе пользователя в Firestore, как вы уже делаете в register.
  // Пример, как обновить токен для текущего пользователя:
  if (fcmToken != null && authProvider.user != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(authProvider.user!.uid)
        .set(
      {'message_token': fcmToken},
      SetOptions(merge: true),
    );
  }

  // Добавьте прослушивание обновления токена
  messaging.onTokenRefresh.listen((newToken) {
    debugPrint('New FCM Token: $newToken');
    // Здесь также обновите токен в вашей базе данных для текущего пользователя
    if (authProvider.user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .set(
        {'message_token': newToken},
        SetOptions(merge: true),
      );
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification}');

      flutterLocalNotificationsPlugin.show(
        message.hashCode, // Уникальный ID для каждого уведомления
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'flow_channel_id', // ID канала (должен быть уникальным)
            'Flow Notifications', // Имя канала
            channelDescription: 'Notifications from Flow app',
            importance: Importance.max, // Высокая важность
            priority: Priority.high,
            // Добавьте звуки, вибрации и т.д. по желанию
          ),
          // iOS специфичные настройки, если нужны
        ),
        payload: jsonEncode(
            message.data), // Передаем данные для обработки при нажатии
      );
    }
  });

  // Обработка сообщений, когда пользователь открывает приложение из уведомления
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('A new onMessageOpenedApp event was published!');
    debugPrint('Message data: ${message.data}');
    // Здесь вы можете навигировать пользователя на конкретный экран,
    // основываясь на данных уведомления (message.data).
    // Например:
    // if (message.data['type'] == 'invitation') {
    //   GoRouter.of(globalNavigatorKey.currentContext!).go('/invite/${message.data['boardId']}');
    // }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),

        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
        ),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<BoardProvider>(
          create: (_) => BoardProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        // 🔽 сюда добавляй другие Provider
        // ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // ChangeNotifierProvider(create: (_) => SomeOtherProvider()),
      ],
      child: MyApp(
        router: appRouter(authProvider),
      ),
    ),
  );
}

// void handleIncomingLinks() {
//   uriLinkStream.listen((Uri? uri) {
//     if (uri == null) return;

//     final pathSegments = uri.pathSegments;
//     if (pathSegments.isNotEmpty && pathSegments[0] == 'invite') {
//       final inviteId = pathSegments.length > 1 ? pathSegments[1] : null;
//       if (inviteId != null) {
//         GoRouter.of(globalNavigatorKey.currentContext!).go('/invite/$inviteId');
//       }
//     }
//   }, onError: (err) {
//     print('Ошибка при обработке ссылки: $err');
//   });
// }
