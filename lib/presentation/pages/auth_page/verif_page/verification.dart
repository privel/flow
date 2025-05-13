import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:flow/core/utils/provider/auth_provider/auth_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _resendAvailable = true;
  String _resendText = "Отправить повторно";

  TextStyle mainTextStyle = const TextStyle(
    fontFamily: 'SFProText',
    fontWeight: FontWeight.w300,
    fontSize: 15,
  );

  Future<void> _handleResendEmail(AuthProvider auth) async {
    if (!_resendAvailable) return;

    setState(() {
      _resendAvailable = false;
      _resendText = "Отправлено (30 сек)";
    });

    await auth.sendVerificationEmail();

    int countdown = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 1) {
        timer.cancel();
        setState(() {
          _resendAvailable = true;
          _resendText = "Отправить повторно";
        });
      } else {
        countdown--;
        setState(() {
          _resendText = "Отправлено (${countdown} сек)";
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        auth.clearError(); // сброс ошибки после показа
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      // backgroundColor: const Color(0xFF121212),
      // appBar: AppBar(
      //   title: const Text("Verify Email"),
      //   actions: [
      //     IconButton(
      //         onPressed: () {
      //           context.go("/auth/login");
      //         },
      //         icon: Icon(Icons.arrow_back_ios))
      //   ],
      // ),
      // body: Padding(
      //   padding: const EdgeInsets.all(24),
      //   child: Center(
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         const Icon(Icons.email, size: 80, color: Colors.greenAccent),
      //         const SizedBox(height: 16),
      //         const Text(
      //           "Пожалуйста, подтвердите свою почту.",
      //           style: TextStyle(fontSize: 18, color: Colors.white),
      //           textAlign: TextAlign.center,
      //         ),
      //         const SizedBox(height: 16),
      //         ElevatedButton(
      //           onPressed: () async {
      //             await auth.sendVerificationEmail();
      //           },
      //           child: const Text("Отправить повторно"),
      //         ),
      //         const SizedBox(height: 12),
      //         ElevatedButton(
      //           onPressed: () async {
      //             await auth.checkEmailVerification();
      //             if (auth.isEmailVerified) {
      //               context.go('/');
      //             }
      //           },
      //           child: const Text("Проверить снова"),
      //         ),
      //         if (auth.errorMessage != null)
      //           Padding(
      //             padding: const EdgeInsets.only(top: 12),
      //             child: Text(
      //               auth.errorMessage!,
      //               style: const TextStyle(color: Colors.redAccent),
      //             ),
      //           ),
      //       ],
      //     ),
      //   ),
      // ),

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
            color: const Color(0xFF25282A),
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
                    "Confirm",
                    style: mainTextStyle,
                  ),
                  centerTitle: true,
                  leading: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        IconlyLight.arrow_left,
                        size: isMobile ? 24 : 46,
                      )),
                ),
                const SizedBox(height: 16),
                const Icon(Icons.email, size: 75, color: Colors.greenAccent),
                const SizedBox(height: 13),
                const Text(
                  "Please confirm your email address.",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed:
                      _resendAvailable ? () => _handleResendEmail(auth) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _resendAvailable
                        ? Colors.green
                        : const Color(0xFF25282A),
                    side: BorderSide(
                      color: _resendAvailable
                          ? Colors.transparent
                          : Colors.white54,
                      width: _resendAvailable ? 0 : 1,
                    ),
                  ),
                  child: Text(_resendText),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await auth.checkEmailVerification();
                    if (auth.isEmailVerified) {
                      context.go('/');
                    }
                  },
                  child: const Text("Проверить снова"),
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
    );
  }
}
