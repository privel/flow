import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/role_model.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/widgets/search_bar.dart';
import 'package:flow/presentation/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class AssigneeBottomSheetContent extends StatefulWidget {
  final BoardModel board;
  final String cardId;
  final TaskModel task;
  final BoardProvider boardProvider;
  final AuthProvider auth;

  const AssigneeBottomSheetContent({
    super.key,
    required this.board,
    required this.cardId,
    required this.task,
    required this.boardProvider,
    required this.auth,
  }); // 🔧 и здесь

  @override
  State<AssigneeBottomSheetContent> createState() =>
      _AssigneeBottomSheetContentState();
}

class _AssigneeBottomSheetContentState
    extends State<AssigneeBottomSheetContent> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();
  List<BoardMember> visibleList = [];
  String? userRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => updateList(''));
  }

  Future<void> updateList(String query) async {
    final allMembers =
        await widget.boardProvider.loadBoardUsers(widget.board, widget.auth);

    userRole = widget.boardProvider
        .getUserRole(widget.board, widget.auth.user?.uid ?? '');

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
      final aAssigned = widget.task.assignees.keys.contains(a.user.id);
      final bAssigned = widget.task.assignees.keys.contains(b.user.id);
      return bAssigned
          ? 1
          : aAssigned
              ? -1
              : 0;
    });

    setState(() => visibleList = filtered);
  }

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
        widget.task.assignees.remove(member.user.id);
      });
      updateList(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                ),
                child: Text(
                  S.of(context).responsiblePersons,
                  style: TextStyle(
                    fontFamily: 'SFProText',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SearchBarWidget(
            onChanged: updateList,
            controller: controller,
            isDark: isDark,
            hintText: S.of(context).enterYourEmailAddressOrName,
          ),

          Flexible(
              child: ListView.builder(
            controller: scrollController,
            itemCount: visibleList.isEmpty ? 1 : visibleList.length,
            itemBuilder: (context, index) {
              if (visibleList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Center(
                    child: Text(
                      controller.text.isEmpty
                          ? S.of(context).thereAreNoDesignatedParticipants
                          : S.of(context).noOneHasBeenFound,
                    ),
                  ),
                );
              }

              final member = visibleList[index];
              final assigned =
                  widget.task.assignees.keys.contains(member.user.id);
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (member.user.photoUrl != null &&
                          member.user.photoUrl!.trim().isNotEmpty &&
                          member.user.photoUrl!.startsWith('http'))
                      ? NetworkImage(member.user.photoUrl!)
                      : null,
                  child: (member.user.photoUrl == null ||
                          member.user.photoUrl!.trim().isEmpty ||
                          !member.user.photoUrl!.startsWith('http'))
                      ? (member.user.displayName.isNotEmpty
                          ? Text(
                              member.user.displayName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            )
                          : const Icon(Icons.person, color: Colors.white))
                      : null,
                ),
                // title: Text(member.user.displayName),
                title: Text(
                  member.user.displayName == ""
                      ? 'No name'
                      : member.user.displayName,
                  style: TextStyle(
                    fontFamily: 'SFProText',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  member.user.email,
                  style: TextStyle(
                    fontFamily: 'SFProText',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Icon(
                  assigned ? Icons.check : null,
                  color: assigned ? Colors.green : Colors.redAccent.shade400,
                ),
                onTap: () async {
                  if (userRole != 'viewer12') {
                    if (assigned) {
                      // _confirmRemove(member);

                      await widget.boardProvider.removeAssigneeFromTask(
                        widget.board,
                        widget.cardId,
                        widget.task.id,
                        member.user.id,
                      );
                      setState(() {
                        widget.task.assignees.remove(member.user.id);
                      });
                      updateList(controller.text);
                    } else {
                      await widget.boardProvider.addAssigneeToTask(
                        widget.board,
                        widget.cardId,
                        widget.task.id,
                        member.user.id,
                      );
                      setState(() {
                        widget.task.assignees[member.user.id] = DateTime.now();
                      });
                      updateList(controller.text);
                    }
                  } else {
                    // SnackBarHelper.show(
                    //   context,
                    //   S.of(context).notEnoughRights,
                    //   type: SnackType.error,
                    // );
                  }
                },
              );
            },
          )),
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //     vertical: 25,
          //     horizontal: 10,
          //   ),
          //   child: ListView(
          //     children: [
          //       const SizedBox(height: 10),
          //       if (visibleList.isEmpty)
          //         Text(controller.text.isEmpty
          //             ? 'Нет назначенных участников'
          //             : 'Никто не найден'),
          //       ...visibleList.map((member) {
          //         final assigned =
          //             widget.task.assignees.keys.contains(member.user.id);
          //         return ListTile(
          //           leading: CircleAvatar(
          //             backgroundImage: member.user.photoUrl != null
          //                 // ? NetworkImage(member.user.photoUrl!)
          //                 ? null
          //                 : null,
          //             child: member.user.photoUrl == null
          //                 ? Text(member.user.displayName[0])
          //                 : null,
          //           ),
          //           title: Text(member.user.displayName),
          //           subtitle: Text(member.user.email),
          //           trailing: Icon(assigned ? Icons.remove : Icons.add,
          //               color: assigned ? Colors.red : Colors.green),
          //           onTap: () async {
          //             if (assigned) {
          //               _confirmRemove(member);
          //             } else {
          //               widget.boardProvider.addAssigneeToTask(
          //                 widget.board,
          //                 widget.cardId,
          //                 widget.task.id,
          //                 member.user.id,
          //               );
          //               setState(() {
          //                 widget.task.assignees[member.user.id] =
          //                     DateTime.now();
          //               });
          //               updateList(controller.text);
          //             }
          //           },
          //         );
          //       }),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
