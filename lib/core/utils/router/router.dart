import 'package:flow/core/utils/on_boarding_service/on_boarding.dart';
import 'package:flow/core/utils/provider/auth_provider/auth_provider.dart';
import 'package:flow/core/utils/router/router_transitions.dart';
import 'package:flow/presentation/pages/auth_page/forgot_page/forgot.dart';
import 'package:flow/presentation/pages/auth_page/login_page/login.dart';
import 'package:flow/presentation/pages/auth_page/register_page/register.dart';
import 'package:flow/presentation/pages/auth_page/verif_page/verification.dart';
import 'package:flow/presentation/pages/home_page/home.dart';
import 'package:flow/presentation/pages/welcome_page/welcome.dart';
import 'package:flow/presentation/widgets/header/responsive_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

GoRouter appRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) async {
      final isLoggedIn = authProvider.isLoggedIn;
      final isEmailVerified = authProvider.isEmailVerified;
      // Разрешаем доступ к forgot-password и register даже неавторизованным
      final allowedUnauthenticatedPaths = [
        '/auth/forgot-password',
        '/auth/register'
      ];

      if (!isLoggedIn &&
          !allowedUnauthenticatedPaths.contains(state.fullPath)) {
        return '/auth/login';
      }

      if (isLoggedIn &&
          !isEmailVerified &&
          !['/auth/verify-email', '/auth/login', '/auth/register']
              .contains(state.fullPath)) {
        return '/auth/verify-email';
      }

      return null;
    },
    routes: [
      /// ✅ Оболочка с ResponsiveLayout
      ShellRoute(
        builder: (context, state, child) {
          return ResponsiveLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const Center(child: Text('Настройки')),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Center(child: Text('Профиль')),
          ),
        ],
      ),

      // 🔒 Отдельные маршруты без оболочки
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/verify-email',
        builder: (context, state) => const VerificationPage(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
    ],
  );
}
