import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow/presentation/pages/board_page/new_board_after_test/boardWidgetSt.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/card_model.dart' as flow_model;
import 'package:flow/core/utils/provider/board_provider.dart';

class BoardTest2 extends StatefulWidget {
  final String boardId;

  const BoardTest2({Key? key, required this.boardId}) : super(key: key);

  @override
  State<BoardTest2> createState() => _BoardTest2State();
}

class _BoardTest2State extends State<BoardTest2> {
  late BoardProvider boardProvider;
  BoardModel? _boardModel;
  StreamSubscription<BoardModel?>? _subscription;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    boardProvider = Provider.of<BoardProvider>(context, listen: false);

    _subscription = boardProvider.watchBoardById(widget.boardId).listen(
      (board) {
        setState(() {
          _boardModel = board;
          _isLoading = false;
        });
      },
      onError: (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _promptAndAddNewCard(
    BuildContext context,
    String currentBoardId,
    int currentCardCount,
  ) async {
    TextEditingController textController = TextEditingController();
    String? title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Новая колонка"),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: "Введите название колонки"),
        ),
        actions: [
          TextButton(
            child: const Text("Отмена"),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text("Добавить"),
            onPressed: () =>
                Navigator.of(dialogContext).pop(textController.text),
          ),
        ],
      ),
    );

    if (title != null && title.isNotEmpty) {
      final newCardId = FirebaseFirestore.instance.collection('dummy').doc().id;
      final newOrder = currentCardCount;
      final newCard = flow_model.CardModel(
        id: newCardId,
        title: title,
        tasks: {},
        order: newOrder,
      );

      try {
        await boardProvider.addCardToBoard(currentBoardId, newCard);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Не удалось добавить колонку: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Ошибка: $_error'));
    }

    if (_boardModel == null) {
      return const Center(child: Text('Доска не найдена.'));
    }

    return Scaffold(
      backgroundColor: _boardModel!.color,
      appBar: AppBar(
        title: Text(
          _boardModel!.title,
        ),
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
        actions: [
          IconButton(
            onPressed: () {
              // можно добавить опции
            },
            icon: const Icon(Icons.more_vert_outlined, size: 22),
          ),
        ],
        backgroundColor: isDark
            ? const Color.fromARGB(164, 31, 31, 31)
            : const Color.fromARGB(164, 211, 211, 211),
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric( vertical: 18),
        child: AppFlowyBoardWidget(boardModel: _boardModel!),
      ),
    );
  }
}




/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow/presentation/pages/board_page/new_board_after_test/boardWidgetSt.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/card_model.dart' as flow_model;
import 'package:flow/core/utils/provider/board_provider.dart';

class BoardTest2 extends StatefulWidget {
  final String boardId;

  const BoardTest2({Key? key, required this.boardId}) : super(key: key);

  @override
  State<BoardTest2> createState() => _BoardTest2State();
}

class _BoardTest2State extends State<BoardTest2> {
  Future<void> _promptAndAddNewCard(
      BuildContext context,
      BoardProvider boardProvider,
      String currentBoardId,
      int currentCardCount) async {
    TextEditingController textController = TextEditingController();
    String? title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // Используем dialogContext
        title: const Text("Новая колонка"),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: "Введите название колонки"),
        ),
        actions: [
          TextButton(
            child: const Text("Отмена"),
            onPressed: () =>
                Navigator.of(dialogContext).pop(), // Используем dialogContext
          ),
          TextButton(
            child: const Text("Добавить"),
            onPressed: () => Navigator.of(dialogContext)
                .pop(textController.text), // Используем dialogContext
          ),
        ],
      ),
    );

    if (title != null && title.isNotEmpty) {
      final newCardId = FirebaseFirestore.instance.collection('dummy').doc().id;
      // Новый порядок будет равен текущему количеству карточек (т.е. в конец)
      final newOrder = currentCardCount;
      final newCard = flow_model.CardModel(
        // Используем псевдоним
        id: newCardId,
        title: title,
        tasks: {},
        order: newOrder,
      );
      try {
        await boardProvider.addCardToBoard(currentBoardId, newCard);
      } catch (e) {
        // Обработка ошибок, если нужно
        debugPrint("Ошибка добавления карточки: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Не удалось добавить колонку: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return StreamBuilder<BoardModel?>(
      stream: boardProvider.watchBoardById(widget.boardId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Board not found.'));
        }

        final boardModel = snapshot.data!;
        // Update AppBar title dynamically if needed
        // Example: You might want to lift the AppBar to this page and set its title.
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (mounted && ModalRoute.of(context)?.isCurrent ?? false) {
        //      // Access your AppBar state here if using a custom one or via a provider
        //   }
        // });

        return Scaffold(
          backgroundColor: boardModel.color,

          appBar: AppBar(
            title: Text(boardModel.title),
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
            actions: [
              IconButton(
                onPressed: (){

                },
                icon:const Icon(Icons.more_vert_outlined, size: 22,),
              ),
            ],
            backgroundColor: isDark
                ? const Color.fromARGB(164, 31, 31, 31)
                : const Color.fromARGB(164, 211, 211, 211),
            foregroundColor: isDark ? Colors.white : Colors.black87,
          ),
          // The ResponsiveLayout from your router will handle the AppBar if needed
          body: AppFlowyBoardWidget(boardModel: boardModel),
        );
      },
    );
  }
}
 
 */