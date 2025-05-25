import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow/core/theme/app_ext.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Size size;
  final List<BoardModel> boards;

  const AddTaskBottomSheet({
    required this.scrollController,
    required this.size,
    required this.boards,
    super.key,
  });

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  String? selectedBoardId;
  String? selectedCardId;
  String taskTitle = '';

  bool isChoose = false;
  bool isBoard = true;

  Widget ChooseBoard(BuildContext context, selectedCards, bool isBoard) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.close,
                  color: Theme.of(context)
                      .extension<AppColorsExtension>()
                      ?.mainText),
              onPressed: () {
                setState(() {
                  isChoose = false;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              children: [
                Text("Hello From Choose ${isBoard ? "Board" : "Card"}"),
                SizedBox(height: widget.size.height * 0.03),
                DropdownButton<String>(
                  hint: const Text("Выберите доску"),
                  value: selectedBoardId,
                  isExpanded: true,
                  items: widget.boards.map((board) {
                    return DropdownMenuItem(
                      value: board.id,
                      child: Text(board.title),
                    );
                  }).toList(),
                  onChanged: (boardId) {
                    setState(() {
                      selectedBoardId = boardId;
                      selectedCardId = null;
                    });
                  },
                ),
                const SizedBox(height: 10),
                if (selectedBoardId != null)
                  DropdownButton<String>(
                    hint: const Text("Выберите карточку"),
                    value: selectedCardId,
                    isExpanded: true,
                    items: selectedCards.map((card) {
                      return DropdownMenuItem(
                        value: card.id,
                        child: Text(card.title),
                      );
                    }).toList(),
                    onChanged: (cardId) {
                      setState(() => selectedCardId = cardId);
                    },
                  ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Введите название задачи',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => taskTitle = value,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedBoard = widget.boards.firstWhere(
        (b) => b.id == selectedBoardId,
        orElse: () => BoardModel.empty());

    final selectedCards = selectedBoard.cards.values.toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.close,
                  color: Theme.of(context)
                      .extension<AppColorsExtension>()
                      ?.mainText),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              onPressed: () async {
                if (selectedBoardId != null &&
                    selectedCardId != null &&
                    taskTitle.isNotEmpty) {
                  try {
                    final boardProvider = context.read<BoardProvider>();
                    final selectedBoard = widget.boards
                        .firstWhere((b) => b.id == selectedBoardId);
                    final selectedCard = selectedBoard.cards[selectedCardId];
                    final taskCount = selectedCard?.tasks.length ?? 0;

                    final task = TaskModel(
                      id: FirebaseFirestore.instance
                          .collection('dummy')
                          .doc()
                          .id,
                      title: taskTitle,
                      description: '',
                      isDone: false,
                      order: taskCount + 1,
                    );

                    await boardProvider.addTaskToCard(
                      selectedBoardId!,
                      selectedCardId!,
                      task,
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    debugPrint('Ошибка при добавлении задачи: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Не удалось добавить задачу')),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).save,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              children: [
                SizedBox(height: widget.size.height * 0.03),
               
                DropdownButton<String>(
                  hint: const Text("Выберите доску"),
                  value: selectedBoardId,
                  isExpanded: true,
                  items: widget.boards.map((board) {
                    return DropdownMenuItem(
                      value: board.id,
                      child: Text(board.title),
                    );
                  }).toList(),
                  onChanged: (boardId) {
                    setState(() {
                      selectedBoardId = boardId;
                      selectedCardId = null;
                    });
                  },
                ),
                const SizedBox(height: 10),
                if (selectedBoardId != null)
                  DropdownButton<String>(
                    hint: const Text("Выберите карточку"),
                    value: selectedCardId,
                    isExpanded: true,
                    items: selectedCards.map((card) {
                      return DropdownMenuItem(
                        value: card.id,
                        child: Text(card.title),
                      );
                    }).toList(),
                    onChanged: (cardId) {
                      setState(() => selectedCardId = cardId);
                    },
                  ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Введите название задачи',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => taskTitle = value,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
