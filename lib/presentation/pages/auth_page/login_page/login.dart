import 'package:flow/core/utils/provider/auth_provider.dart';
import 'package:flow/generated/l10n.dart';
import 'package:flow/presentation/pages/auth_page/login_page/login_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showToggleIcon = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _passwordController.addListener(() {
      setState(() {
        _showToggleIcon = _passwordController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Widget _inputField(String label,
      {bool obscure = false, TextEditingController? controller}) {
    final layout = LoginLayout(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 300,
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style:  TextStyle(color:  isDark? Colors.white: Colors.black),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: layout.hintTextStyle,
          filled: true,
          // fillColor: const Color(0xFF2C2C2C),
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _mainButton(String label, {required VoidCallback onPressed}) {
    return SizedBox(
      width: 300,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
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
        auth.clearError();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final layout = LoginLayout(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 20),
        Column(
          children: [
            Text(S.of(context).LoginWelcomeText, style: layout.mainTextStyle),
            const SizedBox(height: 8),
            Text(S.of(context).LoginWelcomeSubText, style: layout.subTextStyle),
            const SizedBox(height: 100),
            _inputField(S.of(context).LoginHintEmailText, controller: _emailController),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              height: 50,
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style:  TextStyle( color:  isDark? Colors.white: Colors.black,),
                decoration: InputDecoration(
                  hintText: S.of(context).RegHintPassword,
                  hintStyle: layout.hintTextStyle,
                  filled: true,
                  // fillColor: const Color(0xFF2C2C2C),
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _showToggleIcon
                      ? IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? IconlyBold.show
                                : IconlyLight.show,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary, //Colors.white54
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/auth/forgot-password'),
                child:  Text(S.of(context).LoginBtnForgotPassword,
                    style: TextStyle(color: Theme.of(context)
                                .colorScheme
                                .secondary,)),
              ),
            ),
            const SizedBox(height: 40),
            _mainButton(_isLoading ? S.of(context).LoginBtnHintLoading : S.of(context).LoginBtnHintSignIn,
                onPressed: () async {
              FocusScope.of(context).unfocus();
              final auth = Provider.of<AuthProvider>(context, listen: false);
              setState(() => _isLoading = true);
              await auth.login(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );
              setState(() => _isLoading = false);
              if (auth.isLoggedIn) {
                final user = auth.user;
                if (user != null && !user.emailVerified) {
                  // ignore: use_build_context_synchronously
                  context.go('/auth/verify-email');
                } else {
                  // ignore: use_build_context_synchronously
                  context.go('/');
                }
              }
            }),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 34, top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(S.of(context).LoginTextDontAccount,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary)), // Colors.white60
              GestureDetector(
                onTap: () => context.go('/auth/register'),
                child:  Text(S.of(context).LoginBtnHintSignUp,
                    style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      // backgroundColor: const Color(0xFF121212),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? 360 : 450,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: isMobile
                    ? content
                    : Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1C),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: content,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
