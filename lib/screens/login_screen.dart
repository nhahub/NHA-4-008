import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../models/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final credential = await AuthService.signIn(email: email, password: pass);
      final uid = credential.user?.uid;
      if (uid == null) {
        throw StateError('Missing user after sign-in.');
      }

      final profile = await AuthService.fetchProfile(uid);
      await SessionService.saveSession(
        role: profile.role,
        serviceType: profile.serviceType,
      );

      if (!mounted) return;
      context.read<AppState>().setRole(profile.role);
      if (profile.role == 'provider' && profile.serviceType != null) {
        context.read<AppState>().setServiceType(profile.serviceType!);
      }

      final route = profile.role == 'provider' ? '/provider_navigation' : '/user_navigation';
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _friendlyAuthError(e.code);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return 'Login failed ($code). Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        // ── Header ──
        AppHeader(
          title: 'Login',
          subtitle: 'Welcome Back',
          trailing: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 32),
          ),
        ),

        // ── Body ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_error.isNotEmpty) _errorBanner(_error),

              AppInput(hint: 'Email Address', icon: Icons.mail_outline_rounded,
                controller: _emailCtrl, keyboardType: TextInputType.emailAddress),

              AppInput(
                hint: 'Password', icon: Icons.lock_outline_rounded,
                controller: _passCtrl, obscure: _obscure,
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 19, color: AppColors.gray),
                ),
              ),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?', style: TextStyle(
                    color: AppColors.teal, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                ),
              ),
              const SizedBox(height: 8),

              _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : PrimaryButton(
                      text: 'Sign In',
                      onTap: _login,
                    ),
              const SizedBox(height: 28),

              // Divider
              Row(children: [
                const Expanded(
                    child: Divider(
                        color: AppColors.border)
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                      'Or continue with',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray.withOpacity(0.8),
                          fontFamily: 'Cairo')
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ]),
              const SizedBox(height: 20),

              // Social buttons
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _socialBtn(color: const Color(0xFF1877F2), icon: Icons.facebook_rounded),
                const SizedBox(width: 16),
                _socialBtn(color: const Color(0xFFEA4335), icon: Icons.g_mobiledata_rounded),
              ]),
              const SizedBox(height: 24),

              // Sign up link
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo')),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Sign Up', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teal, fontFamily: 'Cairo')),
                ),
              ]),
            ]),
          ),
        ),
        _homeIndicator(),
      ]),
    );
  }

  Widget _socialBtn({required Color color, required IconData icon}) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.5),
        color: AppColors.white,
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }

  Widget _homeIndicator() => Container(
    width: 130, height: 5,
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(3)),
  );

  Widget _errorBanner(String msg) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.withOpacity(0.3)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline, color: Colors.red, size: 18),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          msg,
          style: const TextStyle(fontSize: 12, color: Colors.red, fontFamily: 'Cairo'),
        ),
      ),
    ]),
  );
}
