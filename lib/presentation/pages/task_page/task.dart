import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/widgets/date_time_picker.dart';
import 'package:flow/presentation/widgets/rounded_container.dart';
import 'package:flutter/material.dart';
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
  DateTime? startDate;
  DateTime? dueDate;
  bool _isDone = false;
  bool _isInitialized = false;

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

  Future<void> _saveTask(BoardProvider provider, int order) async {
    final updatedTask = TaskModel(
      id: widget.taskId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isDone: _isDone,
      startDate: startDate,
      dueDate: dueDate,
      order: order,
    );

    await provider.updateTask(
      widget.boardId,
      widget.cardId,
      updatedTask,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).changesSaved)),
    );
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoardProvider>(context, listen: false);
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

        if (task == null) {
          return const Scaffold(body: Center(child: Text('Задача не найдена')));
        }

        if (!_isInitialized && task != null) {
          startDate = task.startDate;
          dueDate = task.dueDate;
          _loadTaskData(task);
          _isInitialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).editTask(task.title)),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  await _saveTask(provider, task.order);
                },
              ),
            ],
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
                        // Container(
                        //   width: 320,
                        //   decoration: BoxDecoration(
                        //     color: isDark
                        //         ? const Color(0xFF333333)
                        //         : const Color(0xFFF0F0F0),
                        //     borderRadius: BorderRadius.circular(25),
                        //   ),
                        //   child: Theme(
                        //     data: Theme.of(context).copyWith(
                        //       unselectedWidgetColor:
                        //           isDark ? Colors.white54 : Colors.black54,
                        //     ),
                        //     child: CheckboxListTile(
                        //       value: _isDone,
                        //       onChanged: (bool? value) async {
                        //         setState(() {
                        //           _isDone = value ?? false;
                        //         });
                        //         final updatedTask = TaskModel(
                        //           id: widget.taskId,
                        //           title: _titleController.text.trim(),
                        //           description:
                        //               _descriptionController.text.trim(),
                        //           isDone: _isDone,
                        //           startDate: startDate,
                        //           dueDate: dueDate,
                        //           order: task.order,
                        //         );

                        //         await provider.updateTask(
                        //           widget.boardId,
                        //           widget.cardId,
                        //           updatedTask,
                        //         );
                        //       },
                        //       title: Text(
                        //         S.of(context).complete,
                        //         style: TextStyle(
                        //           color: isDark ? Colors.white : Colors.black,
                        //           fontWeight: FontWeight.w600,
                        //         ),
                        //       ),
                        //       activeColor:
                        //           Theme.of(context).colorScheme.primary,
                        //       checkColor: Colors.white,
                        //       controlAffinity: ListTileControlAffinity.leading,
                        //       contentPadding:
                        //           const EdgeInsets.symmetric(horizontal: 16),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(25),
                        //       ),
                        //     ),
                        //   ),
                        // ),
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
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 12),
                    //   child: RoundedContainerCustom(
                    //     isDark: isDark,
                    //     padding: const EdgeInsets.symmetric(horizontal: 10),
                    //     childWidget: SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: GestureDetector(
                    //         onTap: () async {
                    //           // showManageMembersModal(context, widget.board);
                    //           await provider.getValidTaskAssignees(board.id, card!.id, task.id);
                    //         },
                    //         child: Text("123")),
                    //   ),
                    // ),
                    //   ),
                    // ),

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

                    const SizedBox(height: 270), // отступ перед кнопкой
                    SizedBox(
                      width: 320,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () =>
                            _deleteTask(widget.cardId, widget.taskId, isDark),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          // body: Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Column(
          //     children: [
          //       TextField(
          //         controller: _titleController,
          //         decoration: const InputDecoration(labelText: 'Название задачи'),
          //       ),
          //       const SizedBox(height: 16),
          //       TextField(
          //         controller: _descriptionController,
          //         decoration: const InputDecoration(labelText: 'Описание'),
          //         maxLines: 4,
          //       ),
          //       const SizedBox(height: 16),
          //       CheckboxListTile(
          //         title: const Text('Завершена'),
          //         value: _isDone,
          //         onChanged: (val) => setState(() => _isDone = val ?? false),
          //       ),
          //     ],
          //   ),
          // ),
        );
      },
    );
  }
}
