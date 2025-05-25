import 'package:flow/core/theme/app_ext.dart';
import 'package:flow/core/utils/picker_file_image/picker.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/core/utils/provider/local_provider.dart';
import 'package:flow/core/utils/provider/theme_provider.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/pages/account_page/account_layout.dart';
import 'package:flow/presentation/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final picker = Picker();

  Uint8List? imageBytes;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void showBottomModalAccountEdit(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final initialName = (auth.user?.displayName?.trim().isNotEmpty ?? false)
        ? auth.user!.displayName!
        : 'No Name';

    final TextEditingController nameController =
        TextEditingController(text: initialName);

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
                        // 🔝 Верхние кнопки

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
                                final newName = nameController.text.trim();
                                final currentName =
                                    auth.user?.displayName?.trim();

                                // Обновляем только если имя изменилось и не пустое
                                if (newName.isNotEmpty &&
                                    newName != currentName) {
                                  await auth.updateDisplayName(
                                      newName); // 🔧 сохраняем в Firebase Auth + Firestore
                                }

                                Navigator.pop(context); // Закрываем модалку
                              },
                              child: Text(
                                S.of(context).save,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.03),

                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            final photoUrl = auth.user?.photoURL;
                            return GestureDetector(
                              onTap: () {
                                if (photoUrl != null) {
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: InteractiveViewer(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              photoUrl,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                              onLongPressStart: (details) {
                                final tapPosition = details.globalPosition;

                                showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    tapPosition.dx,
                                    tapPosition.dy,
                                    tapPosition.dx,
                                    tapPosition.dy,
                                  ),
                                  items: [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Изменить фото',
                                        style:
                                            AccountLayout.CardSubTitle.copyWith(
                                          color: Theme.of(context)
                                              .extension<AppColorsExtension>()
                                              ?.mainText,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'remove',
                                      child: Text(
                                        'Удалить фото',
                                        style:
                                            AccountLayout.CardSubTitle.copyWith(
                                          color: Theme.of(context)
                                              .extension<AppColorsExtension>()
                                              ?.mainText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).then((value) async {
                                  if (value == 'edit') {
                                    final pickedBytes =
                                        await picker.pickImageBytes(context);
                                    if (pickedBytes != null) {
                                      await auth.updateUserPhoto(
                                          pickedBytes); // 🔧 реализуем ниже
                                    }
                                  } else if (value == 'remove') {
                                    await auth.removeUserPhoto();
                                  }
                                });
                              },
                              child: auth.user?.photoURL != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        auth.user!.photoURL!,
                                      ),
                                      radius: isMobile ? 70 : 100,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      radius: isMobile ? 70 : 100,
                                      child: Icon(
                                        IconlyLight.profile,
                                        color: Colors.white,
                                        size: isMobile ? 70 : 80,
                                      ),
                                    ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: 300,
                          height: 50,
                          child: TextField(
                            controller: nameController,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            cursorColor: isDark ? Colors.white : Colors.black,
                            decoration: InputDecoration(
                              hintText: initialName,
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey : Colors.black54,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.white : Colors.black,
                                  width: 2, // Можно толще
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ElevatedButton(
                        //   onPressed: () async {
                        //     final picked = await pick.pickImageBytes();
                        //     if (picked != null) {
                        //       setState(() {
                        //         imageBytes = picked;
                        //       });
                        //     }
                        //   },
                        //   child: const Text("Выбрать изображение"),
                        // ),

                        // if (imageBytes != null)
                        //   Padding(
                        //     padding: const EdgeInsets.only(top: 20),
                        //     child: Image.memory(imageBytes!, height: 200),
                        //   ),
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

  void showBottomModalThemeEdit(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    ThemeMode currentMode = themeProvider.themeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? const Color(0xFF1F1F1F) : const Color(0xFFD3D3D3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верхняя панель
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
                      Text(
                        'Theme settings',
                        style: TextStyle(
                          color: Theme.of(context)
                              .extension<AppColorsExtension>()
                              ?.mainText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 48), // для выравнивания
                    ],
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 24),
                  Text(
                    "SELECT THEME",
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<AppColorsExtension>()
                          ?.subText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),

                  AutoExpandableCard(
                    children: [
                      //  THEME SETTINGS
                      InkWell(
                        onTap: () {
                          setState(() => currentMode = ThemeMode.system);
                          themeProvider.toggleThemeMode(ThemeMode.system);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.hdr_auto_outlined,
                              color: isDark
                                  ? const Color.fromARGB(255, 179, 179, 179)
                                  : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            const Text("Automatic"),
                            const Spacer(),
                            if (currentMode == ThemeMode.system)
                              Icon(Icons.check,
                                  color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 0.5,
                        color: Color.fromARGB(96, 158, 158, 158),
                      ),
                      //LANG SETTINGS
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          setState(() => currentMode = ThemeMode.light);
                          themeProvider.toggleThemeMode(ThemeMode.light);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.light_mode_rounded,
                              color: isDark
                                  ? const Color.fromARGB(255, 179, 179, 179)
                                  : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            const Text("Light"),
                            const Spacer(),
                            if (currentMode == ThemeMode.light)
                              Icon(Icons.check,
                                  color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 0.5,
                        color: Color.fromARGB(96, 158, 158, 158),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          setState(() => currentMode = ThemeMode.dark);
                          themeProvider.toggleThemeMode(ThemeMode.dark);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.dark_mode_rounded,
                              color: isDark
                                  ? const Color.fromARGB(255, 179, 179, 179)
                                  : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            const Text("Dark"),
                            const Spacer(),
                            if (currentMode == ThemeMode.dark)
                              Icon(Icons.check,
                                  color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // _themeTile(
                  //   title: "Dark",
                  //   selected: currentMode == ThemeMode.dark,
                  //   onTap: () {
                  //     setState(() => currentMode = ThemeMode.dark);
                  //     themeProvider.toggleThemeMode(ThemeMode.dark);
                  //   },
                  // ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showBottomModalLanguageEdit(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    Locale currentLocale = localeProvider.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? const Color(0xFF1F1F1F) : const Color(0xFFD3D3D3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верхняя панель
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
                      Text(
                        S.of(context).languageSetting,
                        style: TextStyle(
                          color: Theme.of(context)
                              .extension<AppColorsExtension>()
                              ?.mainText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 48), // для выравнивания
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text(
                    S.of(context).selectLanguage,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<AppColorsExtension>()
                          ?.subText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),

                  AutoExpandableCard(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() => currentLocale = const Locale('en'));
                          localeProvider.setLocale(const Locale('en'));
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.language),
                            const SizedBox(width: 8),
                            const Text("English"),
                            const Spacer(),
                            if (currentLocale.languageCode == 'en')
                              Icon(Icons.check,
                                  color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 0.5,
                        color: Color.fromARGB(96, 158, 158, 158),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() => currentLocale = const Locale('ru'));
                          localeProvider.setLocale(const Locale('ru'));
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.language),
                            const SizedBox(width: 8),
                            const Text("Русский"),
                            const Spacer(),
                            if (currentLocale.languageCode == 'ru')
                              Icon(Icons.check,
                                  color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color(0xFF1F1F1F),
        backgroundColor:
            isDark ? const Color(0xFF1F1F1F) : const Color(0xFFD3D3D3),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:
              isDark ? const Color(0xFF1F1F1F) : const Color(0xFFD3D3D3),
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text(S.of(context).accountPage,
            style: AccountLayout.AppBarTitle.copyWith(
              color: isDark ? Colors.white : const Color(0xFF1F1F1F),
            )),
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: false,
        radius: const Radius.circular(20),
        thickness: 1.5,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Card(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return ListTile(
                    leading: auth.user?.photoURL != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(auth.user!.photoURL!),
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 25,
                            child:
                                Icon(IconlyLight.profile, color: Colors.white),
                          ),
                    title: Text(
                      auth.user?.displayName?.isNotEmpty == true
                          ? auth.user!.displayName!
                          : "No name",
                      style: AccountLayout.CardMainTitle.copyWith(
                        color: Theme.of(context)
                            .extension<AppColorsExtension>()
                            ?.mainText,
                      ),
                    ),
                    subtitle: Text(
                      auth.user?.email ?? "",
                      style: AccountLayout.CardSubTitle.copyWith(
                        color: Theme.of(context)
                            .extension<AppColorsExtension>()
                            ?.subText,
                      ),
                    ),
                    trailing: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 15,
                      child: const Icon(
                        IconlyLight.edit,
                        size: 18,
                      ),
                    ),
                    onTap: () {
                      final auth =
                          Provider.of<AuthProvider>(context, listen: false);
                      final uid = auth.user?.uid;
                      if (uid == null) return;

                      showBottomModalAccountEdit(context);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            Text(
              S.of(context).settingAndTools,
              style: AccountLayout.TextH2,
            ),
            AutoExpandableCard(
              children: [
                //  THEME SETTINGS
                GestureDetector(
                  onTap: () {
                    showBottomModalThemeEdit(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: isDark
                            ? const Color.fromARGB(255, 179, 179, 179)
                            : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(S.of(context).theme),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 0.5,
                  color: Color.fromARGB(96, 158, 158, 158),
                ),
                //LANG SETTINGS
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    showBottomModalLanguageEdit(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.language_sharp,
                        color: isDark
                            ? const Color.fromARGB(255, 179, 179, 179)
                            : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(S.of(context).language),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 0.5,
                  color: Color.fromARGB(96, 158, 158, 158),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    auth.logout();
                    SnackBarHelper.show(context, S.of(context).successfulExit);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_outlined,
                        color: isDark
                            ? const Color.fromARGB(255, 179, 179, 179)
                            : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(S.of(context).logOut),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Text(
              S.of(context).appInformation,
              style: AccountLayout.TextH2,
            ),
            AutoExpandableCard(
              children: [
                //  APP VERSION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).appVersion,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "25.148",
                      style: AccountLayout.TextNumber.copyWith(
                          color: Theme.of(context)
                              .extension<AppColorsExtension>()
                              ?.subText),
                    ),
                  ],
                ),

                const Divider(
                  thickness: 0.5,
                  color: Color.fromARGB(96, 158, 158, 158),
                ),
                //LANG SETTINGS
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).build,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "202514884252",
                      style: AccountLayout.TextNumber.copyWith(
                          color: Theme.of(context)
                              .extension<AppColorsExtension>()
                              ?.subText),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TextFieldCustom extends StatelessWidget {
  const TextFieldCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class AutoExpandableCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final Color backgroundColor;

  const AutoExpandableCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = const Color(0xFF2A2A2A),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? backgroundColor : const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
