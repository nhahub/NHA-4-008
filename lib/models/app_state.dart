import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/provider_model.dart';

class AppState extends ChangeNotifier {
  // ── Existing fields ───────────────────────────────────────────────────────
  String _role = '';
  String _serviceType = '';
  UserModel? _currentUser;
  ProviderModel? _selectedProvider;
  bool _isOnline = true;

  String get role => _role;
  String get serviceType => _serviceType;
  UserModel? get currentUser => _currentUser;
  ProviderModel? get selectedProvider => _selectedProvider;
  bool get isOnline => _isOnline;

  void setRole(String r) { _role = r; notifyListeners(); }
  void setServiceType(String s) { _serviceType = s; notifyListeners(); }
  void setUser(UserModel u) { _currentUser = u; notifyListeners(); }
  void selectProvider(ProviderModel p) { _selectedProvider = p; notifyListeners(); }
  void toggleOnline() { _isOnline = !_isOnline; notifyListeners(); }

  // ── Temporary registration fields (Step 2 → Step 3) ──────────────────────
  // These hold form data in memory between screens and are cleared after
  // the Firebase account is successfully created.
  String _regFullName = '';
  String _regEmail    = '';
  String _regPhone    = '';
  String _regPassword = '';
  String _regProfileImageUrl = '';

  String get regFullName => _regFullName;
  String get regEmail    => _regEmail;
  String get regPhone    => _regPhone;
  String get regPassword => _regPassword;
  String get regProfileImageUrl => _regProfileImageUrl;

  void setRegistrationDetails({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? profileImageUrl,
  }) {
    _regFullName = fullName;
    _regEmail    = email;
    _regPhone    = phone;
    _regPassword = password;
    if (profileImageUrl != null) _regProfileImageUrl = profileImageUrl;
    notifyListeners();
  }

  /// Call this after Firebase account creation succeeds to wipe sensitive data.
  void clearRegistrationData() {
    _regFullName = '';
    _regEmail    = '';
    _regPhone    = '';
    _regPassword = '';
    _regProfileImageUrl = '';
    notifyListeners();
  }
}
