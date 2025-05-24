import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/card_model.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';



class BoardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BoardModel> _boards = [];

  List<BoardModel> get boards => _boards;



Future<void> renameCard(String boardId, String cardId, String newTitle) async {
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
  final boardRef = FirebaseFirestore.instance.collection('boards').doc(boardId);

  await boardRef.update({
    'cards.${card.id}': card.toMap(),
  });
}
Future<void> removeCardFromBoard(String boardId, String cardId) async {
  final boardRef = FirebaseFirestore.instance.collection('boards').doc(boardId);

  await boardRef.update({
    'cards.$cardId': FieldValue.delete(),
  });
}


Future<void> addTaskToCard(String boardId, String cardId, TaskModel task) async {
  final boardRef = FirebaseFirestore.instance.collection('boards').doc(boardId);

  final path = 'cards.$cardId.tasks.${task.id}';
  await boardRef.update({
    path: task.toMap(),
  });
}
Future<void> removeTaskFromCard(String boardId, String cardId, String taskId) async {
  final boardRef = FirebaseFirestore.instance.collection('boards').doc(boardId);

  await boardRef.update({
    'cards.$cardId.tasks.$taskId': FieldValue.delete(),
  });
}

Future<void> updateTask(String boardId, String cardId, TaskModel updatedTask) async {
  final boardRef = FirebaseFirestore.instance.collection('boards').doc(boardId);

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

  Future<void> reorderTasksWithinCard(String boardId, String cardId, List<String> orderedTaskIds) async {
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
    required List<String> orderedTaskIdsInSourceCard, // Tasks remaining in source, ordered
    required List<String> orderedTaskIdsInTargetCard, // All tasks in target (including moved one), ordered
  }) async {
    final boardRef = _firestore.collection('boards').doc(boardId);
    WriteBatch batch = _firestore.batch();

    // 1. Remove task from source card's task map
    batch.update(boardRef, {'cards.$sourceCardId.tasks.$taskId': FieldValue.delete()});

    // 2. Re-order remaining tasks in source card
    for (int i = 0; i < orderedTaskIdsInSourceCard.length; i++) {
      final currentTaskId = orderedTaskIdsInSourceCard[i];
      batch.update(boardRef, {'cards.$sourceCardId.tasks.$currentTaskId.order': i});
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
          {'cards.$targetCardId.tasks.$taskId': taskData.copyWith(order: i).toMap()},
          SetOptions(merge: true), // Use merge to avoid overwriting the whole tasks map if it exists
        );
      } else {
        // Update order for other tasks in the target card
         batch.update(boardRef, {'cards.$targetCardId.tasks.$currentTaskId.order': i});
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
          if (data['ownerId'] == userId || (data['sharedWith']?.containsKey(userId) ?? false)) {
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

Stream<Map<String, TaskModel>> watchTasksInCard(String boardId, String cardId) {
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
Stream<TaskModel?> watchTaskById(String boardId, String cardId, String taskId) {
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

    _boards = snapshot.docs.map((doc) {
      final data = doc.data();
      if (data['ownerId'] == userId || (data['sharedWith']?.containsKey(userId) ?? false)) {
        return BoardModel.fromMap(data, doc.id);
      }
      return null;
    }).whereType<BoardModel>().toList();

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

  Future<void> deleteBoard(String boardId) async {
    await _firestore.collection('boards').doc(boardId).delete();
    _boards.removeWhere((b) => b.id == boardId);
    notifyListeners();
  }

  // Роли
  String? getUserRole(BoardModel board, String userId) {
    if (board.ownerId == userId) return 'admin';
    return board.sharedWith[userId];
  }

  bool canEdit(BoardModel board, String userId) {
    final role = getUserRole(board, userId);
    return role == 'editor' || role == 'admin';
  }

  bool canView(BoardModel board, String userId) {
    final role = getUserRole(board, userId);
    return role != null;
  }

//   List<TaskModel> getTasksForBoard(String boardId) {
//   return tasks.where((t) => t.boardId == boardId).toList();
// }


  // Добавление участника
  Future<void> addUserToBoard(BoardModel board, String newUserId, String role) async {
    final updatedSharedWith = Map<String, String>.from(board.sharedWith);
    updatedSharedWith[newUserId] = role;
    final updatedBoard = board.copyWith(sharedWith: updatedSharedWith);
    await updateBoard(updatedBoard);
  }

  // Удаление участника
  Future<void> removeUserFromBoard(BoardModel board, String removeUserId) async {
    final updatedSharedWith = Map<String, String>.from(board.sharedWith);
    updatedSharedWith.remove(removeUserId);
    final updatedBoard = board.copyWith(sharedWith: updatedSharedWith);
    await updateBoard(updatedBoard);
  }
}
