import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class InviteJoinPage extends StatefulWidget {
  final String inviteId;
  const InviteJoinPage({super.key, required this.inviteId});

  @override
  State<InviteJoinPage> createState() => _InviteJoinPageState();
}

class _InviteJoinPageState extends State<InviteJoinPage> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return FutureBuilder(
      future: userId != null
          ? boardProvider.joinBoardByInviteId(widget.inviteId, userId)
          : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
              body: Center(child: Text('Неверная или просроченная ссылка')));
        }

        final board = snapshot.data!;

        if (!_navigated) {
          _navigated = true;
          Future.microtask(() {
            context.go('/board/${board.id}');
          });
        }

        return const Scaffold(); // Пусто, тк переход
      },
    );
  }
}
