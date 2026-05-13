import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _fade     = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _scale    = Tween<double>(begin: 0.7, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)));
    _progress = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeInOut)));
    _ctrl.forward();
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        await SessionService.clearSession();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final state = context.read<AppState>();
      AuthProfile? profile = await SessionService.loadSession();
      final missingName = profile == null ||
          profile.fullName == null ||
          profile.fullName!.trim().isEmpty;
      final missingProviderType = profile != null &&
          profile.role == 'provider' &&
          (profile.serviceType == null || profile.serviceType!.isEmpty);

      if (profile == null || missingProviderType || missingName) {
        profile = await AuthService.fetchProfile(currentUser.uid);
        await SessionService.saveSession(
          role: profile.role,
          serviceType: profile.serviceType,
          fullName: profile.fullName,
        );
      }

      state.setRole(profile.role);
      if (profile.role == 'provider' && profile.serviceType != null) {
        state.setServiceType(profile.serviceType!);
        await state.loadProviderAvailabilityFromFirestore();
      } else {
        state.setServiceType('');
      }
      state.setLoggedInFullName(profile.fullName ?? '');

      if (!mounted) return;
      final route = profile.role == 'provider'
          ? '/provider_navigation'
          : '/user_navigation';
      Navigator.pushReplacementNamed(context, route);
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.black, AppColors.navy, AppColors.blue],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo icon
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: AppColors.teal.withOpacity(0.2),
                        border: Border.all(color: AppColors.teal.withOpacity(0.5), width: 2),
                      ),
                      child: Image.asset(
                        'images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  RichText(text: const TextSpan(
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
                    children: [
                      TextSpan(text: 'Ay', style: TextStyle(color: AppColors.white)),
                      TextSpan(text: 'Khedma', style: TextStyle(color: AppColors.teal)),
                    ],
                  )),
                  const SizedBox(height: 8),
                  Text('سباك • كهربائي • دليفري',
                    style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.5), fontFamily: 'Cairo')),
                  const SizedBox(height: 48),
                  // Progress bar
                  Container(
                    width: 160, height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
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
