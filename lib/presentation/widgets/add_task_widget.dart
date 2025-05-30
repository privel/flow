import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow/core/theme/app_ext.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/widgets/date_time_picker.dart';
import 'package:flow/presentation/widgets/drop_down_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Size size;
  final List<BoardModel> boards;

  const AddTaskBottomSheet({
    required this.scrollController,
    required this.size,
    required this.boards,
    super.key,
  });

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  String? selectedBoardId;
  String? selectedCardId;
  String taskTitle = '';
  DateTime? startDate;
  DateTime? dueDate;

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _actionKey = GlobalKey();
  bool isDropdownOpen = false;

  OverlayEntry? _overlayEntry2;
  final LayerLink _layerLink2 = LayerLink();
  final GlobalKey _actionKey2 = GlobalKey();
  bool isDropdownOpen2 = false;

  final ScrollController _cardListController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _closeDropdowns() {
    if (isDropdownOpen) {
      _overlayEntry?.remove();
      isDropdownOpen = false;
    }
    if (isDropdownOpen2) {
      _overlayEntry2?.remove();
      isDropdownOpen2 = false;
    }
  }

  void _toggleDropdownBoard(BuildContext context) {
    _closeDropdowns();

    final RenderBox renderBox =
        _actionKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 6,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 6),
          child: Material(
            color: Theme.of(context).cardColor,
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Scrollbar(
                controller: _cardListController,
                thumbVisibility: true,
                thickness: 2,
                radius: const Radius.circular(6),
                child: ListView.builder(
                  controller: _cardListController,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: widget.boards.length,
                  itemBuilder: (context, index) {
                    final board = widget.boards[index];
                    return ListTile(
                      title: Text(
                        board.title,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      hoverColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      onTap: () {
                        setState(() {
                          selectedBoardId = board.id;
                          selectedCardId = null;
                          isDropdownOpen = false;
                        });
                        _overlayEntry?.remove();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    isDropdownOpen = true;
  }

  void _toggleDropdownCard(BuildContext context, List selectedCards) {
    _closeDropdowns();

    final RenderBox renderBox =
        _actionKey2.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final double itemHeight = 48.0;
    final double maxHeight = 200.0;
    final double calculatedHeight = selectedCards.isEmpty
        ? 60
        : (selectedCards.length * itemHeight).clamp(60, maxHeight).toDouble();

    final newOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 6,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink2,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 6),
          child: Material(
            color: Theme.of(context).cardColor,
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: calculatedHeight,
              ),
              child: selectedCards.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Нет карточек',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      thickness: 2,
                      controller: _cardListController,
                      radius: const Radius.circular(6),
                      child: ListView.builder(
                        controller: _cardListController,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: selectedCards.length,
                        itemBuilder: (context, index) {
                          final card = selectedCards[index];
                          return ListTile(
                            title: Text(
                              card.title,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                            hoverColor: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                            onTap: () {
                              setState(() {
                                selectedCardId = card.id;
                                isDropdownOpen2 = false;
                              });
                              _overlayEntry2?.remove();
                            },
                          );
                        },
                      ),
                    ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(newOverlay);
    _overlayEntry2 = newOverlay;
    isDropdownOpen2 = true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBoard = widget.boards.firstWhere(
        (b) => b.id == selectedBoardId,
        orElse: () => BoardModel.empty());

    final selectedCards = selectedBoard.cards.values.toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.close,
                  color: Theme.of(context)
                      .extension<AppColorsExtension>()
                      ?.mainText),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              onPressed: () async {
                if (selectedBoardId != null &&
                    selectedCardId != null &&
                    taskTitle.isNotEmpty) {
                  try {
                    final boardProvider = context.read<BoardProvider>();
                    final selectedBoard = widget.boards
                        .firstWhere((b) => b.id == selectedBoardId);
                    final selectedCard = selectedBoard.cards[selectedCardId];
                    final taskCount = selectedCard?.tasks.length ?? 0;

                    final task = TaskModel(
                      id: FirebaseFirestore.instance
                          .collection('dummy')
                          .doc()
                          .id,
                      title: taskTitle,
                      description: '',
                      isDone: false,
                      startDate: startDate,
                      dueDate: dueDate,
                      order: taskCount + 1,
                    );

                    await boardProvider.addTaskToCard(
                      selectedBoardId!,
                      selectedCardId!,
                      task,
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    // debugPrint('Ошибка при добавлении задачи: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context).couldntAddTask),
                      ),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).save,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              children: [
                SizedBox(height: widget.size.height * 0.03),
                CompositedTransformTarget(
                  link: _layerLink,
                  child: GestureDetector(
                    key: _actionKey,
                    onTap: () => _toggleDropdownBoard(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedBoardId != null
                                ? widget.boards
                                    .firstWhere((b) => b.id == selectedBoardId)
                                    .title
                                : "Выберите доску",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (selectedBoardId != null)
                  CompositedTransformTarget(
                    link: _layerLink2,
                    child: GestureDetector(
                      key: _actionKey2,
                      onTap: () => _toggleDropdownCard(context, selectedCards),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedCardId != null
                                  ? selectedCards
                                      .firstWhere((c) => c.id == selectedCardId)
                                      .title
                                  : "Выберите карточку",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      child: TextField(
                        controller: _titleController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        cursorWidth: 1.5,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: S.of(context).nameTask,
                          hintStyle: const TextStyle(color: Colors.grey),
                          isDense: true,
                          fillColor: isDark
                              ? const Color(0xFF333333)
                              : const Color(0xFFF0F0F0),
                        ),
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
                      // Убери фиксированную высоту!
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
