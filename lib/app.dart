import 'package:flutter/material.dart';
import 'package:flow/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flow',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: ThemeMode.system, 
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
          background: AppColors.light.background,
          surface: AppColors.light.surface,
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
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.dark.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.dark.primary,
          background: AppColors.dark.background,
          surface: AppColors.dark.surface,
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
      ),
      
    );
  }
}
