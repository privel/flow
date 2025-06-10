import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/role_model.dart';
import 'package:flow/data/models/user_models.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/widgets/assigne_bottom_widget.dart';
import 'package:flow/presentation/widgets/date_time_picker.dart';
import 'package:flow/presentation/widgets/rounded_container.dart';
import 'package:flow/presentation/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/task_model.dart';

class TaskDetailPage extends StatefulWidget {
  final String boardId;
  final String cardId;
  final String taskId;

  const TaskDetailPage(
      {super.key,
      required this.boardId,
      required this.cardId,
      required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String? UserRole;
  DateTime? startDate;
  DateTime? dueDate;
  bool _isDone = false;
  bool _isInitialized = false;
  late Future<List<BoardMember>> futureMembers;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadTaskData(TaskModel task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _isDone = task.isDone;
  }

  // Future<void> _saveTask(BoardProvider provider, int order) async {
  //   final updatedTask = TaskModel(
  //     id: widget.taskId,
  //     title: _titleController.text.trim(),
  //     description: _descriptionController.text.trim(),
  //     isDone: _isDone,
  //   );

  //   await provider.updateTask(
  //     widget.boardId,
  //     widget.cardId,
  //     updatedTask,
  //   );

  //   if (!mounted) return;
  //   Navigator.pop(context);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Изменения сохранены')),
  //   );
  // }

  Future<void> _saveTask(
      BoardProvider provider, int order, TaskModel task) async {
    final updatedTask = TaskModel(
      id: widget.taskId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isDone: _isDone,
      startDate: startDate,
      dueDate: dueDate,
      assignees: task.assignees,
      order: order,
    );

    await provider.updateTask(
      widget.boardId,
      widget.cardId,
      updatedTask,
    );

    if (!mounted) return;
    Navigator.pop(context);
    SnackBarHelper.show(context, S.of(context).changesSaved,
        type: SnackType.success);
  }

  Future<void> _deleteTask(String cardId, String taskId, bool isDark) async {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);

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
            child: Text(
              S.of(context).cancel,
              style: TextStyle(
                fontFamily: 'SFProText',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              S.of(context).delete,
              style: TextStyle(
                fontFamily: 'SFProText',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.redAccent.shade400,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await boardProvider.removeTaskFromCard(widget.boardId, cardId, taskId);
      if (mounted) Navigator.pop(context); // Закрыть после удаления
    }
  }

  void showAssigneeBottomSheet({
    required BuildContext context,
    required BoardModel board,
    required String cardId,
    required TaskModel task,
    required bool isDark,
  }) {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161616) : const Color(0xFFD3D3D3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return AssigneeBottomSheetContent(
                  board: board,
                  cardId: cardId,
                  task: task,
                  boardProvider: boardProvider,
                  auth: auth,
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<BoardMember> getAssignees(
      List<BoardMember> members, Map<String, DateTime> assigneesMap) {
    return members
        .where((member) => assigneesMap.containsKey(member.user.id))
        .toList();
  }

  Widget buildUserList(List<BoardMember> members, bool isDark) {
    return Row(
      children: members.map((member) {
        final user = member.user;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 25,
                backgroundImage:
                    (user.photoUrl != null && user.photoUrl!.trim().isNotEmpty)
                        ? NetworkImage(user.photoUrl!)
                        : null,
                child: (user.photoUrl == null || user.photoUrl!.trim().isEmpty)
                    ? (user.displayName != null &&
                            user.displayName.trim().isNotEmpty)
                        ? Text(
                            user.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'SFProText',
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : Icon(Icons.person)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                user.displayName.isNotEmpty ? user.displayName : 'No name',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'SFProText',
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              Text(
                user.email,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontFamily: 'SFProText',
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoardProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: provider.watchBoardById(widget.boardId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final board = snapshot.data!;
        final card = board.cards[widget.cardId];
        final task = card?.tasks[widget.taskId];

        UserRole = provider.getUserRole(board, auth.user?.uid ?? '');

        if (task == null) {
          return const Scaffold(body: Center(child: Text('Задача не найдена')));
        }

        if (!_isInitialized && task != null) {
          startDate = task.startDate;
          dueDate = task.dueDate;
          _loadTaskData(task);
          futureMembers = provider.loadBoardUsers(
              board, Provider.of<AuthProvider>(context, listen: false));
          _isInitialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            // title: Text(S.of(context).editTask(task.title)),
            title: Text(task.title),
            leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(Icons.arrow_back_ios, size: 22),
        ),
            actions: UserRole != 'viewer'
                ? [
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () async {
                        await _saveTask(provider, task.order, task);
                      },
                    ),
                  ]
                : null,
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          S.of(context).title,
                          style: const TextStyle(
                            fontFamily: 'SFProText',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: 320,
                          height: 55,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF333333)
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Checkbox(
                                  value: _isDone,
                                  onChanged: (bool? value) async {
                                    setState(() {
                                      _isDone = value ?? false;
                                    });
                                    final updatedTask = TaskModel(
                                      id: widget.taskId,
                                      title: _titleController.text.trim(),
                                      description:
                                          _descriptionController.text.trim(),
                                      isDone: _isDone,
                                      startDate: startDate,
                                      dueDate: dueDate,
                                      assignees: task.assignees,
                                      order: task.order,
                                    );

                                    await provider.updateTask(
                                      widget.boardId,
                                      widget.cardId,
                                      updatedTask,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _titleController,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  cursorWidth: 1.5,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: S.of(context).nameTask,
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                    isDense: true,
                                    fillColor: isDark
                                        ? const Color(0xFF333333)
                                        : const Color(0xFFF0F0F0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        //Descriptions
                        Text(
                          S.of(context).description,
                          style: const TextStyle(
                            fontFamily: 'SFProText',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 320,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF333333)
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 10),
                          child: TextField(
                            controller: _descriptionController,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            cursorWidth: 1.5,
                            keyboardType: TextInputType.multiline,
                            minLines: 4,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: S.of(context).someDescription,
                              hintStyle: const TextStyle(color: Colors.grey),
                              isDense: true,
                              fillColor: isDark
                                  ? const Color(0xFF333333)
                                  : const Color(0xFFF0F0F0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DateTimePickerWidget(
                            label: S.of(context).startDate,
                            initialDateTime: startDate,
                            onDateTimeSelected: (picked) {
                              FocusScope.of(context).unfocus();
                              setState(() => startDate = picked);
                            },
                          ),
                          DateTimePickerWidget(
                            label: S.of(context).dueDate,
                            initialDateTime: dueDate,
                            onDateTimeSelected: (picked) {
                              FocusScope.of(context).unfocus();
                              setState(() => dueDate = picked);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    RoundedContainerCustom(
                      isDark: isDark,
                      width: 320,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 15,
                      ),
                      childWidget: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people_alt_rounded,
                                size: 15.0,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                S.of(context).members,
                                style: TextStyle(
                                  fontFamily: 'SFProText',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: isDark ? Colors.white30 : Colors.black26,
                            thickness: 1.2,
                            height: 5,
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<List<BoardMember>>(
                            future: futureMembers,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }

                              final members = snapshot.data!;
                              final assigned =
                                  getAssignees(members, task.assignees);

                              if (assigned.isEmpty) {
                                return Text(
                                  S.of(context).thereAreNoResponsiblePeople,
                                  style: const TextStyle(
                                    fontFamily: 'SFProText',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: GestureDetector(
                                  onTap: () {
                                    showAssigneeBottomSheet(
                                      context: context,
                                      board: board, // актуальная доска
                                      cardId: widget.cardId,
                                      task: task,
                                      isDark: isDark,
                                    );
                                  },
                                  child: buildUserList(
                                      assigned,
                                      Theme.of(context).brightness ==
                                          Brightness.dark),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 200),
                    UserRole != "viewer"
                        ? SizedBox(
                            width: 320,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () => _deleteTask(
                                  widget.cardId, widget.taskId, isDark),
                              child: Text(
                                S.of(context).deleteATask,
                                style: TextStyle(
                                  fontFamily: 'SFProText',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
