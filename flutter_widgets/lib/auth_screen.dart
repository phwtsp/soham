import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_styles.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context); // Close auth screen on success
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message ?? "Ocorreu um erro";
          if (e.code == 'weak-password') {
            _errorMessage = 'A senha fornecida é muito fraca.';
          } else if (e.code == 'email-already-in-use') {
            _errorMessage = 'A conta já existe para esse email.';
          } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
            _errorMessage = 'Usuário ou senha inválidos.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erro inesperado: $e";
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.backgroundDark, // Using dark theme as per app style
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Image Placeholder
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.backgroundDark, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                  image: const DecorationImage(
                    image: NetworkImage(
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuBiSqrFM5QghciFNI1_C-lt_UPmOicLr-V5cBFXBLFF1nHWQi9U44ebHrf9muygGCmcHhiJfCkNxjvbUlArMriL0YlmCucAw0-uZxq-_NFd83h3wyKX2_coghlniClie4-tDPluL7-7ICHZ409VOQNyx6Aj3jd7vkM2AO0O28-ToCedMuYcAe3EpeHoegO80uA9iUBl1mnaAuVNL9M5C-LIgXibafLTLGYmI7vy8yo0UDe5AtofhDfHTtSRcT1WZlcN9ENso2Ik8Kc"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Soham",
                style: GoogleFonts.splineSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandGreen,
                ),
              ),
              Text(
                "Encontre o seu centro.",
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),

              // Social Buttons (Placeholders)
              _SocialButton(
                text: "Entrar com Google",
                icon: Icons.g_mobiledata,
                onTap: () {}, // TODO: Implement Google Sign In
              ),
              const SizedBox(height: 12),
              _SocialButton(
                text: "Entrar com Apple",
                icon: Icons.apple,
                color: Colors.white,
                textColor: Colors.black,
                onTap: () {}, // TODO: Implement Apple Sign In
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.1))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "ou continuar com email",
                      style: GoogleFonts.splineSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white30,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.1))),
                ],
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Form
              _AuthInput(
                controller: _emailController,
                hint: "seu@email.com",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _AuthInput(
                controller: _passwordController,
                hint: "Sua senha",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Esqueceu a senha?",
                    style: GoogleFonts.splineSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandGreen,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.brandBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.brandBlue)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? "Entrar" : "Cadastrar",
                              style: GoogleFonts.splineSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => setState(() => _isLogin = !_isLogin),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.notoSans(
                        fontSize: 14, color: Colors.white70),
                    children: [
                      TextSpan(
                        text: _isLogin
                            ? "Não tem uma conta? "
                            : "Já tem uma conta? ",
                      ),
                      TextSpan(
                        text: _isLogin ? "Cadastre-se" : "Entrar",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;

  const _AuthInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.brandGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.brandGreen.withOpacity(0.5)),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.brandGreen.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  const _SocialButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor ?? Colors.white),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.splineSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
