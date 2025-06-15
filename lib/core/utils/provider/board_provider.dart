import 'dart:typed_data';

import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/notification_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/card_model.dart';
import 'package:flow/data/models/role_model.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flow/data/models/user_models.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:uuid/uuid.dart';

class BoardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BoardModel> _boards = [];

  List<BoardModel> get boards => _boards;

  Future<void> renameCard(
      String boardId, String cardId, String newTitle) async {
    final docRef = _firestore.collection('boards').doc(boardId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final board = BoardModel.fromMap(doc.data()!, boardId);
    final updatedCards = Map<String, CardModel>.from(board.cards);

    if (updatedCards.containsKey(cardId)) {
      final updatedCard = updatedCards[cardId]!.copyWith(title: newTitle);
      updatedCards[cardId] = updatedCard;

      final updatedBoard = board.copyWith(cards: updatedCards);
      await docRef.set(updatedBoard.toMap());
    }
  }

  Future<void> addCardToBoard(String boardId, CardModel card) async {
    final boardRef =
        FirebaseFirestore.instance.collection('boards').doc(boardId);

    await boardRef.update({
      'cards.${card.id}': card.toMap(),
    });
  }

  Future<void> removeCardFromBoard(String boardId, String cardId) async {
    final boardRef =
        FirebaseFirestore.instance.collection('boards').doc(boardId);

    await boardRef.update({
      'cards.$cardId': FieldValue.delete(),
    });
  }

  Future<void> addTaskToCard(
      String boardId, String cardId, TaskModel task) async {
    final boardRef =
        FirebaseFirestore.instance.collection('boards').doc(boardId);

    final path = 'cards.$cardId.tasks.${task.id}';
    await boardRef.update({
      path: task.toMap(),
    });
  }

  Future<void> removeTaskFromCard(
      String boardId, String cardId, String taskId) async {
    final boardRef =
        FirebaseFirestore.instance.collection('boards').doc(boardId);

    await boardRef.update({
      'cards.$cardId.tasks.$taskId': FieldValue.delete(),
    });
  }

  Future<void> updateTask(
      String boardId, String cardId, TaskModel updatedTask) async {
    final boardRef =
        FirebaseFirestore.instance.collection('boards').doc(boardId);

    await boardRef.update({
      'cards.$cardId.tasks.${updatedTask.id}': updatedTask.toMap(),
    });
  }

  Future<void> reorderCards(String boardId, List<String> orderedCardIds) async {
    final boardRef = _firestore.collection('boards').doc(boardId);
    WriteBatch batch = _firestore.batch();

    for (int i = 0; i < orderedCardIds.length; i++) {
      final cardId = orderedCardIds[i];
      batch.update(boardRef, {'cards.$cardId.order': i});
    }
    await batch.commit();
  }

  Future<void> reorderTasksWithinCard(
      String boardId, String cardId, List<String> orderedTaskIds) async {
    final boardRef = _firestore.collection('boards').doc(boardId);
    WriteBatch batch = _firestore.batch();

    for (int i = 0; i < orderedTaskIds.length; i++) {
      final taskId = orderedTaskIds[i];
      batch.update(boardRef, {'cards.$cardId.tasks.$taskId.order': i});
    }
    await batch.commit();
  }

  Future<void> moveTaskToDifferentCard({
    required String boardId,
    required String sourceCardId,
    required String targetCardId,
    required String taskId,
    required TaskModel taskData, // Full task data, new order will be set
    required List<String>
        orderedTaskIdsInSourceCard, // Tasks remaining in source, ordered
    required List<String>
        orderedTaskIdsInTargetCard, // All tasks in target (including moved one), ordered
  }) async {
    final boardRef = _firestore.collection('boards').doc(boardId);
    WriteBatch batch = _firestore.batch();

    // 1. Remove task from source card's task map
    batch.update(
        boardRef, {'cards.$sourceCardId.tasks.$taskId': FieldValue.delete()});

    // 2. Re-order remaining tasks in source card
    for (int i = 0; i < orderedTaskIdsInSourceCard.length; i++) {
      final currentTaskId = orderedTaskIdsInSourceCard[i];
      batch.update(
          boardRef, {'cards.$sourceCardId.tasks.$currentTaskId.order': i});
    }

    // 3. Add/Update task in target card's task map and re-order all tasks in target
    // The taskData should have its order field updated before this step by the caller if needed,
    // but here we explicitly set order based on orderedTaskIdsInTargetCard list.
    for (int i = 0; i < orderedTaskIdsInTargetCard.length; i++) {
      final currentTaskId = orderedTaskIdsInTargetCard[i];
      if (currentTaskId == taskId) {
        // Add the moved task with its new order in the target card
        batch.set(
          boardRef,
          {
            'cards.$targetCardId.tasks.$taskId':
                taskData.copyWith(order: i).toMap()
          },
          SetOptions(
              merge:
                  true), // Use merge to avoid overwriting the whole tasks map if it exists
        );
      } else {
        // Update order for other tasks in the target card
        batch.update(
            boardRef, {'cards.$targetCardId.tasks.$currentTaskId.order': i});
      }
    }
    await batch.commit();
  }

  /* Future<void> createBoard(BoardModel board) async {
    final docRef = await _firestore.collection('boards').add(board.toMap());
    _boards.add(board.copyWith(id: docRef.id));
    notifyListeners();
  }

  Future<void> updateBoard(BoardModel board) async {
    await _firestore.collection('boards').doc(board.id).update(board.toMap());
    final index = _boards.indexWhere((b) => b.id == board.id);
    if (index != -1) {
      _boards[index] = board;
      notifyListeners();
    }
  }

  Future<void> deleteBoard(String boardId) async {
    await _firestore.collection('boards').doc(boardId).delete();
    _boards.removeWhere((b) => b.id == boardId);
    notifyListeners();
  } */

//   Future<void> addExampleCardToBoard(String boardId) async {
//   final docRef = _firestore.collection('boards').doc(boardId);
//   final doc = await docRef.get();
//   if (!doc.exists) return;

//   final board = BoardModel.fromMap(doc.data()!, doc.id);

//   final updatedCards = List<CardModel>.from(board.cards)
//     ..add(CardModel(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       title: 'Новая карточка',
//       tasks: [
//         TaskModel(
//           id: 't1',
//           title: 'Пример задачи',
//           description: 'Описание задачи',
//           isDone: false,
//         )
//       ],
//     ));

//   await docRef.update({
//     'cards': updatedCards.map((c) => c.toMap()).toList(),
//   });

//   // Обнови локальный список, если надо
//   await fetchBoards(board.ownerId);
//   notifyListeners();
// }

// Future<BoardModel?> getBoardById(String boardId) async {
//   final doc = await _firestore.collection('boards').doc(boardId).get();
//   if (doc.exists) {
//     return BoardModel.fromMap(doc.data()!, doc.id);
//   }
//   return null;
// }

  Future<List<BoardMember>> loadBoardUsers(
      BoardModel board, AuthProvider auth) async {
    List<BoardMember> result = [];

    final owner = await auth.fetchUserById(board.ownerId);
    if (owner != null) {
      result.add(BoardMember(user: owner, role: 'owner'));
    }

    for (final entry in board.sharedWith.entries) {
      final userId = entry.key;
      final info = entry.value;

      if (userId != board.ownerId && info['status'] == 'accepted') {
        final user = await auth.fetchUserById(userId);
        if (user != null) {
          result.add(BoardMember(user: user, role: info['role']));
        }
      }
    }

    return result;
  }

  Future<BoardModel?> getBoardById(String boardId) async {
    try {
      // ИЗМЕНЕНИЕ ЗДЕСЬ: Принудительно читаем с сервера для диагностики
      final doc = await _firestore
          .collection('boards')
          .doc(boardId)
          .get(const GetOptions(source: Source.server)); // Добавляем GetOptions

      if (doc.exists) {
        return BoardModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching board by ID from server: $e");
      return null; // В случае ошибки возвращаем null или обрабатываем иначе
    }
  }

  Stream<List<BoardModel>> watchBoards(String userId) {
    return _firestore.collection('boards').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data['ownerId'] == userId ||
                (data['sharedWith']?.containsKey(userId) ?? false)) {
              return BoardModel.fromMap(data, doc.id);
            }
            return null;
          })
          .whereType<BoardModel>()
          .toList();
    });
  }

  Stream<BoardModel?> watchBoardById(String boardId) {
    return _firestore.collection('boards').doc(boardId).snapshots().map((doc) {
      if (doc.exists) {
        return BoardModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Stream<Map<String, TaskModel>> watchTasksInCard(
      String boardId, String cardId) {
    return _firestore.collection('boards').doc(boardId).snapshots().map((doc) {
      if (!doc.exists) return {};

      final boardData = doc.data();
      final cardsMap = Map<String, dynamic>.from(boardData?['cards'] ?? {});
      final cardData = cardsMap[cardId];

      if (cardData == null || cardData['tasks'] == null) return {};

      final tasksMap = Map<String, dynamic>.from(cardData['tasks']);
      return tasksMap.map((taskId, taskData) {
        return MapEntry(
          taskId,
          TaskModel.fromMap(Map<String, dynamic>.from(taskData), taskId),
        );
      });
    });
  }




  Stream<TaskModel?> watchTaskById(
      String boardId, String cardId, String taskId) {
    final docRef = _firestore.collection('boards').doc(boardId);

    return docRef.snapshots().map((doc) {
      if (!doc.exists) return null;

      final boardData = doc.data();
      final cardMap = Map<String, dynamic>.from(boardData?['cards'] ?? {});
      final cardData = cardMap[cardId];

      if (cardData == null) return null;

      final tasksMap = Map<String, dynamic>.from(cardData['tasks'] ?? {});
      final taskData = tasksMap[taskId];

      if (taskData == null) return null;

      return TaskModel.fromMap(Map<String, dynamic>.from(taskData), taskId);
    });
  }

  Future<void> fetchBoards(String userId) async {
    final snapshot = await _firestore.collection('boards').get();

    _boards = snapshot.docs
        .map((doc) {
          final data = doc.data();
          if (data['ownerId'] == userId ||
              (data['sharedWith']?.containsKey(userId) ?? false)) {
            return BoardModel.fromMap(data, doc.id);
          }
          return null;
        })
        .whereType<BoardModel>()
        .toList();

    notifyListeners();
  }

  Future<void> createBoard(BoardModel board) async {
    final docRef = await _firestore.collection('boards').add(board.toMap());
    _boards.add(board.copyWith(id: docRef.id));
    notifyListeners();
  }

  Future<void> updateBoard(BoardModel board) async {
    await _firestore.collection('boards').doc(board.id).update(board.toMap());
    final index = _boards.indexWhere((b) => b.id == board.id);
    if (index != -1) {
      _boards[index] = board;
      notifyListeners();
    }
  }

  Future<void> markBoardAsFavorite(String boardId, bool isFavorite) async {
    await FirebaseFirestore.instance
        .collection('boards')
        .doc(boardId)
        .update({'isFavorite': isFavorite});
  }

  Future<void> deleteBoard(String boardId) async {
    await _firestore.collection('boards').doc(boardId).delete();
    _boards.removeWhere((b) => b.id == boardId);
    notifyListeners();
  }

  // Роли
  String? getUserRole(BoardModel board, String userId) {
    if (board.ownerId == userId) return 'owner';
    return board.sharedWith[userId]?['role'];
  }

  bool canEdit(BoardModel board, String userId) {
    final role = getUserRole(board, userId);
    return role == 'editor' || role == 'owner';
  }

  bool canView(BoardModel board, String userId) {
    final role = getUserRole(board, userId);
    return role != null;
  }

//   List<TaskModel> getTasksForBoard(String boardId) {
//   return tasks.where((t) => t.boardId == boardId).toList();
// }

  // Добавление участника
  // Future<void> addUserToBoard(
  //     BoardModel board, String newUserId, String role) async {
  //   final updatedSharedWith =
  //       Map<String, Map<String, dynamic>>.from(board.sharedWith);
  //   updatedSharedWith[newUserId] = {
  //     'role': role,
  //     'status': 'pending',
  //   };
  //   final updatedBoard = board.copyWith(sharedWith: updatedSharedWith);
  //   await updateBoard(updatedBoard);

  // }

  Future<void> getValidTaskAssignees(
      String boardId, String cardId, String taskId) async {
    final brd = await FirebaseFirestore.instance
        .collection('boards')
        .doc(boardId)
        .collection('cards')
        .doc(cardId)
        .collection('tasks')
        .doc(taskId);
    debugPrint('${brd.firestore.collection('assigneeIds').doc('0')}');
  }

  Future<void> addUserToBoard(
    BoardModel board,
    String newUserId,
    String role,
    AppUser sender,
    NotificationProvider notificationProvider,
  ) async {
    final updatedSharedWith =
        Map<String, Map<String, dynamic>>.from(board.sharedWith);

    final isNewUser = !updatedSharedWith.containsKey(newUserId);

    updatedSharedWith[newUserId] = {
      'role': role,
      'status': isNewUser
          ? 'pending'
          : updatedSharedWith[newUserId]?['status'] ?? 'accepted',
    };

    final updatedBoard = board.copyWith(sharedWith: updatedSharedWith);
    await updateBoard(updatedBoard);

    if (isNewUser) {
      // Отправляем уведомление только при первом добавлении
      await notificationProvider.sendInvitationNotification(
        recipientId: newUserId,
        sender: sender,
        board: updatedBoard,
      );
    }
  }

  Future<void> acceptInvite(String boardId, String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('boards')
        .doc(boardId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      final sharedWith = Map<String, dynamic>.from(data['sharedWith']);
      if (sharedWith.containsKey(userId)) {
        sharedWith[userId]['status'] = 'accepted';

        await FirebaseFirestore.instance
            .collection('boards')
            .doc(boardId)
            .update({'sharedWith': sharedWith});
      }
    }
  }

  Future<void> declineInvite(String boardId, String userId) async {
    final docRef = FirebaseFirestore.instance.collection('boards').doc(boardId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final data = doc.data()!;
    final sharedWith = Map<String, dynamic>.from(data['sharedWith'] ?? {});
    if (sharedWith.containsKey(userId)) {
      sharedWith[userId]['status'] = 'declined';
      await docRef.update({'sharedWith': sharedWith});
    }
  }

  // Удаление участника
  Future<void> removeUserFromBoard(
      BoardModel board, String removeUserId) async {
    final updatedSharedWith =
        Map<String, Map<String, dynamic>>.from(board.sharedWith);
    updatedSharedWith.remove(removeUserId);
    final updatedBoard = board.copyWith(sharedWith: updatedSharedWith);
    await updateBoard(updatedBoard);
  }

  Future<BoardModel?> joinBoardByInviteId(
      String inviteId, String userId) async {
    final snapshot = await _firestore
        .collection('boards')
        .where('inviteId', isEqualTo: inviteId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final boardId = doc.id;
    final data = doc.data();

    final sharedWith = Map<String, dynamic>.from(data['sharedWith'] ?? {});

    if (!sharedWith.containsKey(userId)) {
      sharedWith[userId] = {
        'role': 'viewer',
        'status': 'pending',
      };

      await doc.reference.update({
        'sharedWith': sharedWith,
      });
    }

    return BoardModel.fromMap(data, boardId);
  }

  
Future<void> addAssigneeToTask(
  BoardModel board,
  String cardId,
  String taskId,
  String userId,
) async {
  final card = board.cards[cardId];
  if (card == null) return;

  final task = card.tasks[taskId];
  if (task == null) return;

  if (!task.assignees.containsKey(userId)) {
    final updatedAssignees = Map<String, DateTime>.from(task.assignees)
      ..[userId] = DateTime.now();

    final updatedTask = task.copyWith(assignees: updatedAssignees);
    card.tasks[taskId] = updatedTask;

    await updateBoard(board);
    notifyListeners();
  }
}


Future<void> removeAssigneeFromTask(
  BoardModel board,
  String cardId,
  String taskId,
  String userId,
) async {
  final card = board.cards[cardId];
  if (card == null) return;

  final task = card.tasks[taskId];
  if (task == null) return;

  if (task.assignees.containsKey(userId)) {
    final updatedAssignees = Map<String, DateTime>.from(task.assignees)
      ..remove(userId);

    final updatedTask = task.copyWith(assignees: updatedAssignees);
    card.tasks[taskId] = updatedTask;

    await updateBoard(board);
    notifyListeners();
  }
}

 Future<String?> uploadTaskImage(String taskId, Uint8List imageBytes) async {
    try {
      final String imageId = const Uuid().v4(); // Генерируем уникальный ID для изображения
      final String fileName = 'tasks/$taskId/$imageId.jpg'; // Путь для хранения: tasks/taskId/imageId.jpg

      // Удалите 'supa.StorageResponse'
      final response = await supa.Supabase.instance.client.storage
          .from('task.attached') // Имя бакета изменено на 'task.attached'
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const supa.FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Проверка на ошибку после выполнения операции
      // Supabase клиент может выбросить исключение при ошибке, или возвращать объект с полем error
      // Если response - это напрямую путь, то error будет в catch блоке
      // Если response - это объект с ошибкой, как раньше в StorageResponse, то проверка ниже будет работать.
      // Если это просто url, а ошибки ловятся try-catch, то этот if может быть лишним.
      // Для нового Supabase SDK, ошибки обычно выбрасываются, и их ловят в catch.
      // Поэтому, если response.error больше не существует, просто удалите этот if блок.
      // Ниже пример как может выглядеть код для более новой версии Supabase (без response.error)
      // В любом случае, publicUrl будет работать, если загрузка успешна.

      final publicUrl = supa.Supabase.instance.client.storage
          .from('task.attached') // Имя бакета изменено на 'task.attached'
          .getPublicUrl(fileName);

      debugPrint("📤 Загружено изображение задачи в Supabase: $publicUrl");
      return publicUrl;
    } catch (e) {
      debugPrint('Exception during task image upload: $e');
      return null;
    }
  }

  // Метод для удаления изображения задачи из Supabase Storage
  Future<void> deleteTaskImage(String taskId, String imageId) async {
    try {
      final String fileName = 'tasks/$taskId/$imageId.jpg'; // Путь к файлу

      // Удалите 'supa.StorageResponse'
      final result = await supa.Supabase.instance.client.storage
          .from('task.attached') // Имя бакета изменено на 'task.attached'
          .remove([fileName]);

      // В зависимости от версии Supabase SDK, result может быть List<FileObject> или чем-то другим.
      // Ошибки, как правило, будут перехвачены в catch блоке.
      debugPrint("🗑️ Изображение задачи удалено из Supabase: $result");
    } catch (e) {
      debugPrint('Exception during task image deletion: $e');
    }
  }





// // Метод: Получить валидных назначенных участников задачи
//   List<AppUser> getValidTaskAssigneesTest(String boardId, String cardId, String taskId) {
//     final board = boards1[boardId];
//     if (board == null) return [];

//     final card = board.cards[cardId];
//     if (card == null) return [];

//     final task = card.tasks[taskId];
//     if (task == null) return [];

//     final sharedUserIds = board.sharedWith.keys.toSet();
//     final memberIds = board.sharedWith.keys.toSet();
//     final validUserIds = {...sharedUserIds, ...memberIds, board.ownerId};

//     return task.assigneeIds
//         .where((id) => validUserIds.contains(id))
//         .map((id) => allUsers1[id])
//         .whereType<AppUser>()
//         .toList();
//   }

//   // Метод: Получить всех пользователей, подтвердивших участие
//   List<AppUser> getConfirmedBoardUsers(String boardId) {
//     final board = boards1[boardId];
//     if (board == null) return [];

//     final confirmedUserIds = board.sharedWith.entries
//         .where((entry) => entry.value['status'] == 'accepted')
//         .map((e) => e.key)
//         .toSet();

//     final memberIds = board.sharedWith.keys.toSet();

//     final validIds = {...confirmedUserIds, ...memberIds, board.ownerId};

//     return validIds.map((uid) => allUsers1[uid]).whereType<AppUser>().toList();
//   }

//   // Метод: Добавить участника к задаче
//   void addAssigneeToTask(String boardId, String cardId, String taskId, String userId) {
//     final board = boards1[boardId];
//     if (board == null ||
//         !(board.sharedWith[userId]?['status'] == 'accepted') &&
//         !board.sharedWith.containsKey(userId) &&
//         userId != board.ownerId) return;

//     final card = board.cards[cardId];
//     if (card == null) return;

//     final task = card.tasks[taskId];
//     if (task == null) return;

//     if (!task.assigneeIds.contains(userId)) {
//       final updatedAssignees = [...task.assigneeIds, userId];
//       final updatedTask = task.copyWith(assigneeIds: updatedAssignees);
//       card.tasks[taskId] = updatedTask;
//       notifyListeners();
//     }
//   }

//   // Метод: Удалить участника из задачи
//   void removeAssigneeFromTask(String boardId, String cardId, String taskId, String userId) {
//     final board = boards1[boardId];
//     if (board == null) return;

//     final card = board.cards[cardId];
//     if (card == null) return;

//     final task = card.tasks[taskId];
//     if (task == null) return;

//     if (task.assigneeIds.contains(userId)) {
//       final updatedAssignees = List<String>.from(task.assigneeIds)..remove(userId);
//       final updatedTask = task.copyWith(assigneeIds: updatedAssignees);
//       card.tasks[taskId] = updatedTask;
//       notifyListeners();
//     }
//   }

//   // Метод: Очистить недействительных участников из всех задач доски
//   void cleanInvalidAssigneesFromBoard(String boardId) {
//     final board = boards1[boardId];
//     if (board == null) return;

//     final validUserIds = {
//       ...board.sharedWith.keys,
//       ...board.sharedWith.keys,
//       board.ownerId,
//     };

//     board.cards.forEach((cardId, card) {
//       card.tasks.forEach((taskId, task) {
//         final filteredAssignees = task.assigneeIds
//             .where((id) => validUserIds.contains(id))
//             .toList();
//         card.tasks[taskId] = task.copyWith(assigneeIds: filteredAssignees);
//       });
//     });

//     notifyListeners();
//   }

//   // Метод: Обновить доску с проверкой удаления пользователей
//   Future<void> updateBoardWithCleanup(BoardModel board) async {
//     boards1[board.id] = board;
//     cleanInvalidAssigneesFromBoard(board.id);
//     notifyListeners();
//     await updateBoard(board); // Предполагается, что этот метод сохраняет в БД
//   }

  // Обновлённый метод добавления пользователя в доску
  // Future<void> addUserToBoard(
  //   BoardModel board,
  //   String newUserId,
  //   String role,
  //   AppUser sender,
  //   NotificationProvider notificationProvider,
  // ) async {
  //   final updatedSharedWith =
  //       Map<String, Map<String, dynamic>>.from(board.sharedWith);

  //   final isNewUser = !updatedSharedWith.containsKey(newUserId);

  //   updatedSharedWith[newUserId] = {
  //     'role': role,
  //     'status': isNewUser
  //         ? 'pending'
  //         : updatedSharedWith[newUserId]?['status'] ?? 'accepted',
  //   };

  //   final updatedBoard = board.copyWith(sharedWith: updatedSharedWith);
  //   await updateBoardWithCleanup(updatedBoard);

  //   if (isNewUser) {
  //     await notificationProvider.sendInvitationNotification(
  //       recipientId: newUserId,
  //       sender: sender,
  //       board: updatedBoard,
  //     );
  //   }
  // }
}
