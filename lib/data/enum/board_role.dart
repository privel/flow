import 'package:flow/data/models/board_model.dart';

enum BoardRole { reader, editor, admin }

BoardRole getRoleForUser(String uid, BoardModel board) {
  if (uid == board.ownerId) return BoardRole.admin;
  final role = board.sharedWith[uid];
  switch (role) {
    case 'reader':
      return BoardRole.reader;
    case 'editor':
      return BoardRole.editor;
    case 'admin':
      return BoardRole.admin;
    default:
      return BoardRole.reader;
  }
}
