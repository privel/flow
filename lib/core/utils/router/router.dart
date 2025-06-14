import 'package:flow/core/utils/on_boarding_service/on_boarding.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/router/router_transitions.dart';
import 'package:flow/presentation/pages/auth_page/forgot_page/forgot.dart';
import 'package:flow/presentation/pages/auth_page/login_page/login.dart';
import 'package:flow/presentation/pages/auth_page/register_page/register.dart';
import 'package:flow/presentation/pages/auth_page/verif_page/verification.dart';
import 'package:flow/presentation/pages/board_page/board.dart';
import 'package:flow/presentation/pages/home_page/home.dart';
import 'package:flow/presentation/pages/account_page/account.dart';
import 'package:flow/presentation/pages/invite_join_page/Invite_page.dart';
import 'package:flow/presentation/pages/notification_page/notification.dart';
import 'package:flow/presentation/pages/task_page/photo_page.dart';
import 'package:flow/presentation/pages/task_page/task.dart';
import 'package:flow/presentation/pages/welcome_page/welcome.dart';
import 'package:flow/presentation/pages/board_page/new_board_after_test/other_test.dart';
import 'package:flow/presentation/test/test.dart';
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
        '/auth/register',
        '/invite',
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
            path: '/account',
            builder: (context, state) => const AccountPage(),
          ),
          GoRoute(
            path: '/notification',
            builder: (context, state) => const NotificationPage(),
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

      GoRoute(
        path: '/board/:id',
        name: 'board',
        builder: (context, state) {
          final boardId = state.pathParameters['id']!;
          return BoardPage(boardId: boardId);
        },
      ),
      //Убрал для теста просмотра картинок
      // GoRoute(
      //   path: '/board/:boardId/card/:cardId/task/:taskId',
      //   builder: (context, state) => TaskDetailPage(
      //     boardId: state.pathParameters['boardId']!,
      //     cardId: state.pathParameters['cardId']!,
      //     taskId: state.pathParameters['taskId']!,
      //   ),
      // ),

      GoRoute(
        path: '/boardtest/:id',
        name: 'boardtest',
        builder: (context, state) {
          final boardId = state.pathParameters['id']!;
          return BoardPaget(boardId: boardId);
        },
      ),

      GoRoute(
        path: '/boardtest2/:id',
        name: 'boardtest2',
        builder: (context, state) {
          final boardId = state.pathParameters['id']!;
          return BoardTest2(boardId: boardId);
        },
      ),

      GoRoute(
        path: '/invite/:inviteId',
        builder: (context, state) {
          final inviteId = state.pathParameters['inviteId']!;
          return InviteJoinPage(inviteId: inviteId);
        },
      ),
      GoRoute(
        path: "/test/color",
        builder: (context, state) => const Text("Test"),
      ),

      GoRoute(
        path: '/board/:boardId/card/:cardId/task/:taskId',
        builder: (context, state) => TaskDetailPage(
          boardId: state.pathParameters['boardId']!,
          cardId: state.pathParameters['cardId']!,
          taskId: state.pathParameters['taskId']!,
        ),
        routes: [
          // Новый вложенный маршрут для просмотра изображений
          GoRoute(
            path:
                'view-images', // Полный путь будет /board/:boardId/card/:cardId/task/:taskId/view-images
            builder: (context, state) {
              final List<Map<String, dynamic>> images =
                  state.extra as List<Map<String, dynamic>>;
              final int initialIndex =
                  state.uri.queryParameters['initialIndex'] != null
                      ? int.parse(state.uri.queryParameters['initialIndex']!)
                      : 0;

              return ImageViewerPage(
                images: images,
                initialIndex: initialIndex,
              );
            },
          ),
        ],
      ),
    ],
  );
}
