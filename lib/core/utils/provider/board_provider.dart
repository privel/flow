import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';



class BoardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BoardModel> _boards = [];

  List<BoardModel> get boards => _boards;


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
