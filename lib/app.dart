/*ColorScheme.dark(
  primary: ...,             // основной цвет (кнопки, активные элементы)
  onPrimary: ...,           // цвет текста на primary
  secondary: ...,           // дополнительный цвет (менее важные кнопки)
  onSecondary: ...,         // текст на secondary
  surface: ...,             // фон карточек, bottom sheets и т.д.
  onSurface: ...,           // текст на surface
  background: ...,          // основной фон
  onBackground: ...,        // текст на background
  error: ...,               // цвет ошибки
  onError: ...,             // текст ошибки
  brightness: Brightness.dark, // обязательно!
)



final isDark = Theme.of(context).brightness == Brightness.dark;

Container(
  color: isDark ? Colors.black : Colors.white,
  child: Text(
    'Пример',
    style: TextStyle(
      color: isDark ? Colors.white : Colors.black,
    ),
  ),
);


 */

import 'package:flow/core/theme/app_ext.dart';
import 'package:flow/core/utils/provider/local_provider.dart';
import 'package:flow/core/utils/provider/theme_provider.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flow/core/theme/app_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp.router(
      title: 'Flow',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // themeMode: ThemeMode.system,
      themeMode: themeProvider.themeMode,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 599, name: MOBILE),
          const Breakpoint(start: 600, end: 1023, name: TABLET),
          // const Breakpoint(start: 1024, end: 1439, name: DESKTOP),
          const Breakpoint(start: 1024, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.light.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.light.primary,
          onPrimary: AppColors.light.onPrimary,
          background: AppColors.light.background,
          surface: AppColors.light.surface,
          secondary: AppColors.light.secondaryText,
          onSurface: AppColors.light.onSurface,
        ),
        cardColor: AppColors.light.surface,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: AppColors.light.text),
          bodySmall: TextStyle(color: AppColors.light.secondaryText),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.light.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: AppColors.light.secondaryText),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.light.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent, // ⬅️ ключ!
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.light.bottomNavBar,
        ),
        extensions: const <ThemeExtension<dynamic>>[
          AppColorsExtension(
            mainText: Colors.black,
            subText: Colors.black54,
          ),
        ],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.dark.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.dark.primary,
          onPrimary: AppColors.dark.onPrimary,
          background: AppColors.dark.background,
          surface: AppColors.dark.surface,
          secondary: AppColors.dark.secondaryText,
          onSurface: AppColors.dark.onSurface,
        ),
        cardColor: AppColors.dark.surface,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: AppColors.dark.text),
          bodySmall: TextStyle(color: AppColors.dark.secondaryText),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.dark.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: AppColors.dark.secondaryText),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dark.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent, // ⬅️ ключ!
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppColors.dark.bottomNavBar),
        extensions: const <ThemeExtension<dynamic>>[
          AppColorsExtension(
            mainText: Colors.white,
            subText: Colors.white54,
          ),
        ],
      ),

      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      
      locale: locale,
    );
  }
}
