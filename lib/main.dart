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
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app.dart';

//App Check Android:  keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias

void main() async {
  Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
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

  final authProvider = AuthProvider();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // handleIncomingLinks();

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
