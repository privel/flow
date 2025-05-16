import 'package:firebase_core/firebase_core.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/local_provider.dart';
import 'package:flow/core/utils/provider/theme_provider.dart';
import 'package:flow/core/utils/router/router.dart';
import 'package:flow/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authProvider = AuthProvider();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
        ),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),

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
