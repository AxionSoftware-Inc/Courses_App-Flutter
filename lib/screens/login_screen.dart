import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_repository.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPhoneMode = false;
  bool _codeSent = false;
  bool _obscurePassword = true;
  String _verificationId = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.length < 6) {
      _showError("Email va kamida 6 belgili parol kiriting");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = AuthService.instance;
      final result = _isLogin
          ? await auth.signInWithEmail(email: email, password: password)
          : await auth.registerWithEmail(email: email, password: password);

      if (result.user != null) {
        await UserRepository.instance.ensureUserProfile(result.user!);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Autentifikatsiya xatosi");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final result = await AuthService.instance.signInWithGoogle();
      final user = result?.user;
      if (user != null) {
        await UserRepository.instance.ensureUserProfile(user);
      }
    } catch (e) {
      _showError("Google orqali kirishda xato: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyPhone() async {
    var phone = _phoneController.text.trim().replaceAll(' ', '');
    if (phone.isEmpty) {
      _showError("Telefon raqam kiriting");
      return;
    }
    if (!phone.startsWith('+')) {
      phone = '+998$phone';
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (credential) async {
          final result = await FirebaseAuth.instance.signInWithCredential(
            credential,
          );
          if (result.user != null) {
            await UserRepository.instance.ensureUserProfile(result.user!);
          }
        },
        verificationFailed: (e) {
          _showError(e.message ?? "SMS tekshiruvida xato");
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
        codeSent: (verificationId, resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
              _isLoading = false;
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tasdiqlash kodi yuborildi")),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showError("Telefon tasdiqlashda xato: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length < 6) {
      _showError("6 xonali kod kiriting");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      if (result.user != null) {
        await UserRepository.instance.ensureUserProfile(result.user!);
      }
    } catch (e) {
      _showError("Kod noto'g'ri yoki muddati tugagan");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: IntrinsicHeight(
                    child: wide
                        ? Row(
                            children: [
                              Expanded(child: _buildMarketing(context)),
                              const SizedBox(width: 20),
                              Expanded(child: _buildAuthCard(context, isDark)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMarketing(context),
                              const SizedBox(height: 20),
                              _buildAuthCard(context, isDark),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMarketing(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "Premium learning stack",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          "Nexa Learn",
          style: theme.textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: 42,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Kurslar, progress nazorati va premium onboarding bitta silliq oqimga yig'ildi.",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.84),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _FeatureTile(
              icon: Icons.auto_graph_rounded,
              title: "Natija nazorati",
              subtitle: "Progress va tugallash foizi",
            ),
            _FeatureTile(
              icon: Icons.play_circle_outline_rounded,
              title: "Real content flow",
              subtitle: "Kurs, preview va continue learning",
            ),
            _FeatureTile(
              icon: Icons.security_rounded,
              title: "Firebase ready",
              subtitle: "Keyin backendga ko'chirish oson",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1F1B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isPhoneMode
                ? (_codeSent ? "Kod tasdiqlash" : "Telefon orqali kirish")
                : (_isLogin ? "Hisobga kirish" : "Yangi account ochish"),
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _isPhoneMode
                ? "Raqamni tasdiqlang va ilovaga bir zumda kiring."
                : "Mentorlar, premium kurslar va learning dashboard sizni kutmoqda.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (_isPhoneMode) ...[
            if (!_codeSent)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Telefon",
                  hintText: "90 123 45 67",
                  prefixIcon: Icon(Icons.phone_rounded),
                  prefixText: "+998 ",
                ),
              )
            else
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: "SMS kod",
                  hintText: "123456",
                  prefixIcon: Icon(Icons.lock_clock_rounded),
                ),
              ),
          ] else ...[
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "you@example.com",
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Parol",
                hintText: "Kamida 6 belgi",
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_isPhoneMode
                        ? (_codeSent ? _verifyOtp : _verifyPhone)
                        : _submitEmail),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      _isPhoneMode
                          ? (_codeSent ? "Tasdiqlash" : "Kod yuborish")
                          : (_isLogin ? "Kirish" : "Ro'yxatdan o'tish"),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          if (!_isPhoneMode) ...[
            Row(
              children: [
                Expanded(child: Divider(color: theme.dividerColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text("yoki", style: theme.textTheme.bodySmall),
                ),
                Expanded(child: Divider(color: theme.dividerColor)),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
                label: const Text("Google bilan davom etish"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isPhoneMode = true;
                          _codeSent = false;
                        });
                      },
                icon: const Icon(Icons.phone_android_rounded),
                label: const Text("Telefon orqali kirish"),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            child: TextButton(
              onPressed: () {
                setState(() {
                  if (_isPhoneMode) {
                    _isPhoneMode = false;
                    _codeSent = false;
                    _otpController.clear();
                  } else {
                    _isLogin = !_isLogin;
                  }
                });
              },
              child: Text(
                _isPhoneMode
                    ? "Email login rejimiga qaytish"
                    : (_isLogin
                          ? "Account yo'qmi? Ro'yxatdan o'ting"
                          : "Account bormi? Kirish"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
