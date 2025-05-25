import 'package:flow/core/theme/app_ext.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/pages/account_page/account_layout.dart';
import 'package:flow/presentation/pages/home_page/home_layout.dart';
import 'package:flow/presentation/widgets/add_task_widget.dart';
import 'package:flow/presentation/widgets/color_picker.dart';
import 'package:flow/presentation/widgets/drop_down_widget.dart';
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

  String _searchText = '';

  late Stream<List<BoardModel>> boardStream;
  late List<BoardModel> boardForTask;

  final List<String> ListColorsHex = [
    "11998e",
    "#00B4DB",
    "#b31217",
    "#7AA1D2",
    "#ffa751",
    "#ffe259",
    "#3c1053",
    "#ad5389",
    "#0083B0",
    "#59C173",
    "#45a247",
    "#283c86",
  ];

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

  Color HexToColor(String hexColor) {
    return Color(int.parse('FF${hexColor.replaceAll("#", "")}', radix: 16));
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

  Future<void> addBoardSample(
      context, String nameBoard, String boardColor) async {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final newBoard = BoardModel(
      id: '', // Firestore сам сгенерирует
      title: nameBoard,
      ownerId: auth.user!.uid,
      sharedWith: {},
      cards: {},
      hexColor: boardColor,
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
    bool showExtraOptions = false;
    bool showColorPicker = false;
    String selectedColor = "11998e";
    String customColorChoose = "";

    //Theme.of(context).extension<AppColorsExtension>()?.mainText

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFD3D3D3),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.5,
                  minChildSize: 0.3,
                  maxChildSize: 0.7,
                  builder: (context, scrollController) {
                    return Padding(
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
                                  await addBoardSample(
                                      context, nameBoard.text, selectedColor);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  S.of(context).save,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  SizedBox(height: size.height * 0.03),
                                  SizedBox(
                                    width: 320,
                                    height: 50,
                                    child: TextField(
                                      controller: nameBoard,
                                      maxLength: 20,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      cursorColor:
                                          isDark ? Colors.white : Colors.black,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 14, horizontal: 16),
                                        hintText: S.of(context).newBoard,
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                            color: isDark
                                                ? Colors.grey
                                                : Colors.black54,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            width: 1, // Можно толще
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // ElevatedButton.icon(
                                  //   onPressed: () => setState(() {
                                  //     showExtraOptions =
                                  //         !showExtraOptions; // переключаем состояние
                                  //   }),
                                  //   icon: Icon(showExtraOptions
                                  //       ? Icons.keyboard_arrow_up
                                  //       : Icons.keyboard_arrow_down),
                                  //   label: Text(showExtraOptions
                                  //       ? 'Скрыть опции'
                                  //       : 'Показать опции'),
                                  // ),

                                  const SizedBox(height: 15),

                                  DropDownWidget(
                                    widthContainer: 320,
                                    isDark: isDark,
                                    header: Row(
                                      children: [
                                        const Text("Background"),
                                        const Spacer(),
                                        Container(
                                          width: 30,
                                          height: 20,
                                          color: HexToColor(selectedColor),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisExtent: 100,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                        ),
                                        itemCount: ListColorsHex.length + 1,
                                        itemBuilder: (context, index) {
                                          // Если это последний элемент — кастомный элемент
                                          if (index == ListColorsHex.length) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  showColorPicker = true;
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: customColorChoose
                                                          .isEmpty
                                                      ? isDark
                                                          ? Colors.grey[800]
                                                          : Colors.grey[300]
                                                      : HexToColor(
                                                          customColorChoose),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? Colors.white54
                                                        : Colors.black45,
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Icon(Icons.add,
                                                      size: 30,
                                                      color: Colors.black54),
                                                ),
                                              ),
                                            );
                                          }
                                          final colorHex = ListColorsHex[index];
                                          final isSelected =
                                              selectedColor == colorHex;

                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedColor = colorHex;
                                                showColorPicker = false;
                                              });
                                            },
                                            splashColor: Colors.black
                                                // ignore: deprecated_member_use
                                                .withOpacity(0.2),
                                            highlightColor: Colors.black
                                                // ignore: deprecated_member_use
                                                .withOpacity(0.3),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: HexToColor(
                                                  ListColorsHex[index],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: isSelected
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons.check,
                                                        size: 30,
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                          );
                                        },
                                      ),
                                      showColorPicker
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: ColorPickerWidget(
                                                initialColor:
                                                    HexToColor(selectedColor),
                                                onColorSelected: (color) {
                                                  setState(() {
                                                    selectedColor = color.value
                                                        .toRadixString(16)
                                                        .substring(2);
                                                    customColorChoose =
                                                        selectedColor;
                                                  });
                                                },
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                  // Container(
                                  //   width: 320,
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(15),
                                  //     color: isDark
                                  //         ? const Color(0xFF494B4D)
                                  //         : const Color(0xFFF6F6F6),
                                  //   ),
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(12.0),
                                  //     child: Column(
                                  //       children: [
                                  //         GestureDetector(
                                  //           onTap: () {
                                  //             setState(() {
                                  //               showExtraOptions =
                                  //                   !showExtraOptions;
                                  //             });
                                  //           },
                                  //           child: Row(
                                  //             mainAxisAlignment:
                                  //                 MainAxisAlignment
                                  //                     .spaceBetween,
                                  //             children: [
                                  //               const Text(
                                  //                 "Background",
                                  //                 style: TextStyle(
                                  //                   fontFamily: 'SFProText',
                                  //                   fontWeight: FontWeight.w700,
                                  //                   fontSize: 14,
                                  //                 ),
                                  //               ),
                                  //               const Spacer(),
                                  //               Container(
                                  //                 color:
                                  //                     HexToColor(selectedColor),
                                  //                 height: 20,
                                  //                 width: 30,
                                  //               ),
                                  //               const SizedBox(width: 4),
                                  //               Icon(!showExtraOptions
                                  //                   ? Icons
                                  //                       .arrow_drop_down_rounded
                                  //                   : Icons
                                  //                       .arrow_drop_up_rounded)
                                  //             ],
                                  //           ),
                                  //         ),
                                  //         AnimatedSize(
                                  //           duration: const Duration(
                                  //               microseconds: 500),
                                  //           child: showExtraOptions
                                  //               ? Column(
                                  //                   children: [
                                  //                     Divider(
                                  //                       height: 25,
                                  //                       color: isDark
                                  //                           ? Colors.white38
                                  //                           : Colors.black45,
                                  //                       thickness: 0.6,
                                  //                     ),
                                  //                     GridView.builder(
                                  //                       shrinkWrap: true,
                                  //                       physics:
                                  //                           const NeverScrollableScrollPhysics(),
                                  //                       gridDelegate:
                                  //                           const SliverGridDelegateWithFixedCrossAxisCount(
                                  //                         crossAxisCount: 2,
                                  //                         mainAxisExtent: 100,
                                  //                         mainAxisSpacing: 10,
                                  //                         crossAxisSpacing: 10,
                                  //                       ),
                                  //                       itemCount: ListColorsHex
                                  //                               .length +
                                  //                           1,
                                  //                       itemBuilder:
                                  //                           (context, index) {
                                  //                         // Если это последний элемент — кастомный элемент
                                  //                         if (index ==
                                  //                             ListColorsHex
                                  //                                 .length) {
                                  //                           return GestureDetector(
                                  //                             onTap: () {
                                  //                               setState(() {
                                  //                                 showColorPicker =
                                  //                                     true;
                                  //                               });
                                  //                             },
                                  //                             child: Container(
                                  //                               decoration:
                                  //                                   BoxDecoration(
                                  //                                 color: customColorChoose
                                  //                                         .isEmpty
                                  //                                     ? isDark
                                  //                                         ? Colors.grey[
                                  //                                             800]
                                  //                                         : Colors.grey[
                                  //                                             300]
                                  //                                     : HexToColor(
                                  //                                         customColorChoose),
                                  //                                 borderRadius:
                                  //                                     BorderRadius
                                  //                                         .circular(
                                  //                                             8),
                                  //                                 border: Border
                                  //                                     .all(
                                  //                                   color: isDark
                                  //                                       ? Colors
                                  //                                           .white54
                                  //                                       : Colors
                                  //                                           .black45,
                                  //                                 ),
                                  //                               ),
                                  //                               child:
                                  //                                   const Center(
                                  //                                 child: Icon(
                                  //                                     Icons.add,
                                  //                                     size: 30,
                                  //                                     color: Colors
                                  //                                         .black54),
                                  //                               ),
                                  //                             ),
                                  //                           );
                                  //                         }
                                  //                         final colorHex =
                                  //                             ListColorsHex[
                                  //                                 index];
                                  //                         final isSelected =
                                  //                             selectedColor ==
                                  //                                 colorHex;

                                  //                         return InkWell(
                                  //                           onTap: () {
                                  //                             setState(() {
                                  //                               selectedColor =
                                  //                                   colorHex;
                                  //                               showColorPicker =
                                  //                                   false;
                                  //                             });
                                  //                           },
                                  //                           splashColor: Colors
                                  //                               .black
                                  //                               // ignore: deprecated_member_use
                                  //                               .withOpacity(
                                  //                                   0.2),
                                  //                           highlightColor: Colors
                                  //                               .black
                                  //                               // ignore: deprecated_member_use
                                  //                               .withOpacity(
                                  //                                   0.3),
                                  //                           child: Container(
                                  //                             decoration:
                                  //                                 BoxDecoration(
                                  //                               color:
                                  //                                   HexToColor(
                                  //                                 ListColorsHex[
                                  //                                     index],
                                  //                               ),
                                  //                               borderRadius:
                                  //                                   BorderRadius
                                  //                                       .circular(
                                  //                                           8),
                                  //                             ),
                                  //                             child: isSelected
                                  //                                 ? const Center(
                                  //                                     child:
                                  //                                         Icon(
                                  //                                       Icons
                                  //                                           .check,
                                  //                                       size:
                                  //                                           30,
                                  //                                     ),
                                  //                                   )
                                  //                                 : const SizedBox
                                  //                                     .shrink(),
                                  //                           ),
                                  //                         );
                                  //                       },
                                  //                     ),
                                  //                     showColorPicker
                                  //                         ? Padding(
                                  //                             padding:
                                  //                                 const EdgeInsets
                                  //                                     .symmetric(
                                  //                                     vertical:
                                  //                                         10),
                                  //                             child:
                                  //                                 ColorPickerWidget(
                                  //                               initialColor:
                                  //                                   HexToColor(
                                  //                                       selectedColor),
                                  //                               onColorSelected:
                                  //                                   (color) {
                                  //                                 setState(() {
                                  //                                   selectedColor = color
                                  //                                       .value
                                  //                                       .toRadixString(
                                  //                                           16)
                                  //                                       .substring(
                                  //                                           2);
                                  //                                   customColorChoose =
                                  //                                       selectedColor;
                                  //                                 });
                                  //                               },
                                  //                             ),
                                  //                           )
                                  //                         : const SizedBox
                                  //                             .shrink(),
                                  //                   ],
                                  //                 )
                                  //               : const SizedBox.shrink(),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
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
                                await Provider.of<BoardProvider>(context,
                                        listen: false)
                                    .updateBoard(
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

  void showBottomModalCreateCardToBoard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final initialName = (auth.user?.displayName?.trim().isNotEmpty ?? false)
        ? auth.user!.displayName!
        : 'No Name';

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
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AddTaskBottomSheet(
                    scrollController: scrollController,
                    size: size,
                    boards: boardForTask,
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
                        // ignore: use_build_context_synchronously
                        showBottomModalAddBoard(context);
                      } else if (value == 'create_card') {
                        // ignore: use_build_context_synchronously
                        showBottomModalCreateCardToBoard(context);
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
                onChanged: (value) {
                  setState(() {
                    _searchText = value.toLowerCase().trim();
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder<List<BoardModel>>(
                stream: boardStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const SizedBox();
                  }

                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final favoriteBoards = snapshot.data!
                      .where((board) => board.favorite == true)
                      .toList();

                  final filteredFavorites = _searchText.isEmpty
                      ? favoriteBoards
                      : favoriteBoards
                          .where((board) =>
                              board.title.toLowerCase().contains(_searchText))
                          .toList();

                  if (filteredFavorites.isEmpty) {
                    return const SizedBox(); // ничего не показывать
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, bottom: 5, top: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              IconlyLight.star,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              S.of(context).starredBoards,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, mainAxisExtent: 100),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredFavorites.length,
                        itemBuilder: (context, index) {
                          final board = filteredFavorites[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                context.goNamed('boardtest2',
                                    pathParameters: {'id': board.id});
                              },
                              // ignore: deprecated_member_use
                              splashColor: Colors.black.withOpacity(0.2),
                              // ignore: deprecated_member_use
                              highlightColor: Colors.black.withOpacity(0.3),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: board.color,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    board.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SFProText',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).yourWorkspaces,
                style: HomeLayout(isMobile, isTablet).h2Style,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      auth.user?.email ?? "",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontFamily: 'SFProText',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
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
                  boardForTask = boards;

                  final filteredBoards = _searchText.isEmpty
                      ? boards
                      : boards
                          .where((board) =>
                              board.title.toLowerCase().contains(_searchText))
                          .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // itemCount: boards.length,
                    itemCount: filteredBoards.length,
                    itemBuilder: (context, index) {
                      // final board = boards[index];
                      final board = filteredBoards[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            // context.go('/board/${board.id}');
                            context.goNamed('boardtest2',
                                pathParameters: {'id': board.id});
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
