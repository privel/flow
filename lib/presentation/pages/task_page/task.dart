import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/task_model.dart';

class TaskDetailPage extends StatefulWidget {
  final String boardId;
  final String cardId;
  final String taskId;

  const TaskDetailPage({super.key, required this.boardId, required this.cardId, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isDone = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadTaskData(TaskModel task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _isDone = task.isDone;
  }

  // Future<void> _saveTask(BoardProvider provider, int order) async {
  //   final updatedTask = TaskModel(
  //     id: widget.taskId,
  //     title: _titleController.text.trim(),
  //     description: _descriptionController.text.trim(),
  //     isDone: _isDone, 
  //   );

  //   await provider.updateTask(
  //     widget.boardId,
  //     widget.cardId,
  //     updatedTask,
  //   );

  //   if (!mounted) return;
  //   Navigator.pop(context);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Изменения сохранены')),
  //   );
  // }

  Future<void> _saveTask(BoardProvider provider, int order) async {
  final updatedTask = TaskModel(
    id: widget.taskId,
    title: _titleController.text.trim(),
    description: _descriptionController.text.trim(),
    isDone: _isDone,
    order: order,
  );

  await provider.updateTask(
    widget.boardId,
    widget.cardId,
    updatedTask,
  );

  if (!mounted) return;
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Изменения сохранены')),
  );
}


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoardProvider>(context, listen: false);

    return StreamBuilder(
      stream: provider.watchBoardById(widget.boardId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(body: Center(child: Text('Нет данных')));
        }

        final board = snapshot.data!;
        final card = board.cards[widget.cardId];
        final task = card?.tasks[widget.taskId];

        if (task == null) {
          return const Scaffold(body: Center(child: Text('Задача не найдена')));
        }

        _loadTaskData(task);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Редактирование задачи'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _saveTask(provider, task.order),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Название задачи'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Описание'),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Завершена'),
                  value: _isDone,
                  onChanged: (val) => setState(() => _isDone = val ?? false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
