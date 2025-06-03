import 'dart:async';

import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/board_provider.dart';
import 'package:flow/core/utils/provider/notification_provider.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/notification_model.dart';
import 'package:flow/data/models/role_model.dart';
import 'package:flow/data/models/user_models.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/widgets/rounded_container.dart';
import 'package:flow/presentation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class ListModalWidget extends StatefulWidget {
  final ScrollController scrollController;

  final BoardModel board;
  const ListModalWidget(
      {super.key,
      required this.scrollController,
    
      required this.board});

  @override
  State<ListModalWidget> createState() => _ListModalWidgetState();
}

class _ListModalWidgetState extends State<ListModalWidget> {
  Timer? _debounce;
  bool _isFavoritel = false;
  late AuthProvider auth;
  late String? userId;
  String? userRole;

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

      userId = auth.user?.uid;
      userRole = boardProvider.getUserRole(widget.board, auth.user?.uid ?? '');

      _boardSub = boardProvider
          .watchBoardById(widget.board.id)
          .listen((updatedBoard) async {
        if (updatedBoard != null) {
          final users = await boardProvider.loadBoardUsers(updatedBoard, auth);
          if (mounted) {
            setState(() {
              boardUsers = users;
              _titleController.text = updatedBoard.title;
              _isFavoritel = updatedBoard.favorite;
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
        if (userRole == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          child: Column(
            children: [
              // CircleAvatar(
              //   backgroundColor: Colors.grey,
              //   radius: 25,
              //   backgroundImage:
              //       user.photoUrl != null && user.photoUrl!.isNotEmpty
              //           ? NetworkImage(user.photoUrl!)
              //           : null,
              //   child: user.photoUrl == null || user.photoUrl!.isEmpty
              //       ? Text(
              //           user.displayName.isNotEmpty ? user.displayName[0] : 'No',
              //           style: const TextStyle(color: Colors.white),
              //         )
              //       : null,
              // ),

              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 25,
                backgroundImage:
                    (user.photoUrl != null && user.photoUrl!.trim().isNotEmpty)
                        ? NetworkImage(user.photoUrl!)
                        : null,
                child: (user.photoUrl == null || user.photoUrl!.trim().isEmpty)
                    ? Text(
                        (user.displayName != null &&
                                user.displayName.trim().isNotEmpty)
                            ? user.displayName[0].toUpperCase()
                            : '?',
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
      builder: (context) => _ManageMembersContent(
        board: board,
      ),
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

  String generateInviteLink(String inviteId) {
    return 'https://flow-ed624.web.app/invite/$inviteId';
  }

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
                padding: const EdgeInsets.only(bottom: 15),
                child: RoundedContainerCustom(
                  isDark: isDark,
                  width: 320,
                  height: 55,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 6),

                  childWidget: (userRole != 'viewer')
                      ? TextField(
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
                        )
                      : Text(
                          _titleController.text,
                          style: TextStyle(
                            fontFamily: 'SFProText',
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                  // childWidget: TextField(
                  //   controller: _titleController,
                  //   style: TextStyle(
                  //     color: isDark ? Colors.white : Colors.black,
                  //   ),
                  //   cursorWidth: 1.5,
                  //   decoration: InputDecoration(
                  //     border: InputBorder.none,
                  //     hintText: S.of(context).nameTask,
                  //     hintStyle: const TextStyle(color: Colors.grey),
                  //     isDense: true,
                  //     fillColor: isDark
                  //         ? const Color(0xFF333333)
                  //         : const Color(0xFFF0F0F0),
                  //   ),
                  // ),
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
              const SizedBox(height: 20),
              userRole == "owner"
                  ? SizedBox(
                      width: 320,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(
                                S.of(context).deleteTheBoard,
                                style: TextStyle(
                                  fontFamily: 'SFProText',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              content: Text(
                                S.of(context).thisActionCannotBeUndoneContinue,
                                style: TextStyle(
                                  fontFamily: 'SFProText',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text(
                                    S.of(context).cancel,
                                    style: TextStyle(
                                      fontFamily: 'SFProText',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.greenAccent.shade400,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(
                                    S.of(context).delete,
                                    style: TextStyle(
                                      fontFamily: 'SFProText',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.redAccent.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await boardProvider.deleteBoard(widget.board.id);
                            if (mounted) {
                              Navigator.pop(context);
                              context.go('/');
                            }
                          }
                        },
                        child: Text(
                          "Delete Board",
                          style: TextStyle(
                            fontFamily: 'SFProText',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
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

  String? userRole;
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
          userRole = boardProvider.getUserRole(_board, auth.user!.uid)!;
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
    final users = await boardProvider.loadBoardUsers(_board, auth);
    setState(() => currentMembers = users);
  }

  Future<void> _searchUsers(String input) async {
    // if (userRole != 'viewer') {
    setState(() => query = input);
    if (input.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    final results = await auth.searchUsersByEmail(input);
    setState(() => searchResults = results);
    // } else {
    //   setState(() => query = input);

    //   if (input.isEmpty) {
    //     setState(() => searchResults = []);
    //     return;
    //   }

    //   final lowerInput = input.toLowerCase();

    //   // Фильтруем локальных участников доски (currentMembers)
    //   final results = currentMembers
    //       .where((member) {
    //         final email = member.user.email.toLowerCase();
    //         final name = member.user.displayName.toLowerCase();

    //         return email.contains(lowerInput) || name.contains(lowerInput);
    //       })
    //       .map((member) => member.user)
    //       .toList();

    //   setState(() => searchResults = results);
    // }
  }

  bool _isAlreadyMember(String userId) {
    // debugPrint("${widget.board.sharedWith.values}");
    return widget.board.ownerId == userId ||
        widget.board.sharedWith.containsKey(userId);
  }

  Future<void> _addUser(AppUser user) async {
    final notificationProvider = context.read<NotificationProvider>();

    final sender = context.read<AuthProvider>().currentAppUser!;

    await boardProvider.addUserToBoard(
      widget.board,
      user.id,
      'viewer',
      sender,
      notificationProvider,
    );

    // // Добавляем уведомление
    // final notification = NotificationModel(
    //   id: '', // будет сгенерирован Firestore
    //   userId: user.id,
    //   title: 'Приглашение в доску',
    //   description: 'Вас пригласили в доску "${widget.board.title}"',
    //   timestamp: DateTime.now(),
    //   isRead: false,
    // );

    // await notificationProvider.createNotification(notification);
    // // await context.read<NotificationProvider>().createNotification(notification);

    await _loadCurrentMembers();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, scrollController) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161616) : const Color(0xFFD3D3D3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
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
                      S.of(context).members,
                      style: TextStyle(
                        fontFamily: 'SFProText',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SearchBarWidget(
                onChanged: _searchUsers,
                controller: _search_controller,
                isDark: isDark,
                hintText: S.of(context).enterEmail,
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
                              if (userRole != 'viewer') {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  isDismissible: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      DraggableScrollableSheet(
                                    initialChildSize: 0.3,
                                    maxChildSize: 0.4,
                                    builder: (context, scrollController) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF161616)
                                            : const Color(0xFFD3D3D3),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              S
                                                  .of(context)
                                                  .participantManagement,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 20),
                                            RoundedContainerCustom(
                                              isDark: isDark,
                                              width: 330,
                                              height: 55,
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                              ),
                                              childWidget: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.manage_accounts),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    S.of(context).chooseARole,
                                                    style: const TextStyle(
                                                      fontFamily: 'SFProText',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  DropdownButton<String>(
                                                    value: member.role,
                                                    items: ["viewer", "editor"]
                                                        .map((role) {
                                                      return DropdownMenuItem(
                                                        value: role,
                                                        child: Text(
                                                          role,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'SFProText',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 15,
                                                            color: isDark
                                                                ? Colors.white70
                                                                : Colors
                                                                    .black87,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) async {
                                                      if (value != null &&
                                                          value !=
                                                              member.role) {
                                                        final boardProvider =
                                                            context.read<
                                                                BoardProvider>();
                                                        final authProvider =
                                                            context.read<
                                                                AuthProvider>();
                                                        final notificationProvider =
                                                            context.read<
                                                                NotificationProvider>();
                                                        final sender =
                                                            authProvider
                                                                .currentAppUser;

                                                        await boardProvider
                                                            .addUserToBoard(
                                                          _board,
                                                          member.user.id,
                                                          value,
                                                          sender!,
                                                          notificationProvider,
                                                        );

                                                        final updatedBoard =
                                                            await boardProvider
                                                                .getBoardById(
                                                                    _board.id);
                                                        if (updatedBoard !=
                                                            null) {
                                                          if (!mounted) {
                                                            return; // добавь перед setState
                                                          }
                                                          setState(() {
                                                            _board =
                                                                updatedBoard;
                                                          });
                                                          await _loadCurrentMembers();
                                                        }
                                                        if (mounted) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton.icon(
                                              icon: const Icon(
                                                  IconlyLight.delete),
                                              label: Text(
                                                S
                                                    .of(context)
                                                    .deleteAParticipant,
                                                style: const TextStyle(
                                                  fontFamily: 'SFProText',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    Colors.redAccent.shade400,
                                                fixedSize: const Size(330, 50),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
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
                                                final confirmed =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: Text(
                                                      S
                                                          .of(context)
                                                          .doYouReallyWantToDeleteTheParticipant,
                                                      style: TextStyle(
                                                        fontFamily: 'SFProText',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16,
                                                        color: isDark
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      S
                                                          .of(context)
                                                          .thisActionCannotBeUndoneContinue,
                                                      style: TextStyle(
                                                        fontFamily: 'SFProText',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                        color: isDark
                                                            ? Colors.white60
                                                            : Colors.black54,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(ctx)
                                                                .pop(false),
                                                        child: Text(
                                                          S.of(context).cancel,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'SFProText',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14,
                                                            color: Colors
                                                                .greenAccent
                                                                .shade400,
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(ctx)
                                                                .pop(true),
                                                        child: Text(
                                                          S.of(context).delete,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'SFProText',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14,
                                                            color: Colors
                                                                .redAccent
                                                                .shade400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirmed == true) {
                                                  await context
                                                      .read<BoardProvider>()
                                                      .removeUserFromBoard(
                                                        _board,
                                                        member.user.id,
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
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey,
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
                                          member.user.displayName[0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )
                                      : const Icon(Icons.person,
                                          color: Colors.white))
                                  : null,
                            ),

                            // leading: CircleAvatar(
                            //   backgroundImage: member.user.photoUrl != null
                            //       ? NetworkImage(member.user.photoUrl!)
                            //       : null,
                            //   child: member.user.photoUrl == null
                            //       ? Text(member.user.displayName[0])
                            //       : null,
                            // ),
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.user.email,
                                  style: TextStyle(
                                    fontFamily: 'SFProText',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  member.role,
                                  style: TextStyle(
                                    fontFamily: 'SFProText',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    : userRole != 'viewer' //for editor and owner
                        ? ListView(
                            controller: scrollController,
                            children: searchResults.map((user) {
                              final already = _isAlreadyMember(user.id);
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: (user.photoUrl != null &&
                                          user.photoUrl!.trim().isNotEmpty &&
                                          user.photoUrl!.startsWith('http'))
                                      ? NetworkImage(user.photoUrl!)
                                      : null,
                                  child: (user.photoUrl == null ||
                                          user.photoUrl!.trim().isEmpty ||
                                          !user.photoUrl!.startsWith('http'))
                                      ? (user.displayName.isNotEmpty
                                          ? Text(
                                              user.displayName[0].toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            )
                                          : const Icon(Icons.person,
                                              color: Colors.white))
                                      : null,
                                ),
                                // leading: CircleAvatar(
                                //   backgroundImage: user.photoUrl != null
                                //       ? NetworkImage(user.photoUrl!)
                                //       : null,
                                //   child: user.photoUrl == null
                                //       ? Text(
                                //           user.displayName[0],
                                //           style: TextStyle(
                                //             fontFamily: 'SFProText',
                                //             fontWeight: FontWeight.w600,
                                //             fontSize: 14,
                                //             color: isDark
                                //                 ? Colors.white
                                //                 : Colors.black,
                                //           ),
                                //         )
                                //       : null,
                                // ),
                                title: Text(
                                  user.displayName == ""
                                      ? 'No name'
                                      : user.displayName,
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
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                trailing: already
                                    ? const Icon(Icons.check,
                                        color: Colors.grey)
                                    : IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: isDark
                                              ? Colors.greenAccent.shade400
                                              : Colors.green,
                                        ),
                                        onPressed: () {
                                          _addUser(user);
                                          Navigator.pop(context);
                                        },
                                      ),
                              );
                            }).toList(),
                          )
                        //for viewer you can`t edit and add member in board
                        : ListView(
                            controller: scrollController,
                            children: searchResults.map((user) {
                              final already = _isAlreadyMember(user.id);
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: (user.photoUrl != null &&
                                          user.photoUrl!.trim().isNotEmpty &&
                                          user.photoUrl!.startsWith('http'))
                                      ? NetworkImage(user.photoUrl!)
                                      : null,
                                  child: (user.photoUrl == null ||
                                          user.photoUrl!.trim().isEmpty ||
                                          !user.photoUrl!.startsWith('http'))
                                      ? (user.displayName.isNotEmpty
                                          ? Text(
                                              user.displayName[0].toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            )
                                          : const Icon(Icons.person,
                                              color: Colors.white))
                                      : null,
                                ),
                                title: Text(
                                  user.displayName == ""
                                      ? 'No name'
                                      : user.displayName,
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
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                trailing: already
                                    ? Icon(
                                        Icons.check,
                                        color: isDark
                                              ? Colors.greenAccent.shade400
                                              : Colors.green,
                                      )
                                    : const Icon(
                                        Icons.person_off_rounded,
                                        color: Colors.grey,
                                      ),
                                // : IconButton(
                                //     icon: Icon(
                                //       Icons.add,
                                //       color: Colors.greenAccent.shade400,
                                //     ),
                                //     onPressed: () {
                                //       _addUser(user);
                                //       Navigator.pop(context);
                                //     },
                                //   ),
                              );
                            }).toList(),
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
