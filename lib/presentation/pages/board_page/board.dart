import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow/core/theme/app_colors.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/card_model.dart';
import 'package:flow/data/models/task_model.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class BoardPage extends StatefulWidget {
  final String boardId;

  const BoardPage({super.key, required this.boardId});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  Timer? _debounce;
  bool _isMinimized = false;

  BoardModel? _board;
  StreamSubscription? _subscription;
  bool _loading = true;

  ScrollController _cardScrollController = ScrollController();
  Map<String, bool> showInputMap = {};
  Map<String, TextEditingController> inputControllers = {};

  @override
  void initState() {
    super.initState();

    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    _cardScrollController = ScrollController();
    _subscription =
        boardProvider.watchBoardById(widget.boardId).listen((boardData) {
      if (mounted) {
        setState(() {
          _board = boardData;
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _subscription?.cancel();
    _cardScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_board == null) {
      return const Scaffold(body: Center(child: Text("Доска не найдена")));
    }

    final board = _board!;
    // Создаем список отсортированных записей
    final sortedCardsEntries = board.cards.entries.toList()
      ..sort((a, b) => a.value.order.compareTo(b.value.order));

    return Scaffold(
      backgroundColor: board.color,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(board.title),
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
        backgroundColor: isDark
            ? const Color.fromARGB(164, 31, 31, 31)
            : const Color.fromARGB(164, 211, 211, 211),
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 100,
              ),
              child: AnimatedScale(
                scale: _isMinimized ? 0.8 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    

                    ...sortedCardsEntries.map((entry) {
                      final card = entry.value;
                      

                      final cardId = entry.key;
                      showInputMap.putIfAbsent(cardId, () => false);
                      inputControllers.putIfAbsent(
                          cardId, () => TextEditingController());

                      return Container(
                        width: 300,
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.only(
                          top: 12.0,
                          left: 12.0,
                          right: 12.0,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF0F0F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        card.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: 0,
                                    maxHeight: size.height * 0.6,
                                  ),
                                  child: Scrollbar(
                                    controller: _cardScrollController,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      controller: _cardScrollController,
                                      child: Column(
                                        children:
                                            card.tasks.entries.map((taskEntry) {
                                          final task = taskEntry.value;
                                          return Card(
                                            color: isDark
                                                ? const Color(0xFF3A3A3D)
                                                : Colors.white,
                                            elevation: 2,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                task.title,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              subtitle: Text(
                                                task.description,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                              onTap: () {
                                                context.push(
                                                  '/board/${widget.boardId}/card/${entry.key}/task/${taskEntry.key}',
                                                );
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),

                                // Анимированный ввод новой задачи
                                if (!showInputMap[card.id]!)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        showInputMap[card.id] =
                                            !showInputMap[card.id]!;
                                        inputControllers[card.id]!.clear();
                                      });
                                    },
                                    child: Text(
                                      "Add Task",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                        fontFamily: 'SFProText',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                if (showInputMap[card.id]!)
                                  const SizedBox(height: 8),

                                Flexible(
                                  child: AnimatedCrossFade(
                                    duration: const Duration(milliseconds: 300),
                                    crossFadeState: showInputMap[card.id]!
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                    firstChild: Column(
                                      children: [
                                        SizedBox(
                                          height: 35,
                                          child: TextField(
                                            controller:
                                                inputControllers[card.id],
                                            style: TextStyle(
                                              fontFamily: 'SFProText',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: isDark
                                                  ? const Color(0xFF3A3A3D)
                                                  : Colors.white,
                                            ),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: isDark
                                                  ? const Color(0xFF3A3A3D)
                                                  : Colors.white,

                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 30,
                                                horizontal: 8,
                                              ), // ⬅️ это важно
                                              isDense:
                                                  true, // ⬅️ уменьшает вертикальные отступы
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton(
                                              style: ButtonStyle(
                                                overlayColor: WidgetStateProperty
                                                    .all(Colors
                                                        .transparent), // Убирает обводку
                                                foregroundColor:
                                                    WidgetStateProperty
                                                        .resolveWith<Color>(
                                                  (states) {
                                                    if (states.contains(
                                                        WidgetState.pressed)) {
                                                      return Colors.black
                                                          .withOpacity(
                                                              0.6); // Тёмнее при нажатии
                                                    }
                                                    return Theme.of(context)
                                                        .colorScheme
                                                        .primary; // Обычный цвет текста
                                                  },
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() =>
                                                    showInputMap[card.id] =
                                                        false);
                                                inputControllers[card.id]!
                                                    .clear();
                                              },
                                              child: Text(
                                                S.of(context).cancel,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontFamily: 'SFProText',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              style: ButtonStyle(
                                                overlayColor: WidgetStateProperty
                                                    .all(Colors
                                                        .transparent), // Убирает обводку
                                                foregroundColor:
                                                    WidgetStateProperty
                                                        .resolveWith<Color>(
                                                  (states) {
                                                    if (states.contains(
                                                        WidgetState.pressed)) {
                                                      return Colors.black
                                                          .withOpacity(
                                                              0.6); // Тёмнее при нажатии
                                                    }
                                                    return Theme.of(context)
                                                        .colorScheme
                                                        .primary; // Обычный цвет текста
                                                  },
                                                ),
                                              ),
                                              onPressed: () async {
                                                final text =
                                                    inputControllers[card.id]!
                                                        .text
                                                        .trim();
                                                if (text.isEmpty) return;

                                                final newTaskId =
                                                    FirebaseFirestore.instance
                                                        .collection('dummy')
                                                        .doc()
                                                        .id;
                                                await boardProvider
                                                    .addTaskToCard(
                                                  widget.boardId,
                                                  card.id,
                                                  TaskModel(
                                                    id: newTaskId,
                                                    title: text,
                                                    description: '',
                                                    isDone: false, order: board.cards[cardId]!.tasks.length, assignees: {},
                                                    
                                                  ),
                                                );
                                                inputControllers[card.id]!
                                                    .clear();
                                                setState(() =>
                                                    showInputMap[card.id] =
                                                        false);
                                              },
                                              child: Text(
                                                S.of(context).add,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontFamily: 'SFProText',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    secondChild: const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    Container(
                      width: 300,
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final newCardId = FirebaseFirestore.instance
                              .collection('dummy')
                              .doc()
                              .id;

                          final newCard = CardModel(
                            id: newCardId,
                            title: "Новая карточка",
                            tasks: {},
                            order: _board!.cards.length,
                          );

                          await boardProvider.addCardToBoard(
                              widget.boardId, newCard);

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Карточка добавлена')),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Добавить"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                          backgroundColor: isDark
                              ? const Color.fromARGB(164, 31, 31, 31)
                              : const Color.fromARGB(164, 211, 211, 211),
                          foregroundColor:
                              isDark ? Colors.white : Colors.black87,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 40,
        width: 40,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isMinimized = !_isMinimized;
            });
          },
          backgroundColor: const Color.fromARGB(183, 0, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(
              _isMinimized ? Icons.zoom_in_rounded : Icons.zoom_out_rounded),
        ),
      ),
    );
  }
}


