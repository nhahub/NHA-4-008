import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProfile {
  final String role; // 'client' | 'provider'
  final String? serviceType; // for providers: 'electrician' | 'plumber' | 'delivery'

  const AuthProfile({required this.role, this.serviceType});
}

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  // ── Step 2: create the Firebase Auth account ─────────────────────────────
  static Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Step 3 (client): persist user doc ────────────────────────────────────
  static Future<void> saveClientProfile({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required String address,
    double? lat,
    double? lng,
    String? profileImageUrl,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid':      uid,
      'role':     'client',
      'fullName': fullName,
      'email':    email,
      'phone':    phone,
      'address':  address,
      if (profileImageUrl != null && profileImageUrl.trim().isNotEmpty)
        'profileImageUrl': profileImageUrl,
      if (lat != null && lng != null)
        'location': GeoPoint(lat, lng),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Step 3 (provider): persist provider doc ───────────────────────────────
  // Writes ONLY to the service-type collection:
  //   electricians/{uid}
  //   plumbers/{uid}
  //   delivery/{uid}
  static Future<void> saveProviderProfile({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required String serviceType,   // 'electrician' | 'plumber' | 'delivery'
    required int    yearsOfExperience,
    required double startingPrice,
    required String bio,
    String? profileImageUrl,
  }) async {
    // Map service type → collection name
    final collectionName = _serviceCollection(serviceType);

    await _db.collection(collectionName).doc(uid).set({
      'uid':               uid,
      'role':              'provider',
      'fullName':          fullName,
      'email':             email,
      'phone':             phone,
      if (profileImageUrl != null && profileImageUrl.trim().isNotEmpty)
        'profileImageUrl': profileImageUrl,
      'serviceType':       serviceType,
      'yearsOfExperience': yearsOfExperience,
      'startingPrice':     startingPrice,
      'bio':               bio,
      'rating':            0.0,
      'totalReviews':      0,
      'createdAt':         FieldValue.serverTimestamp(),
    });
  }

  /// Maps a service type string to its Firestore collection name.
  static String _serviceCollection(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'electrician': return 'electricians';
      case 'plumber':     return 'plumbers';
      case 'delivery':    return 'delivery';
      default:            return '${serviceType.toLowerCase()}s';
    }
  }

  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Determines whether the signed-in account is a client or provider.
  ///
  /// - clients:   `users/{uid}` exists
  /// - providers: one of `electricians/{uid}`, `plumbers/{uid}`, `delivery/{uid}` exists
  static Future<AuthProfile> fetchProfile(String uid) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final role = (userDoc.data()?['role'] as String?) ?? 'client';
      return AuthProfile(role: role);
    }

    const providerCollections = <String>['electricians', 'plumbers', 'delivery'];
    for (final col in providerCollections) {
      final doc = await _db.collection(col).doc(uid).get();
      if (doc.exists) {
        final data = doc.data() ?? const <String, dynamic>{};
        final serviceType = (data['serviceType'] as String?) ??
            (col == 'delivery' ? 'delivery' : col.substring(0, col.length - 1));
        return AuthProfile(role: 'provider', serviceType: serviceType);
      }
    }

    // If the user exists in Auth but no profile doc exists, treat as client.
    return const AuthProfile(role: 'client');
  }
}
