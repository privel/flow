import 'package:flow/core/theme/app_ext.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/pages/account_page/account_layout.dart';
import 'package:flow/presentation/widgets/list_modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:appflowy_board/appflowy_board.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/card_model.dart' as flow; // Псевдоним
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:uuid/uuid.dart';

class FlowTaskItem extends AppFlowyGroupItem {
  final TaskModel task;

  FlowTaskItem(this.task);

  @override
  String get id => task.id;

  String get title => task.title;
  String get description => task.description;
  bool get isDone => task.isDone;
}

class AppFlowyBoardWidget extends StatefulWidget {
  final BoardModel boardModel;

  const AppFlowyBoardWidget({super.key, required this.boardModel});

  @override
  State<AppFlowyBoardWidget> createState() => _AppFlowyBoardWidgetState();
}

class _AppFlowyBoardWidgetState extends State<AppFlowyBoardWidget> {
  late AppFlowyBoardController controller;
  late BoardProvider boardProvider;
  final Uuid _uuid = const Uuid();
  late AuthProvider auth;
  late String? userId;
  String? userRole;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    boardProvider = Provider.of<BoardProvider>(context, listen: false);
    controller = _createBoardController(widget.boardModel);

    userId = auth.user?.uid;
    userRole =
        boardProvider.getUserRole(widget.boardModel, auth.user?.uid ?? '');
  }

  @override
  void didUpdateWidget(covariant AppFlowyBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.boardModel != oldWidget.boardModel) {
      controller.dispose();
      controller = _createBoardController(widget.boardModel);
    }
  }

  // AppFlowyBoardController _createBoardController(BoardModel board) {
  //   final newController = AppFlowyBoardController(
  //     onMoveGroup: (dynamic p1, dynamic p2, dynamic p3, dynamic p4) {
  //       // Выводим реальные типы параметров, которые передает библиотека
  //       debugPrint('onMoveGroup callback params runtimeTypes:');
  //       debugPrint(
  //           'p1: ${p1.runtimeType}, p2: ${p2.runtimeType}, p3: ${p3.runtimeType}, p4: ${p4.runtimeType}');
  //       debugPrint(
  //           'p1 value: $p1, p2 value: $p2, p3 value: $p3, p4 value: $p4');

  //       // Пытаемся извлечь ID и индексы
  //       // Предполагаем, что p1 - это ID или объект перемещаемой группы,
  //       // p2 - ее старый индекс (int),
  //       // p3 - ID или объект целевой группы/контекста (может быть таким же, как p1),
  //       // p4 - новый индекс (int).
  //       String? fromGroupId;
  //       int? fromIndex;
  //       String?
  //           toGroupId; // Может не использоваться, если p4 - абсолютный индекс
  //       int? toIndex;

  //       if (p1 is String) {
  //         fromGroupId = p1;
  //       } else if (p1 is AppFlowyGroupData) {
  //         fromGroupId = p1.id;
  //       } else if (p1 is flow.CardModel) {
  //         // На случай если библиотека передает наш CardModel
  //         fromGroupId = p1.id;
  //       }

  //       if (p2 is int) fromIndex = p2;

  //       if (p3 is String) {
  //         toGroupId = p3;
  //       } else if (p3 is AppFlowyGroupData) {
  //         toGroupId = p3.id;
  //       } else if (p3 is flow.CardModel) {
  //         toGroupId = p3.id;
  //       }

  //       if (p4 is int) toIndex = p4;

  //       if (fromGroupId != null && fromIndex != null && toIndex != null) {
  //         // toGroupId может быть не нужен, если toIndex - это новый абсолютный индекс fromGroupId
  //         _handleMoveGroup(
  //             fromGroupId, fromIndex, toGroupId ?? fromGroupId, toIndex);
  //       } else {
  //         debugPrint('onMoveGroup: Could not determine correct parameters.');
  //       }
  //     },
  //     onMoveGroupItem: (String groupId, int itemFromIndex, int itemToIndex) {
  //       _handleMoveGroupItem(groupId, itemFromIndex, itemToIndex);
  //     },
  //     onMoveGroupItemToGroup:
  //         (String fromGroupId, int fromIndex, String toGroupId, int toIndex) {
  //       _handleMoveGroupItemToGroup(fromGroupId, fromIndex, toGroupId, toIndex);
  //     },
  //   );

  //   final sortedCards = board.cards.values.toList()
  //     ..sort((a, b) => a.order.compareTo(b.order));

  //   for (final cardModel in sortedCards) {
  //     final sortedTasks = cardModel.tasks.values.toList()
  //       ..sort((a, b) => a.order.compareTo(b.order));

  //     final group = AppFlowyGroupData(
  //       id: cardModel.id,
  //       name: cardModel.title,
  //       items: sortedTasks.map((task) => FlowTaskItem(task)).toList(),
  //     );
  //     newController.addGroup(group);
  //   }
  //   return newController;
  // }

//NEW

  AppFlowyBoardController _createBoardController(BoardModel board) {
    final newController = AppFlowyBoardController(
      onMoveGroup: (dynamic p1, dynamic p2, dynamic p3, dynamic p4) {
        String? fromGroupId;
        int? fromIndex;
        String? toGroupId;
        int? toIndex;

        if (p1 is String) fromGroupId = p1;
        if (p2 is int) fromIndex = p2;
        if (p3 is String) toGroupId = p3;
        if (p4 is int) toIndex = p4;

        if (fromGroupId != null && fromIndex != null && toIndex != null) {
          _handleMoveGroup(
              fromGroupId, fromIndex, toGroupId ?? fromGroupId, toIndex);
        }
      },
      onMoveGroupItem: (String groupId, int fromIndex, int toIndex) {
        _handleMoveGroupItem(groupId, fromIndex, toIndex);
      },
      onMoveGroupItemToGroup:
          (String fromGroupId, int fromIndex, String toGroupId, int toIndex) {
        _handleMoveGroupItemToGroup(fromGroupId, fromIndex, toGroupId, toIndex);
      },
    );

    final sortedCards = board.cards.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    for (final cardModel in sortedCards) {
      final sortedTasks = cardModel.tasks.values.toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      final group = AppFlowyGroupData(
        id: cardModel.id,
        name: cardModel.title,
        items: sortedTasks.map((task) => FlowTaskItem(task)).toList(),
      );
      newController.addGroup(group);
    }
    return newController;
  }

//NEW TEST
  void _handleMoveGroup(String movedGroupId, int oldIndex,
      String targetContextGroupId, int newIndex) {
    List<flow.CardModel> cardsList = widget.boardModel.cards.values.toList();
    cardsList.sort((a, b) => a.order.compareTo(b.order));
    List<String> orderedCardIds = cardsList.map((c) => c.id).toList();
    if (orderedCardIds.contains(movedGroupId)) {
      orderedCardIds.remove(movedGroupId);
    }
    int effectiveToIndex = newIndex.clamp(0, orderedCardIds.length);
    orderedCardIds.insert(effectiveToIndex, movedGroupId);
    boardProvider.reorderCards(widget.boardModel.id, orderedCardIds);
  }

  void _handleMoveGroupItem(String groupId, int fromIndex, int toIndex) {
    final groupController = controller.getGroupController(groupId);
    if (groupController != null) {
      final orderedItemIds =
          groupController.groupData.items.map((item) => item.id).toList();
      boardProvider.reorderTasksWithinCard(
          widget.boardModel.id, groupId, orderedItemIds);
    }
  }

  void _handleMoveGroupItemToGroup(
      String fromGroupId, int fromIndex, String toGroupId, int toIndex) {
    final targetGroupController = controller.getGroupController(toGroupId);
    if (targetGroupController == null) return;

    final itemsInTargetGroup = targetGroupController.groupData.items;
    if (toIndex < 0 || toIndex >= itemsInTargetGroup.length) return;

    final movedItemId = itemsInTargetGroup[toIndex].id;
    final taskToMove = widget.boardModel.cards[fromGroupId]?.tasks[movedItemId];
    if (taskToMove == null) return;

    final sourceGroupController = controller.getGroupController(fromGroupId);
    final orderedTaskIdsInSource =
        sourceGroupController?.groupData.items.map((i) => i.id).toList() ?? [];
    final orderedTaskIdsInTarget = itemsInTargetGroup.map((i) => i.id).toList();

    boardProvider.moveTaskToDifferentCard(
      boardId: widget.boardModel.id,
      sourceCardId: fromGroupId,
      targetCardId: toGroupId,
      taskId: movedItemId,
      taskData: taskToMove,
      orderedTaskIdsInSourceCard: orderedTaskIdsInSource,
      orderedTaskIdsInTargetCard: orderedTaskIdsInTarget,
    );
  }

  // void _handleMoveGroup(String movedGroupId, int oldIndex,
  //     String targetContextGroupId, int newIndex) {
  //   debugPrint(
  //       "Handling Move Group: movedGroupId: $movedGroupId (oldIndex: $oldIndex) to newIndex: $newIndex (targetContextGroupId: $targetContextGroupId)");

  //   // 1. Получаем список CardModel из Map.
  //   List<flow.CardModel> cardsList = widget.boardModel.cards.values.toList();

  //   // 2. Сортируем этот список по полю 'order'.
  //   cardsList.sort((a, b) => a.order.compareTo(b.order));

  //   // 3. Преобразуем отсортированный список CardModel в список их ID (String).
  //   List<String> orderedCardIds = cardsList.map((c) => c.id).toList();

  //   // Остальная логика остается прежней
  //   if (orderedCardIds.contains(movedGroupId)) {
  //     orderedCardIds.remove(movedGroupId);
  //   }

  //   int effectiveToIndex = newIndex;
  //   if (newIndex < 0) {
  //     effectiveToIndex = 0;
  //   } else if (newIndex > orderedCardIds.length) {
  //     effectiveToIndex = orderedCardIds.length;
  //   }

  //   orderedCardIds.insert(effectiveToIndex, movedGroupId);

  //   boardProvider.reorderCards(widget.boardModel.id, orderedCardIds);
  // }

  // void _handleMoveGroupItem(String groupId, int fromIndex, int toIndex) {
  //   debugPrint("Moved item in group $groupId from $fromIndex to $toIndex");
  //   final groupController = controller.getGroupController(groupId);
  //   if (groupController != null) {
  //     final orderedItemIds =
  //         groupController.groupData.items.map((item) => item.id).toList();
  //     boardProvider.reorderTasksWithinCard(
  //         widget.boardModel.id, groupId, orderedItemIds);
  //   }
  // }

  // void _handleMoveGroupItemToGroup(
  //     String fromGroupId, int fromIndex, String toGroupId, int toIndex) {
  //   debugPrint(
  //       "Item moved from group $fromGroupId (potentially from index $fromIndex) to group $toGroupId (at index $toIndex)");

  //   final targetGroupController = controller.getGroupController(toGroupId);
  //   if (targetGroupController == null) {
  //     debugPrint("Error: Target group $toGroupId not found after move.");
  //     return;
  //   }

  //   final itemsInTargetGroup = targetGroupController.groupData.items;
  //   if (toIndex < 0 || toIndex >= itemsInTargetGroup.length) {
  //     debugPrint(
  //         "Error: toIndex $toIndex is out of bounds for target group $toGroupId with ${itemsInTargetGroup.length} items.");
  //     return;
  //   }
  //   final String movedItemId = itemsInTargetGroup[toIndex].id;
  //   final taskToMove = widget.boardModel.cards[fromGroupId]?.tasks[movedItemId];

  //   if (taskToMove == null) {
  //     debugPrint(
  //         "Error: Task data not found for moved item $movedItemId (expected in fromGroupId $fromGroupId)");
  //     return;
  //   }

  //   final sourceGroupController = controller.getGroupController(fromGroupId);
  //   final orderedTaskIdsInSource =
  //       sourceGroupController?.groupData.items.map((i) => i.id).toList() ?? [];
  //   final orderedTaskIdsInTarget = itemsInTargetGroup.map((i) => i.id).toList();

  //   boardProvider.moveTaskToDifferentCard(
  //     boardId: widget.boardModel.id,
  //     sourceCardId: fromGroupId,
  //     targetCardId: toGroupId,
  //     taskId: movedItemId,
  //     taskData: taskToMove,
  //     orderedTaskIdsInSourceCard: orderedTaskIdsInSource,
  //     orderedTaskIdsInTargetCard: orderedTaskIdsInTarget,
  //   );
  // }

  void _addNewCard(bool isDark) async {
    String? title = await _showTextDialog(S.of(context).newColumn, isDark);
    if (title != null && title.isNotEmpty) {
      final newCardId = _uuid.v4();
      final newOrder = widget.boardModel.cards.length;
      final newCard = flow.CardModel(
        id: newCardId,
        title: title,
        tasks: {},
        order: newOrder,
      );
      await boardProvider.addCardToBoard(widget.boardModel.id, newCard);
    }
  }

  void _addNewTaskToCard(String cardId, bool isDark) async {
    String? title = await _showTextDialog(S.of(context).aNewTask, isDark);
    if (title != null && title.isNotEmpty) {
      final cardModel = widget.boardModel.cards[cardId];
      if (cardModel == null) return;
      final newTaskId = _uuid.v4();
      final newOrder = cardModel.tasks.length;
      final newTask = TaskModel(
        id: newTaskId,
        title: title,
        description: "",
        isDone: false,
        order: newOrder,
      );
      await boardProvider.addTaskToCard(widget.boardModel.id, cardId, newTask);
    }
  }

  Future<String?> _showTextDialog(String title, bool isDark) async {
    TextEditingController textController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontFamily: 'SFProText',
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(hintText: S.of(context).enterTheName),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              S.of(context).cancel,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontFamily: 'SFProText',
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(
              S.of(context).add,
              style: TextStyle(
                color: Colors.greenAccent.shade400,
                fontFamily: 'SFProText',
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(textController.text),
          ),
        ],
      ),
    );
  }

  void showBottomModalEdit(
      BuildContext context, String cardId, String currentTitle, bool isDark) {
    final size = MediaQuery.of(context).size;

    TextEditingController nameBoard = TextEditingController();
    nameBoard.text = currentTitle;

    //Theme.of(context).extension<AppColorsExtension>()?.mainText

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFD3D3D3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
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
                                await _renameCardWithOutUpdate(
                                    cardId, currentTitle, nameBoard.text);
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
                        SizedBox(height: size.height * 0.03),
                        SizedBox(
                          width: 300,
                          height: 50,
                          child: TextField(
                            controller: nameBoard,
                            maxLength: 20,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            cursorColor: isDark ? Colors.white : Colors.black,
                            decoration: InputDecoration(
                              counterText: "",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              hintText: S.of(context).newBoard,
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey : Colors.black54,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.white : Colors.black,
                                  width: 1, // Можно толще
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _renameCardWithOutUpdate(
      String cardId, String currentTitle, String newTitle) async {
    if (newTitle != null && newTitle.isNotEmpty && newTitle != currentTitle) {
      await boardProvider.renameCard(widget.boardModel.id, cardId, newTitle);
    }
  }

  Future<void> _renameCard(String cardId, String currentTitle) async {
    TextEditingController textController =
        TextEditingController(text: currentTitle);
    String? newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).renameAColumn),
        content: TextField(controller: textController, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, textController.text),
              child: Text(S.of(context).save)),
        ],
      ),
    );
    if (newTitle != null && newTitle.isNotEmpty && newTitle != currentTitle) {
      await boardProvider.renameCard(widget.boardModel.id, cardId, newTitle);
    }
  }

  Future<void> _deleteCard(String cardId, bool isDark) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          S.of(context).DeleteColumn,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontFamily: 'SFProText',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          S.of(context).areYouSureYouWantToDeleteThisColumnAnd,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontFamily: 'SFProText',
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              S.of(context).cancel,
              style: const TextStyle(
                fontFamily: 'SFProText',
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              S.of(context).delete,
              style: TextStyle(
                color: Colors.redAccent.shade400,
                fontFamily: 'SFProText',
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await boardProvider.removeCardFromBoard(widget.boardModel.id, cardId);
    }
  }

  Future<void> _renameTask(String cardId, TaskModel task) async {
    TextEditingController titleController =
        TextEditingController(text: task.title);
    String? newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).editATask),
        content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: InputDecoration(labelText: S.of(context).taskName)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, titleController.text),
              child: Text(S.of(context).save)),
        ],
      ),
    );
    if (newTitle != null && newTitle.isNotEmpty && newTitle != task.title) {
      final updatedTask = task.copyWith(title: newTitle);
      await boardProvider.updateTask(widget.boardModel.id, cardId, updatedTask);
    }
  }

  Future<void> _deleteTask(String cardId, String taskId, bool isDark) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          S.of(context).deleteATask,
          style: TextStyle(
            fontFamily: 'SFProText',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(S.of(context).areYouSureYouWantToDeleteThisTask),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(S.of(context).cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(S.of(context).save)),
        ],
      ),
    );
    if (confirm == true) {
      await boardProvider.removeTaskFromCard(
          widget.boardModel.id, cardId, taskId);
    }
  }

// void showBottomModalSettings(BuildContext context, String cardId,
//       String cardTitle, bool isDark) {

//     final size = MediaQuery.of(context).size;

//     final auth = Provider.of<AuthProvider>(context, listen: false);
//     final initialName = (auth.user?.displayName?.trim().isNotEmpty ?? false)
//         ? auth.user!.displayName!
//         : 'No Name';

//     //Theme.of(context).extension<AppColorsExtension>()?.mainText

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           behavior: HitTestBehavior.opaque,
//           child: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: isDark ? const Color(0xFF161616) : const Color(0xFFD3D3D3),
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: DraggableScrollableSheet(
//               expand: false,
//               initialChildSize: 0.8,
//               minChildSize: 0.3,
//               maxChildSize: 0.9,
//               builder: (context, scrollController) {

//                 return Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: ListModalWidget(
//                     scrollController: scrollController,
//                     size: size,
//                     board: _boardModel!,
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

  void _showCardActionsPopupMenu(BuildContext anchorContext, String cardId,
      String cardTitle, bool isDark) {
    final RenderBox renderBox = anchorContext.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx + renderBox.size.width - 48,
      offset.dy + 20,
      offset.dx + renderBox.size.width,
      offset.dy + renderBox.size.height + 20,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          value: 'rename',
          child: SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).renameIt,
                  style: AccountLayout.CardSubTitle.copyWith(
                    color: Theme.of(context)
                        .extension<AppColorsExtension>()
                        ?.mainText,
                  ),
                ),
                Icon(
                  IconlyLight.edit,
                  color: Colors.greenAccent.shade400,
                ),
              ],
            ),
          ),
          // child: Text(
          //   S.of(context).renameIt,
          //   style: TextStyle(
          //     color: isDark ? Colors.white : Colors.black87,
          //     fontFamily: 'SFProText',
          //     fontWeight: FontWeight.w600,
          //     fontSize: 14,
          //   ),
          // ),
        ),
        const PopupMenuItem(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(
            thickness: 0.4,
            height: 1,
            color: Colors.grey,
            indent: 5,
            endIndent: 5,
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).deleteList,
                style: AccountLayout.CardSubTitle.copyWith(
                  color: Theme.of(context)
                      .extension<AppColorsExtension>()
                      ?.mainText,
                ),
              ),
              Icon(
                IconlyLight.delete,
                color: Colors.redAccent.shade400,
              ),
            ],
          ),
          // child: Text(
          //   S.of(context).deleteList,
          //   style: TextStyle(
          //     color: isDark ? Colors.white : Colors.black87,
          //     fontFamily: 'SFProText',
          //     fontWeight: FontWeight.w600,
          //     fontSize: 14,
          //   ),
          // ),
        ),
      ],
    ).then((String? value) {
      if (value == 'rename') {
        // _renameCard(cardId, cardTitle);
        showBottomModalEdit(context, cardId, cardTitle, isDark);
      } else if (value == 'delete') {
        _deleteCard(cardId, isDark);
      }
    });
  }

  String _getGroupname(groupData) {
    String groupTitle;
    try {
      groupTitle = (groupData as dynamic).headerData.groupName;
    } catch (e) {
      try {
        groupTitle = (groupData as dynamic).name;
      } catch (e2) {
        groupTitle = groupData.id;
        debugPrint(
            "Не удалось получить имя группы для ${groupData.id}: $e, $e2");
      }
    }
    return groupTitle;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return AppFlowyBoard(
      controller: controller,
      leading: const SizedBox(
        width: 20,
      ),
      trailing: userRole != 'viewer'
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color.fromARGB(145, 31, 31, 31)
                        : const Color.fromARGB(150, 211, 211, 211),
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    _addNewCard(isDark);
                  },
                  child: Text(
                    S.of(context).addList,
                    style: const TextStyle(
                      fontFamily: 'SFProText',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(
              width: 20,
            ),
      cardBuilder: (context, groupData, groupItemObject) {
        String groupTitle = _getGroupname(groupData);
        final currentItem = groupItemObject as FlowTaskItem;

        return Padding(
          key: ValueKey('item_${currentItem.id}'),
          padding: const EdgeInsets.only(
            top: 5,
          ), // Уменьшаем отступы для визуальной отладки
          child: Card(
            color: isDark ? const Color(0xFF3A3A3D) : Colors.white,
            elevation: 10,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                currentItem.title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                currentItem.description,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              leading: IconButton(
                icon: Icon(
                  currentItem.isDone
                      ? Icons.check_box
                      : Icons.check_box_outline_blank_outlined,
                  color: currentItem.isDone ? Colors.green : Colors.grey,
                ),
                onPressed: () async {
                  final boardProvider = context.read<BoardProvider>();
                  if (userRole != "viewer") {
                    final updatedTask = currentItem.task.copyWith(
                      isDone: !currentItem.isDone, // инвертируем состояние
                    );

                    await boardProvider.updateTask(
                      widget.boardModel.id, // boardId
                      groupData.id, // cardId
                      updatedTask,
                    );
                  }
                },
              ),

              // trailing: (userRole != "viewer")
              //     ? IconButton(
              //         onPressed: () async {
              //           await _deleteTask(groupData.id, currentItem.id, isDark);
              //         },
              //         icon: Icon(
              //           IconlyLight.delete,
              //           color: Colors.redAccent.shade400,
              //         ))
              //     : null,
              onTap: () {
                // debugPrint("CUrretn ITEM ${currentItem}");
                // debugPrint("SAMPEL ${groupData}");
                context.push(
                  '/board/${widget.boardModel.id}/card/${groupData.id}/task/${currentItem.id}',
                );
              },
            ),
          ),
        );
      },
      headerBuilder: (context, groupData) {
        String groupTitle = _getGroupname(groupData);

        return Container(
          key: ValueKey('header_${groupData.id}'),
          padding: const EdgeInsets.only(left: 14.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F5),
            borderRadius: BorderRadius.circular(30),
          ),
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                groupTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                iconSize: 24,
                onPressed: () {
                  if (userRole != 'viewer') {
                    _showCardActionsPopupMenu(
                        context, groupData.id, groupTitle, isDark);
                  }
                },
                icon: Icon(
                  Icons.more_horiz_outlined,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                tooltip: "Действия с колонкой",
              ),
            ],
          ),

          /* AppFlowyGroupHeader(
            title: Text(groupTitle,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D47A1)) // Темно-синий
                ),
            onAddButtonClick: () => _addNewTaskToCard(groupData.id),
            icon: Icon(Icons.add_circle, size: 22, color: Colors.blue[700]),
            moreIcon: Builder(builder: (BuildContext menuContext) {
              return IconButton(
                icon: Icon(Icons.more_vert, color: Colors.blueGrey[700]),
                onPressed: () {
                  _showCardActionsPopupMenu(
                      menuContext, groupData.id, groupTitle);
                },
                tooltip: "Действия с колонкой",
              );
            }),
          ), */
        );
      },
      groupConstraints: const BoxConstraints(
        minWidth: 350.0,
        maxWidth: 350.0,
        maxHeight: 600,
        minHeight: 100,
      ),
      config: AppFlowyBoardConfig(
        groupBackgroundColor:
            isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F5),
        stretchGroupHeight: false,
        cardMargin: const EdgeInsets.symmetric(vertical: 10.0),
      ),
      footerBuilder: (context, groupData) {
        if (userRole != 'viewer') {
          return InkWell(
            key: ValueKey(
                'footer_${groupData.id}'), // ИЗМЕНЕНО: Добавляем ключ к футеру группы
            onTap: () => _addNewTaskToCard(groupData.id, isDark),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F5),
                // borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)), // Если нужны скругленные углы только снизу
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_task,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).addATask,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
