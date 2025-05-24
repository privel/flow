// import 'package:cloud_firestore/cloud_firestore.dart'; // Был закомментирован, но нужен для FirebaseFirestore.instance
import 'package:cloud_firestore/cloud_firestore.dart'; // Убедись, что этот импорт есть
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kanban_board/kanban_board.dart';
import 'package:provider/provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flow/data/models/card_model.dart';
import 'package:flow/core/utils/provider/board_provider.dart';

class BoardPaget extends StatefulWidget {
  final String boardId;
  const BoardPaget({super.key, required this.boardId});

  @override
  State<BoardPaget> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPaget> {
  // Изменение здесь: _controller будет инициализирован в initState
  late final KanbanBoardController _controller;

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Инициализируем здесь
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    _controller = KanbanBoardController();
  }

  void _showAddTaskDialog(String cardId) {
    _selectedCardId = cardId;
    _taskController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новая задача'),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Введите название задачи'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _taskController.text.trim();
              if (title.isNotEmpty && _selectedCardId != null) {
                final boardProvider =
                    Provider.of<BoardProvider>(context, listen: false);
                final board = await boardProvider.getBoardById(widget.boardId);
                final card = board?.cards[_selectedCardId!];

                if (card == null) return;

                final order = card.tasks.length;
                final newTaskId = FirebaseFirestore.instance
                    .collection('dummy') // Используется для генерации ID
                    .doc()
                    .id;
                final task = TaskModel(
                  id: newTaskId,
                  title: title,
                  description: '',
                  isDone: false,
                  order: order,
                );
                await boardProvider.addTaskToCard(
                    widget.boardId, _selectedCardId!, task);
                _taskController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    _cardController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новая колонка'),
        content: TextField(
          controller: _cardController,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Введите название колонки'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _cardController.text.trim();
              if (title.isNotEmpty) {
                final boardProvider =
                    Provider.of<BoardProvider>(context, listen: false);
                final board = await boardProvider.getBoardById(widget.boardId);

                if (board == null) return;

                final order = board.cards.length;
                final newCardId = FirebaseFirestore.instance
                    .collection('dummy') // Используется для генерации ID
                    .doc()
                    .id;

                final newCard = CardModel(
                  id: newCardId,
                  title: title,
                  tasks: {},
                  order: order,
                );

                await boardProvider.addCardToBoard(widget.boardId, newCard);
                _cardController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Создать колонку'),
          ),
        ],
      ),
    );
  }

  void _showRenameCardDialog(String cardId, String currentTitle) {
    final TextEditingController renameController =
        TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Переименовать колонку'),
        content: TextField(
          controller: renameController,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = renameController.text.trim();
              if (newTitle.isNotEmpty) {
                await Provider.of<BoardProvider>(context, listen: false)
                    .renameCard(widget.boardId, cardId, newTitle);
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    _cardController.dispose();
    _scrollController
        .dispose(); // _scrollController теперь используется в _controller
    // Если KanbanBoardController имел бы метод dispose, его нужно было бы вызвать:
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        // ... (appBar code unchanged) ...
        title: StreamBuilder<BoardModel?>(
            stream: boardProvider.watchBoardById(widget.boardId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Text(snapshot.data!.title,
                    overflow: TextOverflow.ellipsis);
              }
              return const Text('Канбан-доска');
            }),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement board options (e.g., rename board, delete board)
            },
          ),
          IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ],
      ),
      body: StreamBuilder<BoardModel?>(
        stream: boardProvider.watchBoardById(widget.boardId),
        builder: (context, snapshot) {
          // ... (snapshot handling unchanged) ...
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text('Доска не найдена или нет данных.'));
          }

          final board = snapshot.data!;
          final cardEntries = board.cards.entries.toList()
            ..sort((a, b) => a.value.order.compareTo(b.value.order));

          final kanbanGroups = cardEntries.map((entry) {
            // ... (kanbanGroups mapping unchanged) ...
            final cardId = entry.key;
            final card = entry.value;

            final taskItems = card.tasks.entries.toList()
              ..sort((a, b) => (a.value.order).compareTo(b.value.order));

            return KanbanBoardGroup<String, _KanbanTaskItem>(
              id: cardId,
              name: card.title,
              items: taskItems
                  .map((e) =>
                      _KanbanTaskItem(taskId: e.key, title: e.value.title))
                  .toList(),
            );
          }).toList();

          return ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 2000,
            ),
            child: KanbanBoard(
              controller:
                  _controller, // Передаем корректно инициализированный контроллер
              groups: kanbanGroups,
              groupHeaderBuilder: (context, groupId) {
                // ... (groupHeaderBuilder unchanged) ...
                final card = board.cards[groupId]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _showRenameCardDialog(groupId, card.title),
                          child: Text(
                            card.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: "Добавить задачу",
                        onPressed: () => _showAddTaskDialog(groupId),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              },
              groupItemBuilder: (context, groupId, itemIndex) {
                // ... (groupItemBuilder unchanged up to task definition) ...
                final sortedTasks = board.cards[groupId]!.tasks.values.toList()
                  ..sort((a, b) => a.order.compareTo(b.order));

                if (itemIndex >= sortedTasks.length) {
                  return const SizedBox.shrink();
                }

                final task = sortedTasks[itemIndex];

                return Dismissible(
                  key: Key(task.id),
                  // ... (Dismissible properties unchanged) ...
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  // onDismissed: (_) async {
                  //   // ... (onDismissed logic unchanged) ...
                  //   await boardProvider.removeTaskFromCard(
                  //       widget.boardId, groupId, task.id);
                  //   final currentBoard =
                  //       await boardProvider.getBoardById(widget.boardId);
                  //   if (currentBoard == null) return;
                  //   final targetCard = currentBoard.cards[groupId];
                  //   if (targetCard == null) return;

                  //   final remainingTasks = targetCard.tasks.values.toList()
                  //     ..removeWhere((t) => t.id == task.id)
                  //     ..sort((a, b) => a.order.compareTo(b.order));

                  //   for (int i = 0; i < remainingTasks.length; i++) {
                  //     remainingTasks[i] = remainingTasks[i].copyWith(order: i);
                  //   }
                  //   final updatedCard = targetCard.copyWith(
                  //       tasks: {for (var t in remainingTasks) t.id: t});
                  //   final updatedCardsMap =
                  //       Map<String, CardModel>.from(currentBoard.cards);
                  //   updatedCardsMap[groupId] = updatedCard;
                  //   await boardProvider.updateBoard(
                  //       currentBoard.copyWith(cards: updatedCardsMap));
                  // },
                  onDismissed: (_) async {
                    // 1. Получаем актуальное состояние доски ПЕРЕД изменениями
                    final boardBeforeDismiss =
                        await boardProvider.getBoardById(widget.boardId);
                    if (boardBeforeDismiss == null) {
                      debugPrint("Board not found, cannot dismiss task.");
                      return;
                    }

                    CardModel? cardToUpdate = boardBeforeDismiss.cards[groupId];
                    if (cardToUpdate == null) {
                      debugPrint(
                          "Card not found in board, cannot dismiss task.");
                      return;
                    }

                    // 2. Создаем новую карту задач для изменяемой колонки, удаляя нужную задачу
                    Map<String, TaskModel> newTasksMapForCard =
                        Map.from(cardToUpdate.tasks);
                    newTasksMapForCard.remove(task
                        .id); // task.id здесь от той задачи, которую смахнули

                    // 3. Переупорядочиваем оставшиеся задачи
                    List<TaskModel> remainingTasksList = newTasksMapForCard
                        .values
                        .toList()
                      ..sort((a, b) => a.order.compareTo(b
                          .order)); // Сортируем по старому order на всякий случай

                    Map<String, TaskModel> reorderedTasks = {};
                    for (int i = 0; i < remainingTasksList.length; i++) {
                      final reorderedTask =
                          remainingTasksList[i].copyWith(order: i);
                      reorderedTasks[reorderedTask.id] = reorderedTask;
                    }

                    // 4. Создаем обновленную карточку (колонку) и обновленную доску
                    final updatedCard =
                        cardToUpdate.copyWith(tasks: reorderedTasks);

                    final updatedBoardCards =
                        Map<String, CardModel>.from(boardBeforeDismiss.cards);
                    updatedBoardCards[groupId] = updatedCard;

                    final boardToSave =
                        boardBeforeDismiss.copyWith(cards: updatedBoardCards);

                    // 5. Сохраняем всю обновленную доску в Firestore ОДНИМ вызовом updateBoard
                    await boardProvider.updateBoard(boardToSave);
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 2,
                    child: ListTile(
                        title: Text(task.title),
                        subtitle: Text("SAMPLE"),
                        onTap: () {/* TODO: Open task details */}),
                  ),
                );
              },
              onGroupItemMove: (oldGroupIndexNullable, oldItemIndexNullable,
                  newGroupIndexNullable, newItemIndexNullable) async {
                final oldGroupIndex = oldGroupIndexNullable!;
                final oldItemIndex = oldItemIndexNullable!;
                final newGroupIndex = newGroupIndexNullable!;
                final newItemIndex = newItemIndexNullable!;

                final currentBoard =
                    await boardProvider.getBoardById(widget.boardId);
                if (currentBoard == null) {
                  debugPrint("Board not found, cannot move task.");
                  return;
                }

                final sortedCardEntries = currentBoard.cards.entries.toList()
                  ..sort((a, b) => a.value.order.compareTo(b.value.order));

                if (oldGroupIndex >= sortedCardEntries.length ||
                    newGroupIndex >= sortedCardEntries.length) {
                  debugPrint(
                      "Error: Invalid group index provided by kanban_board package.");
                  return;
                }

                String sourceCardId = sortedCardEntries[oldGroupIndex].key;
                String targetCardId = sortedCardEntries[newGroupIndex].key;

                CardModel? sourceCard = currentBoard.cards[sourceCardId];
                CardModel? targetCard = currentBoard.cards[targetCardId];

                if (sourceCard == null || targetCard == null) {
                  debugPrint(
                      "Error: Source or target card not found in current board data.");
                  return;
                }

                List<TaskModel> sourceTasks = sourceCard.tasks.values.toList()
                  ..sort((a, b) => a.order.compareTo(b.order));

                // Важная проверка перед удалением
                // if (sourceTasks.isEmpty ||
                //     oldItemIndex < 0 ||
                //     oldItemIndex >= sourceTasks.length) {
                //   debugPrint(
                //       "Error: onGroupItemMove called with invalid index or empty source task list. "
                //       "oldItemIndex: $oldItemIndex, sourceTasks.length: ${sourceTasks.length}, sourceCardId: ${sourceCard.id}");
                //   return; // Предотвращаем креш
                // }

                if (sourceTasks.isEmpty ||
                    oldItemIndex < 0 ||
                    oldItemIndex >= sourceTasks.length) {
                  debugPrint(
                      "Error: onGroupItemMove called with invalid index or empty source task list. "
                      "oldItemIndex: $oldItemIndex, sourceTasks.length: ${sourceTasks.length}, sourceCardId: ${sourceCard.id}");
                  return;
                }
                TaskModel movedTask = sourceTasks.removeAt(oldItemIndex);

                Map<String, CardModel> updatedCardsMap =
                    Map.from(currentBoard.cards);

                if (sourceCardId == targetCardId) {
                  // Перемещение в той же карточке
                  // Убедимся, что newItemIndex не выходит за пределы для вставки
                  final insertAtIndex = (newItemIndex > sourceTasks.length)
                      ? sourceTasks.length
                      : newItemIndex;
                  sourceTasks.insert(insertAtIndex, movedTask);

                  for (int i = 0; i < sourceTasks.length; i++) {
                    sourceTasks[i] = sourceTasks[i].copyWith(order: i);
                  }
                  updatedCardsMap[sourceCardId] = sourceCard.copyWith(
                    tasks: {for (var task in sourceTasks) task.id: task},
                  );
                } else {
                  // Перемещение в другую карточку
                  // Обновить исходную карточку
                  for (int i = 0; i < sourceTasks.length; i++) {
                    sourceTasks[i] = sourceTasks[i].copyWith(order: i);
                  }
                  updatedCardsMap[sourceCardId] = sourceCard.copyWith(
                    tasks: {for (var task in sourceTasks) task.id: task},
                  );

                  // Обновить целевую карточку
                  List<TaskModel> targetTasks = targetCard.tasks.values.toList()
                    ..sort((a, b) => a.order.compareTo(b.order));

                  // Убедимся, что newItemIndex не выходит за пределы для вставки
                  final insertAtIndex = (newItemIndex > targetTasks.length)
                      ? targetTasks.length
                      : newItemIndex;
                  targetTasks.insert(insertAtIndex, movedTask);

                  for (int i = 0; i < targetTasks.length; i++) {
                    targetTasks[i] = targetTasks[i].copyWith(order: i);
                  }
                  updatedCardsMap[targetCardId] = targetCard.copyWith(
                    tasks: {for (var task in targetTasks) task.id: task},
                  );
                }
                await boardProvider
                    .updateBoard(currentBoard.copyWith(cards: updatedCardsMap));
              },
              onGroupMove: // (onGroupMove logic unchanged) ...
                  (oldGroupIndexNullable, newGroupIndexNullable) async {
                final oldGroupIndex = oldGroupIndexNullable!;
                final newGroupIndex = newGroupIndexNullable!;

                final currentBoard =
                    await boardProvider.getBoardById(widget.boardId);
                if (currentBoard == null) return;

                List<MapEntry<String, CardModel>> cardList =
                    currentBoard.cards.entries.toList()
                      ..sort((a, b) => a.value.order.compareTo(b.value.order));

                final movedCardEntry = cardList.removeAt(oldGroupIndex);
                cardList.insert(newGroupIndex, movedCardEntry);

                final reorderedCardsMap = <String, CardModel>{};
                for (int i = 0; i < cardList.length; i++) {
                  reorderedCardsMap[cardList[i].key] =
                      cardList[i].value.copyWith(order: i);
                }

                await boardProvider.updateBoard(
                    currentBoard.copyWith(cards: reorderedCardsMap));
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // ... (FAB unchanged) ...
        onPressed: _showAddCardDialog,
        tooltip: 'Добавить колонку',
        child: const Icon(Icons.add_to_photos_outlined),
      ),
    );
  }
}

class _KanbanTaskItem extends KanbanBoardGroupItem {
  // ... (_KanbanTaskItem unchanged) ...
  final String taskId;
  final String title;

  _KanbanTaskItem({required this.taskId, required this.title});

  @override
  String get id => taskId;
}
