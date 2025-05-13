import 'package:flow/core/utils/provider/auth_provider/auth_provider.dart';
import 'package:flow/presentation/pages/auth_page/register_page/register_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showConfirm = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(() {
      final shouldShow = _passwordController.text.length >= 6;
      if (shouldShow != _showConfirm) {
        setState(() => _showConfirm = shouldShow);
      }
    });
  }

  void register(AuthProvider auth) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (_showConfirm && password != confirm) {
      setState(() => _errorText = "Passwords don't match");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    await auth.register(email, password);

    setState(() => _isLoading = false);

    if (auth.errorMessage != null) {
      setState(() => _errorText = auth.errorMessage);
    } else {
      context.go('/auth/verify-email');
    }
  }

  Widget _inputField(String label,
      {bool obscure = false,
      required TextEditingController controller,
      Widget? suffixIcon}) {
    return SizedBox(
      width: 300,
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: RegisterLayout.hintTextStyle,
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  //   Widget _inputField(String label,
  //     {bool obscure = false, TextEditingController? controller}) {
  //   return SizedBox(
  //     width: 300,
  //     height: 50,
  //     child: TextField(
  //       controller: controller,
  //       obscureText: obscure,
  //       style: const TextStyle(color: Colors.white),
  //       decoration: InputDecoration(
  //         hintText: label,
  //         hintStyle: RegisterLayout.hintTextStyle,
  //         filled: true,
  //         fillColor: const Color(0xFF2C2C2C),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(16),
  //           borderSide: BorderSide.none,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = Provider.of<AuthProvider>(context);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isMobile) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: size.height * 0.14),
                          child: Column(
                            children: [
                              Text("Create Account",
                                  style: RegisterLayout.mainTextStyle),
                              SizedBox(height: size.height * 0.19),
                              _inputField("Email",
                                  controller: _emailController),
                              const SizedBox(height: 16),
                              _inputField(
                                "Password",
                                controller: _passwordController,
                                obscure: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? IconlyBold.show
                                        : IconlyLight.show,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: _showConfirm
                                    ? Column(
                                        children: [
                                          const SizedBox(height: 16),
                                          _inputField("Confirm Password",
                                              controller: _confirmController,
                                              obscure: _obscureConfirm,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureConfirm
                                                      ? IconlyBold.show
                                                      : IconlyLight.show,
                                                  color: Colors.white54,
                                                ),
                                                onPressed: () => setState(() =>
                                                    _obscureConfirm =
                                                        !_obscureConfirm),
                                              )),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              if (_errorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _errorText!,
                                    style: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                ),
                              SizedBox(height: size.height * 0.12),
                              SizedBox(
                                width: 300,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    register(auth);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                      _isLoading ? "Loading..." : "Register"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24, top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Do You Have An Account? ",
                                  style: TextStyle(color: Colors.white60)),
                              GestureDetector(
                                onTap: () => context.go('/auth/login'),
                                child: const Text("Sign In",
                                    style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget WebLayout() {
    final auth = Provider.of<AuthProvider>(context);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isMobile ? 360 : 450,
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            const Text("Create Account",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _inputField("Email", controller: _emailController),
            const SizedBox(height: 16),
            _inputField("Password",
                controller: _passwordController,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? IconlyBold.show : IconlyLight.show,
                    color: Colors.white54,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showConfirm
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        _inputField("Confirm Password",
                            controller: _confirmController,
                            obscure: _obscureConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? IconlyBold.show
                                    : IconlyLight.show,
                                color: Colors.white54,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            )),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  register(auth);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_isLoading ? "Loading..." : "Register"),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? ",
                    style: TextStyle(color: Colors.white60)),
                GestureDetector(
                  onTap: () => context.go('/auth/login'),
                  child: const Text("Sign In",
                      style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w500)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
