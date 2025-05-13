// import 'package:flow/core/utils/provider/auth_provider/auth_provider.dart';
// import 'package:flow/presentation/pages/auth_page/login_page/login_layout.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:iconly/iconly.dart';
// import 'package:provider/provider.dart';
// import 'package:responsive_framework/responsive_framework.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _showToggleIcon = false;

//   @override
//   void initState() {
//     super.initState();

//     // Разрешаем только портрет
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     _passwordController.addListener(() {
//       setState(() {
//         _showToggleIcon = _passwordController.text.isNotEmpty;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     // Возвращаем все ориентации
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     super.dispose();
//   }

//   Widget _inputField(String label,
//       {bool obscure = false, TextEditingController? controller}) {
//     return SizedBox(
//       width: 300,
//       height: 50,
//       child: TextField(
//         controller: controller,
//         obscureText: obscure,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           hintText: label,
//           hintStyle: LoginLayout.hintTextStyle,
//           filled: true,
//           fillColor: const Color(0xFF2C2C2C),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _mainButton(String label, {required VoidCallback onPressed}) {
//     return SizedBox(
//       width: 300,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.green,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         child: Text(label, style: const TextStyle(fontSize: 16)),
//       ),
//     );
//   }

//   Widget _googleButton({required VoidCallback onPressed}) {
//     return SizedBox(
//       width: 300,
//       height: 50,
//       child: OutlinedButton.icon(
//         onPressed: onPressed,
//         style: OutlinedButton.styleFrom(
//           backgroundColor: Colors.white,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         // icon: Image.asset('assets/icons/google.png', height: 20),
//         label: const Text(
//           "Sign In with Google",
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//     );
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final auth = Provider.of<AuthProvider>(context);
//     if (auth.errorMessage != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(auth.errorMessage!),
//             backgroundColor: Colors.redAccent,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//         auth.clearError(); // Очистим после показа
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isMobile = ResponsiveBreakpoints.of(context).isMobile;
//     final isTablet = ResponsiveBreakpoints.of(context).isTablet;
//     final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

//     return Scaffold(
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         behavior: HitTestBehavior.opaque,
//         child: LayoutBuilder(builder: (context, constraints) {
//           return SingleChildScrollView(
//             physics: const ClampingScrollPhysics(),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight),
//               child: IntrinsicHeight(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(top: size.height * 0.12),
//                       child: Column(
//                         children: [
//                           Text("Welcome back!",
//                               style: LoginLayout.mainTextStyle),
//                           const SizedBox(height: 8),
//                           Text("please sign in to your account",
//                               style: LoginLayout.subTextStyle),
//                           SizedBox(height: size.height * 0.19),

//                           // Email
//                           _inputField("Email", controller: _emailController),
//                           const SizedBox(height: 16),

//                           // Password
//                           // _inputField("Password",
//                           //     controller: _passwordController, obscure: true),

//                           SizedBox(
//                             width: 300,
//                             height: 50,
//                             child: TextField(
//                               controller: _passwordController,
//                               obscureText: _obscurePassword,
//                               style: const TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: "Password",
//                                 hintStyle: LoginLayout.hintTextStyle,
//                                 filled: true,
//                                 fillColor: const Color(0xFF2C2C2C),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 suffixIcon: _showToggleIcon
//                                     ? IconButton(
//                                         icon: Icon(
//                                           _obscurePassword
//                                               ? IconlyBold.show
//                                               : IconlyLight.show,
//                                           color: Colors.white54,
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             _obscurePassword =
//                                                 !_obscurePassword;
//                                           });
//                                         },
//                                       )
//                                     : null,
//                               ),
//                             ),
//                           ),

//                           // Forgot
//                           Padding(
//                             padding: EdgeInsets.only(
//                               right: size.width * 0.13,
//                               top: 6,
//                               bottom: 24,
//                             ),
//                             child: Align(
//                               alignment: Alignment.centerRight,
//                               child: TextButton(
//                                 onPressed: () {
//                                   context.go('/auth/forgot-password');
//                                 },
//                                 child: const Text(
//                                   "Forgot Password?",
//                                   style: TextStyle(color: Colors.white54),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: size.height * 0.1),
//                           // Sign In
//                           _mainButton(_isLoading ? "Loading..." : "Sign In",
//                               onPressed: () async {
//                             FocusScope.of(context).unfocus();
//                             final auth = Provider.of<AuthProvider>(context,
//                                 listen: false);

//                             setState(() => _isLoading = true);

//                             await auth.login(
//                               _emailController.text.trim(),
//                               _passwordController.text.trim(),
//                             );

//                             setState(() => _isLoading = false);

//                             if (auth.isLoggedIn) {
//                               final currentUser = auth.user;

//                               if (currentUser != null &&
//                                   !currentUser.emailVerified) {
//                                 // если почта не подтверждена — перейти на страницу подтверждения
//                                 context.go('/auth/verify-email');
//                               } else {
//                                 // если подтверждена — перейти на главную
//                                 context.go('/');
//                               }
//                             }
//                           }),

//                           // const SizedBox(height: 16),

//                           // Google
//                           // _googleButton(onPressed: () async {
//                           //   final auth = Provider.of<AuthProvider>(context,
//                           //       listen: false);
//                           //   setState(() => _isLoading = true);

//                           //   await auth.signInWithGoogle();

//                           //   setState(() => _isLoading = false);

//                           //   if (auth.isLoggedIn) {
//                           //     final user = auth.user;
//                           //     if (user != null &&
//                           //         !user.emailVerified &&
//                           //         !user.email!.endsWith('@gmail.com')) {
//                           //       // Для Gmail аккаунтов проверка не требуется
//                           //       context.go('/auth/verify-email');
//                           //     } else {
//                           //       context.go('/');
//                           //     }
//                           //   }
//                           // }),
//                         ],
//                       ),
//                     ),

//                     // Always at bottom
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 24),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             "Don’t Have An Account? ",
//                             style: TextStyle(color: Colors.white60),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               context.go('/auth/register');
//                             },
//                             child: const Text(
//                               "Sign Up",
//                               style: TextStyle(
//                                 color: Colors.greenAccent,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }



import 'package:flow/core/utils/provider/auth_provider/auth_provider.dart';
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
    return SizedBox(
      width: 300,
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: LoginLayout.hintTextStyle,
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 20),
        Column(
          children: [
            Text("Welcome back!", style: LoginLayout.mainTextStyle),
            const SizedBox(height: 8),
            Text("please sign in to your account", style: LoginLayout.subTextStyle),
            const SizedBox(height: 100),
            _inputField("Email", controller: _emailController),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              height: 50,
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: LoginLayout.hintTextStyle,
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _showToggleIcon
                      ? IconButton(
                          icon: Icon(
                            _obscurePassword ? IconlyBold.show : IconlyLight.show,
                            color: Colors.white54,
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
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.white54)),
              ),
            ),
            const SizedBox(height: 40),
            _mainButton(_isLoading ? "Loading..." : "Sign In", onPressed: () async {
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
                  context.go('/auth/verify-email');
                } else {
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
              const Text("Don’t Have An Account? ", style: TextStyle(color: Colors.white60)),
              GestureDetector(
                onTap: () => context.go('/auth/register'),
                child: const Text("Sign Up", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w500)),
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
            // child: ConstrainedBox(
            //   constraints: BoxConstraints(
            //     maxWidth: isMobile ? 360 : isTablet ? 450 : 450,
                
            //   ),
            //   child: isMobile
            //       ? content
            //       : Container(
            //           padding: const EdgeInsets.all(32),
            //           decoration: BoxDecoration(
            //             color: const Color(0xFF1C1C1C),
            //             borderRadius: BorderRadius.circular(24),
            //             border: Border.all(color: Colors.white10),
            //           ),
            //           child: content,
            //         ),
            // ),
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

