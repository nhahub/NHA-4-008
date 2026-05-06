import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ─── Primary Button ───────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color = AppColors.navy,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
        ),
        child: Text(text,
          style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppColors.white, fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}

// ─── Input Field ─────────────────────────────────────────────
class AppInput extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Widget? suffix;

  const AppInput({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Row(children: [
        Icon(icon, size: 19, color: AppColors.gray),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, fontFamily: 'Cairo', color: AppColors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14, fontFamily: 'Cairo'),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (suffix != null) suffix!,
      ]),
    );
  }
}

// ─── App Header ──────────────────────────────────────────────
class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 36),
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Stack(children: [
        // background circles
        Positioned(top: -30, right: -30,
          child: Container(width: 160, height: 160,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.teal.withOpacity(0.15)))),
        Positioned(bottom: -20, left: -20,
          child: Container(width: 110, height: 110,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.blue.withOpacity(0.25)))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900,
                color: AppColors.white, fontFamily: 'Cairo')),
              Text(subtitle, style: TextStyle(
                fontSize: 13, color: AppColors.white.withOpacity(0.65),
                fontFamily: 'Cairo')),
            ]),
            if (onBack != null)
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                ),
              )
            else if (trailing != null) trailing!,
          ],
        ),
      ]),
    );
  }
}

// ─── Section Label ───────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w700,
      color: AppColors.black, fontFamily: 'Cairo')),
  );
}

// ─── Rating Stars ────────────────────────────────────────────
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  const RatingStars({super.key, required this.rating, this.size = 13});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < rating.floor() ? Icons.star : Icons.star_border,
        size: size, color: const Color(0xFFF59E0B),
      )),
    );
  }
}
