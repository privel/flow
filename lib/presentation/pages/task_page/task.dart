import 'dart:async';
import 'dart:typed_data';

import 'package:flow/core/utils/picker_file_image/picker.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/role_model.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/widgets/assigne_bottom_widget.dart';
import 'package:flow/presentation/widgets/date_time_picker.dart';
import 'package:flow/presentation/widgets/rounded_container.dart';
import 'package:flow/presentation/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:uuid/uuid.dart';

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
  final Picker _customPicker = Picker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String? UserRole;
  DateTime? startDate;
  DateTime? dueDate;
  bool _isDone = false;
  bool _isInitialized = false;
  late Future<List<BoardMember>> futureMembers;
  String _initialTitle = '';
  String _initialDescription = '';

  Timer? _debounceTimer;

  Map<String, Map<String, dynamic>> _initialImages = {};
  Map<String, Map<String, dynamic>> _currentImages = {};

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onInputChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Запускаем новый таймер на 2-3 секунды
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _performAutoSave();
    });
  }

  void _onTitleChanged() {
    _onInputChanged();
  }

  void _onDescriptionChanged() {
    _onInputChanged();
  }

  Future<void> _performAutoSave() async {
    final provider = Provider.of<BoardProvider>(context, listen: false);

    final board = await provider.getBoardById(widget.boardId);
    final card = board?.cards[widget.cardId];
    final task = card?.tasks[widget.taskId];

    if (task == null) {
      debugPrint('Ошибка: Задача не найдена для автосохранения.');
      return;
    }

    // Проверяем, изменились ли заголовок или описание
    final bool titleChanged =
        _titleController.text.trim() != _initialTitle.trim();
    final bool descriptionChanged =
        _descriptionController.text.trim() != _initialDescription.trim();
    final bool imagesChanged = !_areMapsEqual(_currentImages, _initialImages);

    // Если ничего не изменилось, просто выходим
    if (!titleChanged && !descriptionChanged && !imagesChanged) {
      // print(
      //     'Автосохранение: Изменений в заголовке или описании не обнаружено.');
      return;
    }

    final updatedTask = TaskModel(
      id: widget.taskId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isDone: _isDone,
      startDate: startDate,
      dueDate: dueDate,
      assignees: task.assignees,
      order: task.order,
      images: _currentImages,
    );

    await provider.updateTask(
      widget.boardId,
      widget.cardId,
      updatedTask,
    );

    if (!mounted) return;

    // После успешного сохранения, обновляем исходные значения
    _initialTitle = _titleController.text.trim();
    _initialDescription = _descriptionController.text.trim();
    _initialImages = Map.from(_currentImages);

    // SnackBarHelper.show(context, S.of(context).changesSaved,
    //     type: SnackType.success);
    // print(
    //     'Автоматическое сохранение данных: Заголовок: ${_titleController.text}, Описание: ${_descriptionController.text}');
  }

  bool _areMapsEqual(Map<String, Map<String, dynamic>> map1,
      Map<String, Map<String, dynamic>> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      final val1 = map1[key]!;
      final val2 = map2[key]!;

      // Проверяем все поля внутри вложенного Map
      if (val1['url'] != val2['url'] ||
          (val1['dateAdded'] as DateTime).millisecondsSinceEpoch !=
              (val2['dateAdded'] as DateTime).millisecondsSinceEpoch ||
          val1['order'] != val2['order']) {
        return false;
      }
    }
    return true;
  }

  List<Map<String, dynamic>> _getSortedImages() {
    final List<String> sortedKeys = _currentImages.keys.toList()
      ..sort((a, b) {
        final DateTime dateA = _currentImages[a]!['dateAdded'] as DateTime;
        final DateTime dateB = _currentImages[b]!['dateAdded'] as DateTime;
        return dateB.compareTo(
            dateA); // Сортируем от новых к старым (убывающий порядок)
      });

    return sortedKeys
        .map((key) => {
              'id': key, // Сохраняем ID, если он нужен в ImageViewerPage
              'url': _currentImages[key]!['url'],
              'dateAdded': _currentImages[key]!['dateAdded'],
              'order': _currentImages[key]!['order'],
            })
        .toList();
  }

  // --- Методы для работы с изображениями ---
  Future<void> _pickAndUploadImage() async {
    if (UserRole == 'viewer') return;

    // Используем ваш кастомный Picker
    final Uint8List? pickedBytes = await _customPicker.pickImageBytes(context);

    if (pickedBytes != null) {
      final boardProvider = Provider.of<BoardProvider>(context, listen: false);
      // Загружаем изображение в Supabase Storage через BoardProvider
      final imageUrl =
          await boardProvider.uploadTaskImage(widget.taskId, pickedBytes);

      if (imageUrl != null) {
        final imageId = const Uuid().v4();

        setState(() {
          _currentImages[imageId] = {
            'url': imageUrl,
            'dateAdded': DateTime.now(),
            'order':
                _currentImages.length, // Простой порядок по индексу добавления
          };
        });
        _onInputChanged();
      } else {
        SnackBarHelper.show(context, 'Ошибка при загрузке изображения.',
            type: SnackType.error);
      }
    }
  }

  void _removeImage(String imageId) async {
    if (UserRole == 'viewer') return;

    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final imageData = _currentImages[imageId];

    setState(() {
      _currentImages.remove(imageId);
      _reorderImages();
    });

    // Удаляем изображение из Supabase Storage
    if (imageData != null) {
      await boardProvider.deleteTaskImage(widget.taskId, imageId);
    }

    _onInputChanged();
  }

  void _reorderImages() {
    final sortedKeys = _currentImages.keys.toList()
      ..sort((a, b) => (_currentImages[a]!['order'] as int)
          .compareTo(_currentImages[b]!['order'] as int));

    for (int i = 0; i < sortedKeys.length; i++) {
      _currentImages[sortedKeys[i]]!['order'] = i;
    }
  }

  void _loadTaskData(TaskModel task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _isDone = task.isDone;

    _initialTitle = task.title;
    _initialDescription = task.description;
    _initialImages = Map.from(task.images);
    _currentImages = Map.from(task.images);
  }

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

    // if (!mounted) return;
    // Navigator.pop(context);
    // SnackBarHelper.show(context, S.of(context).changesSaved,
    //     type: SnackType.success);
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
                        : const Icon(Icons.person)
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

    return StreamBuilder<BoardModel?>(
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

        final List<Map<String, dynamic>> sortedImages = _getSortedImages();

        if (task == null) {
          return const Scaffold(body: Center(child: Text('Задача не найдена')));
        }

        if (!_isInitialized && task != null) {
          startDate = task.startDate;
          dueDate = task.dueDate;
          _loadTaskData(task);
          futureMembers = provider.loadBoardUsers(board, auth);
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
                            onDateTimeSelected: (picked) async {
                              FocusScope.of(context).unfocus();
                              setState(() => startDate = picked);
                              // _performAutoSave();

                              if (task == null) {
                                debugPrint(
                                    'Ошибка: Задача не найдена для автосохранения.');
                                return;
                              }

                            

                              final updatedTask = TaskModel(
                                id: widget.taskId,
                                title: _titleController.text.trim(),
                                description: _descriptionController.text.trim(),
                                isDone: _isDone,
                                startDate: picked,
                                dueDate: dueDate,
                                assignees: task.assignees,
                                order: task.order,
                                images: _currentImages,
                              );

                              await provider.updateTask(
                                widget.boardId,
                                widget.cardId,
                                updatedTask,
                              );

                              if (!mounted) return;
                            },
                          ),
                          DateTimePickerWidget(
                            label: S.of(context).dueDate,
                            initialDateTime: dueDate,
                            onDateTimeSelected: (picked) async{
                              FocusScope.of(context).unfocus();
                              setState(() => dueDate = picked);



                              if (task == null) {
                                debugPrint(
                                    'Ошибка: Задача не найдена для автосохранения.');
                                return;
                              }

                            

                              final updatedTask = TaskModel(
                                id: widget.taskId,
                                title: _titleController.text.trim(),
                                description: _descriptionController.text.trim(),
                                isDone: _isDone,
                                startDate: startDate,
                                dueDate: picked,
                                assignees: task.assignees,
                                order: task.order,
                                images: _currentImages,
                              );

                              await provider.updateTask(
                                widget.boardId,
                                widget.cardId,
                                updatedTask,
                              );

                              if (!mounted) return;
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
                                IconlyLight.user,
                                size: 18.0,
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
                            height: 15,
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
                                  style: TextStyle(
                                    fontFamily: 'SFProText',
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
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
                    const SizedBox(height: 20),
                    RoundedContainerCustom(
                      isDark: isDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 15,
                      ),
                      width: 320,
                      childWidget: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file_rounded,
                                size: 18.0,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                S.of(context).attachments,
                                style: TextStyle(
                                  fontFamily: 'SFProText',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const Spacer(),
                              if (UserRole != 'viewer')
                                InkWell(
                                  onTap: () {
                                    _pickAndUploadImage();
                                  },
                                  // ignore: deprecated_member_use
                                  splashColor: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.add,
                                      size: 25.0,
                                      color: Color(0xFF1EBA55),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Divider(
                            color: isDark ? Colors.white30 : Colors.black26,
                            thickness: 1.2,
                            height: 20,
                          ),
                          if (_currentImages.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            // Отображение списка изображений
                            SizedBox(
                              // Оберните ListView.builder в SizedBox с фиксированной высотой
                              height:
                                  120, // Задайте желаемую высоту для горизонтального списка
                              child: ListView.builder(
                                scrollDirection:
                                    Axis.horizontal, // Горизонтальная прокрутка
                                itemCount: sortedImages
                                    .length, // Используем отсортированный список
                                itemBuilder: (context, index) {
                                  final imageData = sortedImages[index];
                                  final imageUrl = imageData['url'] as String;
                                  final imageId = imageData['id']
                                      as String; // Получаем imageId
                                  final dateAdded =
                                      imageData['dateAdded'] as DateTime;

                                  return GestureDetector(
                                    onTap: () {
                                      // Переход на страницу просмотра изображений
                                      context.go(
                                        '/board/${widget.boardId}/card/${widget.cardId}/task/${widget.taskId}/view-images?initialIndex=${index.toString()}',
                                        extra:
                                            sortedImages, // Передаем весь отсортированный список
                                      );
                                    },
                                    // !!! ВОТ ЗДЕСЬ ДОБАВЛЯЕМ SizedBox для задания ширины элемента !!!
                                    child: SizedBox(
                                      width:
                                          120, // Установите желаемую ширину для каждой картинки. Например, 120, чтобы она соответствовала высоте.
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal:
                                                5.0), // Отступ между картинками
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Hero(
                                              // Добавляем Hero для плавного перехода
                                              tag:
                                                  imageUrl, // Уникальный тег для Hero
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Center(
                                                        child: Icon(Icons
                                                            .broken_image)),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: UserRole != 'viewer'
                                                  ? IconButton(
                                                      icon: const Icon(
                                                          Icons.cancel,
                                                          color: Colors.red),
                                                      onPressed: () =>
                                                          _removeImage(imageId),
                                                    )
                                                  : Container(),
                                            ),
                                            Positioned(
                                              bottom: 5,
                                              left: 5,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                color: Colors.black54,
                                                child: Text(
                                                  '${dateAdded.day}.${dateAdded.month}.${dateAdded.year}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            /*GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: _currentImages.length,
                              itemBuilder: (context, index) {
                                final sortedImageKeys =
                                    _currentImages.keys.toList()
                                      ..sort((a, b) {
                                        // Получаем DateTime объекты для сравнения
                                        final DateTime dateA =
                                            _currentImages[a]!['dateAdded']
                                                as DateTime;
                                        final DateTime dateB =
                                            _currentImages[b]!['dateAdded']
                                                as DateTime;
                                        // Сортируем от новых к старым (убывающий порядок)
                                        return dateB.compareTo(dateA);
                                      });
                                final imageId = sortedImageKeys[index];
                                final imageData = _currentImages[imageId]!;
                                final imageUrl = imageData['url'] as String;
                                final dateAdded =
                                    imageData['dateAdded'] as DateTime;

                                return Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Используем Image.network для отображения URL из Supabase
                                      Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Center(
                                                child:
                                                    Icon(Icons.broken_image)),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: UserRole != 'viewer'
                                            ? IconButton(
                                                icon: const Icon(Icons.cancel,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _removeImage(imageId),
                                              )
                                            : Container(),
                                      ),
                                      Positioned(
                                        bottom: 5,
                                        left: 5,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          color: Colors.black54,
                                          child: Text(
                                            '${dateAdded.day}.${dateAdded.month}.${dateAdded.year}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            */
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
