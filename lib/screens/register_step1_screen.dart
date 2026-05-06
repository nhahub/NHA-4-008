import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});
  @override State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  String _selected = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        AppHeader(
          title: 'Sign Up',
          subtitle: 'Step 1 of 3',
          onBack: () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              _progressSteps(1),
              const SizedBox(height: 24),

              const Text('من أنت؟', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900,
                  color: AppColors.black, fontFamily: 'Cairo')),
              const SizedBox(height: 4),
              const Text('Who are you?', style: TextStyle(
                  fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo')),
              const SizedBox(height: 4),
              Text('اختار نوع حسابك للبدء', style: TextStyle(
                  fontSize: 12, color: AppColors.gray.withOpacity(0.8), fontFamily: 'Cairo')),
              const SizedBox(height: 28),

              Row(children: [
                Expanded(child: _roleCard(
                  role: 'client',
                  icon: Icons.person_outline_rounded,
                  label: 'Client',
                  sublabel: 'أحتاج خدمة\nI need a service',
                )),
                const SizedBox(width: 14),
                Expanded(child: _roleCard(
                  role: 'provider',
                  icon: Icons.build_outlined,
                  label: 'Provider',
                  sublabel: 'أقدم خدمة\nI offer a service',
                )),
              ]),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Continue',
                onTap: () {
                  if (_selected.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select your role to continue.')),
                    );
                    return;
                  }
                  context.read<AppState>().setRole(_selected);
                  Navigator.pushNamed(context, '/register-step2');
                },
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Already have an account? ',
                    style: TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo')),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Sign In', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.teal, fontFamily: 'Cairo')),
                ),
              ]),
            ]),
          ),
        ),
        _homeIndicator(),
      ]),
    );
  }

  Widget _roleCard({
    required String role,
    required IconData icon,
    required String label,
    required String sublabel,
  }) {
    final bool sel = _selected == role;
    return GestureDetector(
      onTap: () => setState(() => _selected = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? AppColors.teal : AppColors.border,
            width: sel ? 2.5 : 2,
          ),
          color: sel ? AppColors.teal.withOpacity(0.06) : Colors.white,
          boxShadow: sel
              ? [BoxShadow(color: AppColors.teal.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 6))]
              : [BoxShadow(color: AppColors.navy.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: sel ? AppColors.teal.withOpacity(0.15) : AppColors.teal.withOpacity(0.08),
            ),
            child: Icon(icon, size: 30, color: sel ? AppColors.teal : AppColors.gray),
          ),
          const SizedBox(height: 14),
          Text(label, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: sel ? AppColors.teal : AppColors.gray, fontFamily: 'Cairo')),
          const SizedBox(height: 5),
          Text(sublabel, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[400], fontFamily: 'Cairo', height: 1.5)),
        ]),
      ),
    );
  }

  Widget _progressSteps(int current) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (int i = 1; i <= 3; i++) ...[
        _stepDot(i, current),
        if (i < 3) Expanded(child: Container(height: 2,
            color: i < current ? AppColors.navy : AppColors.border)),
      ],
    ]);
  }

  Widget _stepDot(int step, int current) {
    final bool done   = step < current;
    final bool active = step == current;
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.navy : active ? AppColors.teal : Colors.white,
        border: Border.all(
            color: done ? AppColors.navy : active ? AppColors.teal : AppColors.border, width: 2),
      ),
      child: Center(child: done
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : Text('$step', style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: active ? Colors.white : AppColors.gray))),
    );
  }

  Widget _homeIndicator() => Container(
    width: 130, height: 5,
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
        color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(3)),
  );
}
