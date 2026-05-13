import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class SessionService {
  static const _roleKey = 'session_role';
  static const _serviceTypeKey = 'session_service_type';
  static const _fullNameKey = 'session_full_name';

  static Future<void> saveSession({
    required String role,
    String? serviceType,
    String? fullName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roleKey, role);

      if (serviceType != null && serviceType.trim().isNotEmpty) {
        await prefs.setString(_serviceTypeKey, serviceType);
      } else {
        await prefs.remove(_serviceTypeKey);
      }

      if (fullName != null && fullName.trim().isNotEmpty) {
        await prefs.setString(_fullNameKey, fullName.trim());
      } else {
        await prefs.remove(_fullNameKey);
      }
    } catch (_) {

    }
  }

  static Future<AuthProfile?> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(_roleKey);
      if (role == null || role.isEmpty) return null;

      final serviceType = prefs.getString(_serviceTypeKey);
      final fullName = prefs.getString(_fullNameKey);
      return AuthProfile(role: role, serviceType: serviceType, fullName: fullName);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_roleKey);
      await prefs.remove(_serviceTypeKey);
      await prefs.remove(_fullNameKey);
    } catch (_) {

    }
  }
}
