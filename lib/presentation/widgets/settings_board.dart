import 'dart:async';

import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/role_model.dart';
import 'package:flow/data/models/user_models.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/widgets/rounded_container.dart';
import 'package:flow/presentation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class SettingsBoard extends StatefulWidget {
  final ScrollController scrollController;
  final Size size;
  final BoardModel board;
  const SettingsBoard(
      {super.key,
      required this.scrollController,
      required this.size,
      required this.board});

  @override
  State<SettingsBoard> createState() => _SettingsBoardState();
}

class _SettingsBoardState extends State<SettingsBoard> {
  Timer? _debounce;
  bool _isFavoritel = false;
  late AuthProvider auth;
  StreamSubscription<BoardModel?>? _boardSub;

  List<BoardMember> boardUsers = [];

  final TextEditingController _titleController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     auth = Provider.of<AuthProvider>(context, listen: false);
  //     final users = await auth.loadBoardUsers(widget.board);
  //     if (mounted) {
  //       setState(() {
  //         boardUsers = users;
  //       });
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      auth = Provider.of<AuthProvider>(context, listen: false);
      final boardProvider = Provider.of<BoardProvider>(context, listen: false);

      _boardSub = boardProvider
          .watchBoardById(widget.board.id)
          .listen((updatedBoard) async {
        if (updatedBoard != null) {
          final users = await auth.loadBoardUsers(updatedBoard);
          if (mounted) {
            setState(() {
              boardUsers = users;
              _titleController.text = updatedBoard.title;
            });
          }
        }
      });
    });

    _titleController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(seconds: 2), () {
        final newTitle = _titleController.text.trim();
        if (newTitle.isNotEmpty && newTitle != widget.board.title) {
          final boardProvider =
              Provider.of<BoardProvider>(context, listen: false);
          boardProvider.updateBoard(widget.board.copyWith(title: newTitle));
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _boardSub?.cancel();
    super.dispose();
  }

  Widget buildUserList(List<BoardMember> members, bool isDark) {
    return Row(
      children: members.map((member) {
        final user = member.user;
        final role = member.role;

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
                    user.photoUrl != null && user.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Text(
                        user.displayName.isNotEmpty ? user.displayName[0] : '?',
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void showManageMembersModal(BuildContext context, BoardModel board) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManageMembersContent(board: board),
    );
  }

  // Widget buildUserList(List<AppUser> users, bool isDark) {
  //   return Row(
  //     mainAxisSize:
  //         MainAxisSize.min, // 🔧 важно, чтобы ширина была по содержимому
  //     children: users.map((user) {
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 6),
  //         child: CircleAvatar(
  //           backgroundColor: Colors.grey,
  //           radius: 25,
  //           backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
  //               ? NetworkImage(user.photoUrl!)
  //               : null,
  //           child: user.photoUrl == null || user.photoUrl!.isEmpty
  //               ? Text(
  //                   user.displayName.isNotEmpty ? user.displayName[0] : '?',
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 )
  //               : null,
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);

    return Column(
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
                S.of(context).boardMenu,
                style: TextStyle(
                  fontFamily: 'SFProText',
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 25,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add to Favorites",
                      style: TextStyle(
                        fontFamily: 'SFProText',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF333333)
                              : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: IconButton(
                          onPressed: () async {
                            try {
                              setState(() {
                                _isFavoritel = !_isFavoritel;
                              });
                              await boardProvider.markBoardAsFavorite(
                                  widget.board.id, _isFavoritel);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(S.of(context).couldntAddToFavorite),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            !_isFavoritel
                                ? Icons.star_border_rounded
                                : Icons.star_rate_rounded,
                            color: _isFavoritel
                                ? Colors.greenAccent.shade400
                                : isDark
                                    ? Colors.white70
                                    : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: RoundedContainerCustom(
                  isDark: isDark,
                  width: 320,
                  height: 55,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  childWidget: TextField(
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
              ),
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
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Members",
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
                      color: isDark ? Colors.white38 : Colors.black38,
                      thickness: 1.2,
                      height: 5,
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                            onTap: () {
                              showManageMembersModal(context, widget.board);
                            },
                            child: buildUserList(boardUsers, isDark)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManageMembersContent extends StatefulWidget {
  final BoardModel board;
  const _ManageMembersContent({required this.board});

  @override
  State<_ManageMembersContent> createState() => _ManageMembersContentState();
}

class _ManageMembersContentState extends State<_ManageMembersContent> {
  List<BoardMember> currentMembers = [];
  List<AppUser> searchResults = [];
  String query = '';
  TextEditingController _search_controller = TextEditingController();

  late AuthProvider auth;
  late BoardProvider boardProvider;
  late BoardModel _board;

  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    boardProvider = Provider.of<BoardProvider>(context, listen: false);
    // _board = widget.board;
    boardProvider.getBoardById(widget.board.id).then((latestBoard) {
      if (latestBoard != null && mounted) {
        setState(() {
          _board = latestBoard;
        });
        _loadCurrentMembers();
      }
    });
  }

  // Future<void> _loadCurrentMembers() async {
  //   final users = await auth.loadBoardUsers(widget.board);
  //   setState(() => currentMembers = users);
  // }
  Future<void> _loadCurrentMembers() async {
    final users = await auth.loadBoardUsers(_board);
    setState(() => currentMembers = users);
  }

  Future<void> _searchUsers(String input) async {
    setState(() => query = input);
    if (input.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    final results = await auth.searchUsersByEmail(input);
    setState(() => searchResults = results);
  }

  bool _isAlreadyMember(String userId) {
    return widget.board.ownerId == userId ||
        widget.board.sharedWith.containsKey(userId);
  }

  Future<void> _addUser(AppUser user) async {
    await boardProvider.addUserToBoard(widget.board, user.id, 'viewer');
    await _loadCurrentMembers();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : const Color(0xFFD3D3D3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).members,
              style: TextStyle(
                fontFamily: 'SFProText',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            SearchBarWidget(
              onChanged: _searchUsers,
              controller: _search_controller,
              isDark: isDark,
              hintText: "Enter Email",
            ),
            const SizedBox(height: 16),
            Expanded(
              child: query.isEmpty
                  ? ListView(
                      controller: scrollController,
                      children: currentMembers.map((member) {
                        return ListTile(
                          onTap: () {
                            final isOwner =
                                member.user.id == widget.board.ownerId;
                            if (isOwner) return;

                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Управление участником",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          const Icon(Icons.manage_accounts),
                                          const SizedBox(width: 10),
                                          const Text("Выберите роль:"),
                                          const Spacer(),
                                          DropdownButton<String>(
                                            value: member.role,
                                            items: ["viewer", "editor"]
                                                .map((role) {
                                              return DropdownMenuItem(
                                                value: role,
                                                child: Text(role),
                                              );
                                            }).toList(),
                                            // onChanged: (value) async {
                                            //   if (value != null &&
                                            //       value != member.role) {
                                            //     await context
                                            //         .read<BoardProvider>()
                                            //         .addUserToBoard(
                                            //           widget.board,
                                            //           member.user.id,
                                            //           value,
                                            //         );
                                            //     Navigator.pop(context);
                                            //   }
                                            // },
                                            onChanged: (value) async {
                                              if (value != null &&
                                                  value != member.role) {
                                                await context
                                                    .read<BoardProvider>()
                                                    .addUserToBoard(
                                                      _board,
                                                      member.user.id,
                                                      value,
                                                    );
                                                final updatedBoard =
                                                    await boardProvider
                                                        .getBoardById(
                                                            _board.id);
                                                if (updatedBoard != null) {
                                                  setState(() {
                                                    _board = updatedBoard;
                                                  });
                                                  await _loadCurrentMembers();
                                                }
                                                if (mounted)
                                                  Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.remove_circle),
                                        label: const Text("Удалить участника"),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.red,
                                        ),
                                        // onPressed: () async {
                                        //   await context
                                        //       .read<BoardProvider>()
                                        //       .removeUserFromBoard(
                                        //         widget.board,
                                        //         member.user.id,
                                        //       );
                                        //   Navigator.pop(context);
                                        // },
                                        onPressed: () async {
                                          await context
                                              .read<BoardProvider>()
                                              .removeUserFromBoard(
                                                _board,
                                                member.user.id,
                                              );
                                          final updatedBoard =
                                              await boardProvider
                                                  .getBoardById(_board.id);
                                          if (updatedBoard != null) {
                                            setState(() {
                                              _board = updatedBoard;
                                            });
                                            await _loadCurrentMembers();
                                          }
                                          if (mounted) Navigator.pop(context);
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          leading: CircleAvatar(
                            backgroundImage: member.user.photoUrl != null
                                ? NetworkImage(member.user.photoUrl!)
                                : null,
                            child: member.user.photoUrl == null
                                ? Text(member.user.displayName[0])
                                : null,
                          ),
                          title: Text(
                            member.user.displayName,
                            style: TextStyle(
                              fontFamily: 'SFProText',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            member.role,
                            style: TextStyle(
                              fontFamily: 'SFProText',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : ListView(
                      controller: scrollController,
                      children: searchResults.map((user) {
                        final already = _isAlreadyMember(user.id);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null,
                            child: user.photoUrl == null
                                ? Text(
                                    user.displayName[0],
                                    style: TextStyle(
                                      fontFamily: 'SFProText',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            user.displayName,
                            style: TextStyle(
                              fontFamily: 'SFProText',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            user.email,
                            style: TextStyle(
                              fontFamily: 'SFProText',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          trailing: already
                              ? const Icon(Icons.check, color: Colors.grey)
                              : IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.greenAccent.shade400,
                                  ),
                                  onPressed: () {
                                    _addUser(user);
                                    Navigator.pop(context);
                                  },
                                ),
                        );
                      }).toList(),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
