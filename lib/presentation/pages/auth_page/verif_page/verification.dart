import 'dart:async';

import 'package:flow/core/theme/app_ext.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _resendAvailable = true;
  String? _resendText;

  TextStyle mainTextStyle = const TextStyle(
    fontFamily: 'SFProText',
    fontWeight: FontWeight.w300,
    fontSize: 15,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ здесь можно использовать context
    _resendText ??= S.of(context).resend;

    final auth = Provider.of<AuthProvider>(context);
    if (auth.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        auth.clearError();
      });
    }
  }

  Future<void> _handleResendEmail(AuthProvider auth) async {
    if (!_resendAvailable) return;

    setState(() {
      _resendAvailable = false;
      _resendText = S.of(context).sentIn(30);
    });

    await auth.sendVerificationEmail();

    int countdown = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 1) {
        timer.cancel();
        setState(() {
          _resendAvailable = true;
          _resendText = S.of(context).resend;
        });
      } else {
        countdown--;
        setState(() {
          _resendText = S.of(context).sentIn(countdown);
        });
      }
    });
  }

  // Future<void> _handleResendEmail(AuthProvider auth) async {
  //   if (!_resendAvailable) return;

  //   setState(() {
  //     _resendAvailable = false;
  //     _resendText = "Отправлено (30 сек)";
  //   });

  //   await auth.sendVerificationEmail();

  //   int countdown = 30;
  //   Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (countdown == 1) {
  //       timer.cancel();
  //       setState(() {
  //         _resendAvailable = true;
  //         _resendText = "Отправить повторно";
  //       });
  //     } else {
  //       countdown--;
  //       setState(() {
  //         _resendText = "Отправлено (${countdown} сек)";
  //       });
  //     }
  //   });
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final auth = Provider.of<AuthProvider>(context);
  //   if (auth.errorMessage != null) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(auth.errorMessage!),
  //           backgroundColor: Colors.redAccent,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //       auth.clearError(); // сброс ошибки после показа
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        context.go("/auth/login");

        return false; // предотвратить автоматический pop
      },
      child: Scaffold(
        body: Center(
          child: Container(
            width: isMobile
                ? size.width * 0.9
                : isTablet
                    ? 500
                    : 500,
            height: isMobile
                ? size.height * 0.6
                : isTablet
                    ? 200
                    : 300,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF25282A)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    title: Text(
                      S.of(context).confirmTitle,
                      style: mainTextStyle,
                    ),
                    centerTitle: true,
                    leading: IconButton(
                        onPressed: () {
                          context.go("/auth/login");
                        },
                        icon: Icon(
                          IconlyLight.arrow_left,
                          size: isMobile ? 24 : 46,
                        )),
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.email, size: 75, color: Colors.greenAccent),
                  const SizedBox(height: 13),
                  Text(
                    S.of(context).confirmMessage,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .extension<AppColorsExtension>()
                            ?.mainText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _resendAvailable
                        ? () => _handleResendEmail(auth)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _resendAvailable
                          ? Colors.green
                          : const Color(0xFF25282A),
                      side: BorderSide(
                        color: _resendAvailable
                            ? Colors.transparent
                            : Theme.of(context)
                                    .extension<AppColorsExtension>()
                                    ?.mainText ??
                                Colors.grey,
                        width: _resendAvailable ? 0 : 1,
                      ),
                    ),
                    child: Text(
                      _resendText!,
                      style: TextStyle(
                        color: _resendAvailable
                            ? Colors.white
                            : Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context)
                                        .extension<AppColorsExtension>()
                                        ?.mainText ??
                                    Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await auth.checkEmailVerification();
                      if (auth.isEmailVerified) {
                        context.go('/');
                      }
                    },
                    child: Text(S.of(context).checkAgain),
                  ),
                  if (auth.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
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
