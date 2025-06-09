import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/role_model.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flutter/material.dart';

class AssigneeBottomSheetContent extends StatefulWidget {
  final BoardModel board;
  final String cardId;
  final TaskModel task;
  final BoardProvider boardProvider;
  final AuthProvider auth;

  const AssigneeBottomSheetContent({
    required this.board,
    required this.cardId,
    required this.task,
    required this.boardProvider,
    required this.auth,
  });

  @override
  State<AssigneeBottomSheetContent> createState() =>
      _AssigneeBottomSheetContentState();
}

class _AssigneeBottomSheetContentState
    extends State<AssigneeBottomSheetContent> {
  final TextEditingController controller = TextEditingController();
  List<BoardMember> visibleList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => updateList(''));
  }

  Future<void> updateList(String query) async {
    final allMembers =
        await widget.boardProvider.loadBoardUsers(widget.board, widget.auth);

    final acceptedMembers = allMembers
        .where((member) =>
            widget.board.sharedWith[member.user.id]?['status'] == 'accepted' ||
            member.user.id == widget.board.ownerId)
        .toList();

    List<BoardMember> filtered;

    if (query.isEmpty) {
      filtered = acceptedMembers;
    } else {
      filtered = acceptedMembers
          .where((u) =>
              u.user.displayName.toLowerCase().contains(query.toLowerCase()) ||
              u.user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // Сортируем: сначала те, кто уже назначен
    filtered.sort((a, b) {
      final aAssigned = widget.task.assigneeIds.contains(a.user.id);
      final bAssigned = widget.task.assigneeIds.contains(b.user.id);
      return bAssigned
          ? 1
          : aAssigned
              ? -1
              : 0;
    });

    setState(() => visibleList = filtered);
  }

  // Future<void> updateList(String query) async {
  //   final allMembers =
  //       await widget.boardProvider.loadBoardUsers(widget.board, widget.auth);

  //   final acceptedMembers = allMembers
  //       .where((member) =>
  //           widget.board.sharedWith[member.user.id]?['status'] == 'accepted' ||
  //           member.user.id == widget.board.ownerId)
  //       .toList();

  //   if (query.isEmpty) {
  //     setState(() => visibleList = acceptedMembers);
  //   } else {
  //     setState(() {
  //       visibleList = acceptedMembers
  //           .where((u) =>
  //               u.user.displayName
  //                   .toLowerCase()
  //                   .contains(query.toLowerCase()) ||
  //               u.user.email.toLowerCase().contains(query.toLowerCase()))
  //           .toList();
  //     });
  //   }
  // }

  void _confirmRemove(BoardMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Удаление участника"),
        content: Text(
            "Вы действительно хотите удалить ${member.user.displayName} из задачи?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Отмена")),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Удалить")),
        ],
      ),
    );

    if (confirm == true) {
      await widget.boardProvider.removeAssigneeFromTask(
        widget.board,
        widget.cardId,
        widget.task.id,
        member.user.id,
      );
      setState(() {
        widget.task.assigneeIds.remove(member.user.id);
      });
      updateList(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Назначить участников',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: updateList,
            decoration: const InputDecoration(
              hintText: 'Поиск по имени или email',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          if (visibleList.isEmpty)
            Text(controller.text.isEmpty
                ? 'Нет назначенных участников'
                : 'Никто не найден'),
          ...visibleList.map((member) {
            final assigned = widget.task.assigneeIds.contains(member.user.id);
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: member.user.photoUrl != null
                    // ? NetworkImage(member.user.photoUrl!)
                    ? null
                    : null,
                child: member.user.photoUrl == null
                    ? Text(member.user.displayName[0])
                    : null,
              ),
              title: Text(member.user.displayName),
              subtitle: Text(member.user.email),
              trailing: Icon(assigned ? Icons.remove : Icons.add,
                  color: assigned ? Colors.red : Colors.green),
              onTap: () async {
                if (assigned) {
                  _confirmRemove(member);
                } else {
                  widget.boardProvider.addAssigneeToTask(
                    widget.board,
                    widget.cardId,
                    widget.task.id,
                    member.user.id,
                  );
                  setState(() {
                    widget.task.assigneeIds.add(member.user.id);
                  });
                  updateList(controller.text);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
