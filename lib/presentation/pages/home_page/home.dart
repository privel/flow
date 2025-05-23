import 'package:flow/core/theme/app_ext.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/pages/account_page/account_layout.dart';
import 'package:flow/presentation/pages/home_page/home_layout.dart';
import 'package:flow/presentation/widgets/horizontal_datapicker.dart';
import 'package:flow/presentation/widgets/search_bar.dart';
import 'package:flow/presentation/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0; // 0 = Team, 1 = Personal
  final TextEditingController _searchController = TextEditingController();

  late Stream<List<BoardModel>> boardStream;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final userId = auth.user?.uid;
    boardStream = boardProvider.watchBoards(userId ?? '');
  }

  Future<void> _onRefresh() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final userId = auth.user?.uid;

    setState(() {
      boardStream = boardProvider.watchBoards(userId ?? '');
    });

    await Future.delayed(const Duration(milliseconds: 500));
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  Future<void> addBoardSample(context, String nameBoard) async {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final newBoard = BoardModel(
      id: '', // Firestore сам сгенерирует
      title: nameBoard,
      ownerId: auth.user!.uid,
      sharedWith: {},
      cards: {},
    );

    await boardProvider.createBoard(newBoard);
    if (!context.mounted) return;

    SnackBarHelper.show(context, "Сохранено");
  }

  void showBottomModalAddBoard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final initialName = (auth.user?.displayName?.trim().isNotEmpty ?? false)
        ? auth.user!.displayName!
        : 'No Name';

    TextEditingController nameBoard = TextEditingController();

    //Theme.of(context).extension<AppColorsExtension>()?.mainText

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFD3D3D3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
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
                                await addBoardSample(context, nameBoard.text);
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
                        SizedBox(height: size.height * 0.03),
                        SizedBox(
                          width: 300,
                          height: 50,
                          child: TextField(
                            controller: nameBoard,
                            maxLength: 20,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            cursorColor: isDark ? Colors.white : Colors.black,
                            decoration: InputDecoration(
                              counterText: "",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              hintText: S.of(context).newBoard,
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey : Colors.black54,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.white : Colors.black,
                                  width: 1, // Можно толще
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showBottomModalEdit(BuildContext context, BoardModel boardmodel) {
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final initialName = (auth.user?.displayName?.trim().isNotEmpty ?? false)
        ? auth.user!.displayName!
        : 'No Name';

    TextEditingController nameBoard = TextEditingController();
    nameBoard.text = boardmodel.title;

    //Theme.of(context).extension<AppColorsExtension>()?.mainText

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFD3D3D3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
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
                                // await addBoardSample(context, nameBoard.text);
                                await Provider.of<BoardProvider>(context, listen: false).updateBoard(
                                  BoardModel(
                                    id: boardmodel.id,
                                    title: nameBoard.text,
                                    ownerId: boardmodel.ownerId,
                                    sharedWith: boardmodel.sharedWith,
                                    cards: boardmodel.cards,
                                  ),
                                );
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
                        SizedBox(height: size.height * 0.03),
                        SizedBox(
                          width: 300,
                          height: 50,
                          child: TextField(
                            controller: nameBoard,
                            maxLength: 20,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            cursorColor: isDark ? Colors.white : Colors.black,
                            decoration: InputDecoration(
                              counterText: "",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              hintText: S.of(context).newBoard,
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey : Colors.black54,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.white : Colors.black,
                                  width: 1, // Можно толще
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamItems = List.generate(5, (i) => 'Team Project ${i + 1}');
    final personalItems = List.generate(3, (i) => 'Personal Task ${i + 1}');

    final visibleItems = selectedIndex == 0 ? teamItems : personalItems;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final userId = auth.user?.uid;

    if (userId == null) {
      return const Center(child: Text("Пользователь не авторизован"));
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    HomeLayout homeLayout = HomeLayout(isMobile, isTablet);

    return Scaffold(
      appBar: isMobile || isTablet
          ? AppBar(
              actions: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTapDown: (TapDownDetails details) async {
                      final tapPosition = details.globalPosition;

                      final value = await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          tapPosition.dx,
                          tapPosition.dy + 10,
                          tapPosition.dx,
                          tapPosition.dy,
                        ),
                        items: [
                          PopupMenuItem(
                            value: 'create_board',
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: SizedBox(
                              height: 36,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    S.of(context).createBoard,
                                    style: AccountLayout.CardSubTitle.copyWith(
                                      color: Theme.of(context)
                                          .extension<AppColorsExtension>()
                                          ?.mainText,
                                    ),
                                  ),
                                  const Icon(Icons.table_rows_outlined),
                                ],
                              ),
                            ),
                          ),
                          const PopupMenuItem(
                            enabled: false,
                            height: 1,
                            padding: EdgeInsets.zero,
                            child: Divider(
                              thickness: 0.4,
                              height: 1,
                              color: Colors.grey,
                              indent: 5,
                              endIndent: 5,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'create_card',
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: SizedBox(
                              height: 36,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    S.of(context).createCard,
                                    style: AccountLayout.CardSubTitle.copyWith(
                                      color: Theme.of(context)
                                          .extension<AppColorsExtension>()
                                          ?.mainText,
                                    ),
                                  ),
                                  const Icon(Icons.table_rows_outlined),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );

                      if (value == 'create_board') {
                        showBottomModalAddBoard(context);
                      } else if (value == 'create_card') {
                        // ...
                      }
                    },
                    child: Icon(
                      Icons.add,
                      color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                    ),
                  ),
                ),
              ],
              title: Image.asset(
                "assets/image/logo/logoFlowApp2.png",
                scale: homeLayout.ImageScaleIcon,
              ),
              backgroundColor:
                  isDark ? const Color(0xFF1F1F1F) : const Color(0xFFD3D3D3),
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor:
                    isDark ? const Color(0xFF1F1F1F) : const Color(0xFFD3D3D3),
                statusBarIconBrightness: Brightness.light,
              ),
            )
          : null,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              SearchBarWidget(
                controller: _searchController,
                isDark: isDark,
              ),
              
              const SizedBox(height: 16),
              Text(
                "YOUR WORKSPACES",
                style: HomeLayout(isMobile, isTablet).h2Style,
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<BoardModel>>(
                // stream: boardProvider.watchBoards(userId),
                stream: boardStream,
                builder: (context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return const Center(child: CircularProgressIndicator());
                  // }
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Нет досок");
                  }

                  final boards = snapshot.data!;
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: boards.length,
                    itemBuilder: (context, index) {
                      final board = boards[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            // context.go('/board/${board.id}');
                            context.goNamed('boardtest2', pathParameters: {'id': board.id});

                          },
                          onTapDown: (TapDownDetails details) async {
                            final tapPosition = details.globalPosition;

                            final value = await showMenu<String>(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                tapPosition.dx,
                                tapPosition.dy + 10,
                                tapPosition.dx,
                                tapPosition.dy,
                              ),
                              items: [
                                PopupMenuItem(
                                  value: 'edit',
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: SizedBox(
                                    height: 36,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Редактировать",
                                          style: AccountLayout.CardSubTitle
                                              .copyWith(
                                            color: Theme.of(context)
                                                .extension<AppColorsExtension>()
                                                ?.mainText,
                                          ),
                                        ),
                                        const Icon(IconlyLight.edit),
                                      ],
                                    ),
                                  ),
                                ),
                                const PopupMenuItem(
                                  enabled: false,
                                  height: 1,
                                  padding: EdgeInsets.zero,
                                  child: Divider(
                                    thickness: 0.4,
                                    height: 1,
                                    color: Colors.grey,
                                    indent: 5,
                                    endIndent: 5,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: SizedBox(
                                    height: 36,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Удалить",
                                          style: AccountLayout.CardSubTitle
                                              .copyWith(
                                            color: Theme.of(context)
                                                .extension<AppColorsExtension>()
                                                ?.mainText,
                                          ),
                                        ),
                                        const Icon(IconlyLight.delete),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );

                            if (value == 'edit') {
                              // await boardProvider.updateBoard(
                              //   BoardModel(
                              //     id: board.id,
                              //     title: "3322",
                              //     ownerId: board.ownerId,
                              //     sharedWith: board.sharedWith,
                              //     cards: board.cards,
                              //   ),
                              // );

                              showBottomModalEdit(
                                context,
                                BoardModel(
                                  id: board.id,
                                  title: board.title,
                                  ownerId: board.ownerId,
                                  sharedWith: board.sharedWith,
                                  cards: board.cards,
                                ),
                              );
                            } else if (value == 'delete') {
                              await boardProvider.deleteBoard(board.id);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              title: Text(
                                board.title,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1F1F1F),
                                ),
                              ),
                              trailing: Container(
                                height: 45,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: board.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
