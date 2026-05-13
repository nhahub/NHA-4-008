import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ay_khedma/screens/provider/provider_navigation_screen.dart';
import 'package:ay_khedma/screens/user/user_navigation_screen.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';

class RegisterStep3Screen extends StatefulWidget {
  const RegisterStep3Screen({super.key});
  @override State<RegisterStep3Screen> createState() => _RegisterStep3ScreenState();
}

class _RegisterStep3ScreenState extends State<RegisterStep3Screen> {
  // ── Shared ────────────────────────────────────────────────────────────────
  bool   _loading  = false;
  String _error    = '';

  // ── Address fields ────────────────────────────────────────────────────────
  String? _selectedClientAddress;
  String? _selectedProviderAddress;
  final List<String> _addressOptions = const [
    'Masarra',
    'Maadi',
    'Korba',
    'Rod El-Farag',
  ];

  // ── Provider fields ───────────────────────────────────────────────────────
  String _selectedService = '';
  final _expCtr   = TextEditingController();
  final _priceCtr = TextEditingController();
  final _bioCtr   = TextEditingController();

  @override
  void dispose() {
    _expCtr.dispose();
    _priceCtr.dispose();
    _bioCtr.dispose();
    super.dispose();
  }

  // ── Firebase: create account then write Firestore doc ────────────────────
  Future<void> _submit() async {
    final state = context.read<AppState>();

    // Basic guard
    if (state.role == 'provider' && _selectedService.isEmpty) {
      setState(() => _error = 'Please select the service you offer.');
      return;
    }
    if (state.role == 'client' && _selectedClientAddress == null) {
      setState(() => _error = 'Please select your address.');
      return;
    }
    if (state.role == 'provider' && _selectedProviderAddress == null) {
      setState(() => _error = 'Please select your address.');
      return;
    }

    setState(() { _loading = true; _error = ''; });

    try {
      // 1. Create Firebase Auth user
      final credential = await AuthService.createAccount(
        email:    state.regEmail,
        password: state.regPassword,
      );
      final uid = credential.user!.uid;

      // Update display name
      await credential.user!.updateDisplayName(state.regFullName);

      // Write Firestore profile
      if (state.role == 'client') {
        await AuthService.saveClientProfile(
          uid:      uid,
          fullName: state.regFullName,
          email:    state.regEmail,
          phone:    state.regPhone,
          address:  _selectedClientAddress!,
          profileImageUrl: state.regProfileImageUrl,
        );
        await SessionService.saveSession(role: 'client', fullName: state.regFullName);
        if (!mounted) return;
        context.read<AppState>().setLoggedInFullName(state.regFullName);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const UserNavigationScreen()),
          (_) => false,
        );
      } else {
        await AuthService.saveProviderProfile(
          uid:               uid,
          fullName:          state.regFullName,
          email:             state.regEmail,
          phone:             state.regPhone,
          serviceType:       _selectedService,
          yearsOfExperience: int.tryParse(_expCtr.text) ?? 0,
          startingPrice:     double.tryParse(_priceCtr.text) ?? 0,
          bio:               _bioCtr.text.trim(),
          address:           _selectedProviderAddress!,
          profileImageUrl: state.regProfileImageUrl,
        );
        await SessionService.saveSession(
          role: 'provider',
          serviceType: _selectedService,
          fullName: state.regFullName,
        );
        if (!mounted) return;
        context.read<AppState>().setServiceType(_selectedService);
        context.read<AppState>().setLoggedInFullName(state.regFullName);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProviderNavigationScreen()),
          (_) => false,
        );
      }

      // Clear sensitive registration data from state
      state.clearRegistrationData();

    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _friendlyAuthError(e.code);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'This email is already registered. Try signing in.';
      case 'invalid-email':        return 'The email address is invalid.';
      case 'weak-password':        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed': return 'No internet connection. Please try again.';
      default: return 'Registration failed ($code). Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final role       = context.watch<AppState>().role;
    final isProvider = role == 'provider';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        AppHeader(
          title: 'Sign Up',
          subtitle: 'Step 3 of 3',
          onBack: _loading ? null : () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _progressSteps(3),
              const SizedBox(height: 24),

              if (_error.isNotEmpty) _errorBanner(_error),

              if (!isProvider) _buildClientStep(),
              if (isProvider)  _buildProviderStep(),
            ]),
          ),
        ),
        _homeIndicator(),
      ]),
    );
  }

  // ── Error banner ──────────────────────────────────────────────────────────
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
      Expanded(child: Text(msg, style: const TextStyle(
          fontSize: 12, color: Colors.red, fontFamily: 'Cairo'))),
    ]),
  );

  // ── CLIENT step ───────────────────────────────────────────────────────────
  Widget _buildClientStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Almost Done!', style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
    const SizedBox(height: 4),
    const Text('Set your location so providers can reach you',
        style: TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Cairo')),
    const SizedBox(height: 20),

    // Map placeholder — wire up google_maps_flutter or geolocator here
    GestureDetector(
      onTap: () {
        // TODO: open a map picker and write lat/lng back to state
      },
      child: Container(
        width: double.infinity, height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.teal.withOpacity(0.06),
          border: Border.all(color: AppColors.teal.withOpacity(0.3), width: 2),
        ),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.location_on_outlined, size: 36, color: AppColors.teal),
          SizedBox(height: 8),
          Text('Set your home location',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.teal, fontFamily: 'Cairo')),
          SizedBox(height: 4),
          Text('Tap to select on map',
              style: TextStyle(fontSize: 11, color: AppColors.gray, fontFamily: 'Cairo')),
        ]),
      ),
    ),
    const SizedBox(height: 16),

    DropdownButtonFormField<String>(
      value: _selectedClientAddress,
      isExpanded: true,
      items: _addressOptions
          .map((address) => DropdownMenuItem<String>(
                value: address,
                child: Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    color: AppColors.black,
                  ),
                ),
              ))
          .toList(),
      onChanged: (value) => setState(() {
        _selectedClientAddress = value;
        _error = '';
      }),
      style: const TextStyle(fontSize: 14, fontFamily: 'Cairo', color: AppColors.black),
      decoration: InputDecoration(
        hintText: 'Select your address',
        hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14, fontFamily: 'Cairo'),
        prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.gray),
        filled: true,
        fillColor: AppColors.border.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorderFocused(),
      ),
    ),
    const SizedBox(height: 16),

    _submitButton('Create Account'),
  ]);

  // ── PROVIDER step ─────────────────────────────────────────────────────────
  Widget _buildProviderStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('What service do you offer?', style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
    const SizedBox(height: 4),
    const Text('Select your specialty',
        style: TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Cairo')),
    const SizedBox(height: 18),

    Row(children: [
      Expanded(
          child: _serviceCard('electrician',
              Icons.electrical_services_outlined,
              'Electrician', 'كهربائي')
      ),
      const SizedBox(width: 10),
      Expanded(
          child: _serviceCard('plumber',
              Icons.plumbing_outlined,
              'Plumber',
              'سباك')
      ),
      const SizedBox(width: 10),
      Expanded(child: _serviceCard('delivery',
          Icons.delivery_dining_outlined,
          'Delivery',
          'دليفري',)
        ),
      ]
    ),
    const SizedBox(height: 18),

    _plainInput(_expCtr,   'Years of experience',      Icons.work_outline_rounded,   TextInputType.number),
    _plainInput(_priceCtr, 'Starting price (EGP/hr)',  Icons.attach_money_rounded,   TextInputType.number),
    DropdownButtonFormField<String>(
      value: _selectedProviderAddress,
      isExpanded: true,
      items: _addressOptions
          .map((address) => DropdownMenuItem<String>(
                value: address,
                child: Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    color: AppColors.black,
                  ),
                ),
              ))
          .toList(),
      onChanged: (value) => setState(() {
        _selectedProviderAddress = value;
        _error = '';
      }),
      style: const TextStyle(fontSize: 14, fontFamily: 'Cairo', color: AppColors.black),
      decoration: InputDecoration(
        hintText: 'Select your address',
        hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14, fontFamily: 'Cairo'),
        prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.gray),
        filled: true,
        fillColor: AppColors.border.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorderFocused(),
      ),
    ),
    const SizedBox(height: 16),

    // Bio
    Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: _bioCtr,
        maxLines: 3,
        style: const TextStyle(fontSize: 14, fontFamily: 'Cairo', color: AppColors.black),
        decoration: const InputDecoration(
          hintText: 'Brief description about your skills...',
          hintStyle: TextStyle(color: AppColors.gray, fontSize: 13, fontFamily: 'Cairo'),
          border: InputBorder.none, isDense: true,
        ),
      ),
    ),

    _submitButton('Create Provider Account'),
  ]);

  Widget _serviceCard(String type, IconData icon, String label, String arabicLabel) {
    final bool sel = _selectedService == type;
    return GestureDetector(
      onTap: () => setState(() { _selectedService = type; _error = ''; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? AppColors.teal : AppColors.border, width: sel ? 2.5 : 2),
          color: sel ? AppColors.teal.withOpacity(0.06) : Colors.white,
        ),
        child: Column(children: [
          Icon(icon, size: 26, color: sel ? AppColors.teal : AppColors.gray),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: sel ? AppColors.teal : AppColors.gray, fontFamily: 'Cairo')),
          Text(arabicLabel, style: TextStyle(fontSize: 10, color: Colors.grey[400], fontFamily: 'Cairo')),
        ]),
      ),
    );
  }

  Widget _plainInput(TextEditingController ctr, String hint, IconData icon, TextInputType kb) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: ctr,
          keyboardType: kb,
          style: const TextStyle(fontSize: 14, fontFamily: 'Cairo', color: AppColors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14, fontFamily: 'Cairo'),
            prefixIcon: Icon(icon, size: 20, color: AppColors.gray),
            filled: true,
            fillColor: AppColors.border.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: _inputBorder(), enabledBorder: _inputBorder(), focusedBorder: _inputBorderFocused(),
          ),
        ),
      );

  Widget _submitButton(String label) => _loading
      ? const Center(child: Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: CircularProgressIndicator()))
      : PrimaryButton(text: label, onTap: _submit);

  OutlineInputBorder _inputBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
  );
  OutlineInputBorder _inputBorderFocused() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
  );

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
