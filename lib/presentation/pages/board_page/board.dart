import 'package:flutter/material.dart';

class BoardPage extends StatelessWidget {
  final String boardId;

  const BoardPage({super.key, required this.boardId});

  @override
  Widget build(BuildContext context) {
    // Тут можно получить задачи по boardId через Provider или FutureBuilder
    return Scaffold(
      appBar: AppBar(
        title: Text('Доска $boardId'),
      ),
      body: Center(
        child: Text('Здесь будут задачи доски с id: $boardId'),
      ),
    );
  }
}
