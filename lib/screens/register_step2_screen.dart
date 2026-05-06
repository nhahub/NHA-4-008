import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';

class RegisterStep2Screen extends StatefulWidget {
  const RegisterStep2Screen({super.key});
  @override State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtr   = TextEditingController();
  final _emailCtr  = TextEditingController();
  final _phoneCtr  = TextEditingController();
  final _passCtr   = TextEditingController();
  bool  _obscure   = true;
  final ImagePicker _picker = ImagePicker();
  String? _profileImageDataUrl; // data:image/...;base64,...

  @override
  void dispose() {
    _nameCtr.dispose();
    _emailCtr.dispose();
    _phoneCtr.dispose();
    _passCtr.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    // Persist in AppState so Step 3 can use it for the Firebase write
    context.read<AppState>().setRegistrationDetails(
      fullName: _nameCtr.text.trim(),
      email:    _emailCtr.text.trim(),
      phone:    _phoneCtr.text.trim(),
      password: _passCtr.text,
      profileImageUrl: _profileImageDataUrl ?? '',
    );

    Navigator.pushNamed(context, '/register-step3');
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 900,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);

      // Best-effort MIME from extension; fallback to jpeg.
      final name = file.name.toLowerCase();
      String mime = 'image/jpeg';
      if (name.endsWith('.png')) mime = 'image/png';
      if (name.endsWith('.gif')) mime = 'image/gif';
      if (name.endsWith('.webp')) mime = 'image/webp';

      setState(() {
        _profileImageDataUrl = 'data:$mime;base64,$b64';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick image. Please try again.')),
      );
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 42, height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                _pickProfileImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                _pickProfileImage(ImageSource.camera);
              },
            ),
            if (_profileImageDataUrl != null && _profileImageDataUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove photo',
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _profileImageDataUrl = null);
                },
              ),
          ]),
        ),
      ),
    );
  }

  Widget _profileImagePicker() {
    ImageProvider? img;
    final dataUrl = _profileImageDataUrl;
    if (dataUrl != null && dataUrl.startsWith('data:')) {
      final idx = dataUrl.indexOf('base64,');
      if (idx != -1) {
        final raw = dataUrl.substring(idx + 'base64,'.length);
        try {
          img = MemoryImage(base64Decode(raw));
        } catch (_) {
          img = null;
        }
      }
    }

    return Center(
      child: Column(children: [
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.border.withOpacity(0.35),
                backgroundImage: img,
                child: img == null
                    ? const Icon(Icons.person_outline_rounded, size: 42, color: AppColors.gray)
                    : null,
              ),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _showImageSourceSheet,
          child: const Text(
            'Add profile photo',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        AppHeader(
          title: 'Sign Up',
          subtitle: 'Step 2 of 3',
          onBack: () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _progressSteps(2),
                const SizedBox(height: 24),

                const Text('Your Details',
                    style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    fontFamily: 'Cairo')
                ),
                const SizedBox(height: 20),

                _profileImagePicker(),
                const SizedBox(height: 18),

                // Full Name
                _validatedInput(
                  controller: _nameCtr,
                  hint: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter your full name' : null,
                ),

                // Email
                _validatedInput(
                  controller: _emailCtr,
                  hint: 'Email Address',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
                    return null;
                  },
                ),

                // Phone
                _validatedInput(
                  controller: _phoneCtr,
                  hint: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter your phone number' : null,
                ),

                // Password
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _passCtr,
                    obscureText: _obscure,
                    style: const TextStyle(fontSize: 14, fontFamily: 'Cairo', color: AppColors.black),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter a password';
                      if (v.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14, fontFamily: 'Cairo'),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.gray),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 19, color: AppColors.gray),
                      ),
                      filled: true,
                      fillColor: AppColors.border.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                PrimaryButton(text: 'Continue', onTap: _continue),
              ]),
            ),
          ),
        ),
        _homeIndicator(),
      ]),
    );
  }

  /// Wraps a [TextFormField] with consistent styling + validation.
  Widget _validatedInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, fontFamily: 'Cairo', color: AppColors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14, fontFamily: 'Cairo'),
          prefixIcon: Icon(icon, size: 20, color: AppColors.gray),
          filled: true,
          fillColor: AppColors.border.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
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
    final done = step < current; final active = step == current;
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? AppColors.navy : active ? AppColors.teal : Colors.white,
          border: Border.all(
              color: done ? AppColors.navy : active ? AppColors.teal : AppColors.border, width: 2)),
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
