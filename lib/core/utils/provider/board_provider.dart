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


Future<BoardModel?> getBoardById(String boardId) async {
  final doc = await _firestore.collection('boards').doc(boardId).get();
  if (doc.exists) {
    return BoardModel.fromMap(doc.data()!, doc.id);
  }
  return null;
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
