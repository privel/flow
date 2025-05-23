import 'package:flow/core/theme/app_ext.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final size = MediaQuery.of(context).size;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? 380
                  : isTablet
                      ? 450
                      : 500,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                // color: const Color(0xFF191D1E),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔙 Назад + логотип по центру
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.go('/auth/login'),
                          icon: Icon(
                            IconlyLight.arrow_left,
                            color: Theme.of(context)
                                .extension<AppColorsExtension>()
                                ?.mainText,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/image/logo/logoff.png",
                            height: isMobile ? 70 : 80,
                            width: isMobile ? 70 : 80,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text(
                    S.of(context).ForgotenterTheEmailAddressToWhichYouWillReceiveThe,
                    style: TextStyle(
                        color: Theme.of(context)
                            .extension<AppColorsExtension>()
                            ?.subText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // 📧 Email field
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: S.of(context).RegHintEmail,
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: isDark ?  const Color.fromARGB(255, 34, 34, 34): const Color(0xFFD3D3D3),
                      // fillColor: Theme.of(context).colorScheme.onSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 🔘 Сбросить пароль
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await auth
                            .sendPasswordReset(_emailController.text.trim());

                        if (auth.errorMessage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              content: Text(
                                  S.of(context).theEmailHasBeenSentCheckYourEmail),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _emailController.clear();
                          context.go("/auth/login");
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(auth.errorMessage!),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:  Text(S.of(context).resetPassword),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
