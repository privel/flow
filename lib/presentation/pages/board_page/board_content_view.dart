import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BoardContentView extends StatefulWidget {
  final BoardModel board;
  const BoardContentView({super.key, required this.board});

  @override
  State<BoardContentView> createState() => _BoardContentViewState();
}

class _BoardContentViewState extends State<BoardContentView> {
  bool _isMinimized = false;

  @override
  Widget build(BuildContext context) {
    final board = widget.board;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: board.color,
      appBar: AppBar(title: Text(board.title)),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 100),
              child: IntrinsicHeight(
                child: AnimatedScale(
                  scale: _isMinimized ? 0.8 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: board.cards.entries.map((entry) {
                      final card = entry.value;
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(card.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_task),
                                  onPressed: () async {
                                    final newTaskId =
                                        FirebaseFirestore.instance
                                            .collection('dummy')
                                            .doc()
                                            .id;

                                    await boardProvider.addTaskToCard(
                                      board.id,
                                      entry.key,
                                      TaskModel(
                                        id: newTaskId,
                                        title: 'Новая задача',
                                        description: 'Описание задачи',
                                        isDone: false,
                                      ),
                                    );

                                    setState(() => _isMinimized = false); // ❗сброс
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: 100, maxHeight: size.height * 0.6),
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: card.tasks.entries.map((taskEntry) {
                                      final task = taskEntry.value;
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: ListTile(
                                          title: Text(task.title),
                                          subtitle: Text(task.description),
                                          onTap: () {
                                            context.push(
                                              '/board/${board.id}/card/${entry.key}/task/${taskEntry.key}',
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isMinimized = !_isMinimized;
          });
        },
        child:
            Icon(_isMinimized ? Icons.fullscreen : Icons.fullscreen_exit),
      ),
    );
  }
}
