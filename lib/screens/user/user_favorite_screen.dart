import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/provider_model.dart';
import '../../theme/app_colors.dart';

class UserFavoriteScreen extends StatefulWidget {
  const UserFavoriteScreen({super.key});

  @override
  State<UserFavoriteScreen> createState() => _UserFavoriteScreenState();
}

class _UserFavoriteScreenState extends State<UserFavoriteScreen> {
  static const _serviceCollections = <String, String>{
    'electricians': 'electrician',
    'plumbers': 'plumber',
    'delivery': 'delivery',
  };

  static ProviderModel _providerFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String fallbackServiceType,
  ) {
    final data = doc.data() ?? {};
    return ProviderModel(
      id: doc.id,
      name: (data['fullName'] as String?)?.trim().isNotEmpty == true
          ? (data['fullName'] as String)
          : 'Provider',
      serviceType: (data['serviceType'] as String?)?.trim().isNotEmpty == true
          ? (data['serviceType'] as String)
          : fallbackServiceType,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      jobsDone: (data['totalReviews'] as num?)?.toInt() ?? 0,
      experience: (data['yearsOfExperience'] as num?)?.toInt() ?? 0,
      startingPrice: (data['startingPrice'] as num?)?.toDouble() ?? 0.0,
      bio: (data['bio'] as String?) ?? '',
      distanceKm: 0.0,
      isAvailable: true,
    );
  }

  static Future<({ProviderModel model, String profileImageUrl})?>
      _fetchProviderById(String providerId) async {
    final db = FirebaseFirestore.instance;
    final futures = _serviceCollections.entries
        .map((e) => db.collection(e.key).doc(providerId).get());
    final snaps = await Future.wait(futures);
    var i = 0;
    for (final entry in _serviceCollections.entries) {
      final snap = snaps[i];
      i++;
      if (snap.exists && snap.data() != null) {
        final data = snap.data()!;
        final imageUrl =
            (data['profileImageUrl'] as String?)?.trim() ?? '';
        return (
          model: _providerFromDoc(snap, entry.value),
          profileImageUrl: imageUrl,
        );
      }
    }
    return null;
  }

  static Future<List<({ProviderModel provider, String profileImageUrl})>>
      _resolveFavoritesOrdered(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final sorted = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs);
    sorted.sort((a, b) {
      final ta = a.data()['addedAt'];
      final tb = b.data()['addedAt'];
      if (ta is Timestamp && tb is Timestamp) {
        return tb.compareTo(ta);
      }
      if (ta is Timestamp) return -1;
      if (tb is Timestamp) return 1;
      return 0;
    });

    final out = <({ProviderModel provider, String profileImageUrl})>[];
    for (final d in sorted) {
      final id = (d.data()['providerId'] as String?)?.trim().isNotEmpty == true
          ? (d.data()['providerId'] as String)
          : d.id;
      final row = await _fetchProviderById(id);
      if (row != null) {
        out.add((provider: row.model, profileImageUrl: row.profileImageUrl));
      }
    }
    return out;
  }

  IconData _serviceIcon(String type) {
    switch (type) {
      case 'electrician':
        return Icons.electrical_services_outlined;
      case 'plumber':
        return Icons.plumbing_outlined;
      case 'delivery':
        return Icons.delivery_dining_outlined;
      default:
        return Icons.build_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Sign in to see your favorite providers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('favorites')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Could not load favorites. Please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'No favorites yet. Tap the heart on a provider’s profile to save them here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  );
                }

                return FutureBuilder<
                    List<({ProviderModel provider, String profileImageUrl})>>(
                  future: _resolveFavoritesOrdered(docs),
                  builder: (context, resolved) {
                    if (resolved.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (resolved.hasError) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Could not load provider details.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      );
                    }

                    final rows = resolved.data ?? [];
                    if (rows.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Saved favorites could not be loaded. They may have been removed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final p = rows[index].provider;
                        final imageUrl = rows[index].profileImageUrl;
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/service-details',
                            arguments: p,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.navy.withOpacity(0.07),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [AppColors.blue, AppColors.teal],
                                    ),
                                  ),
                                  child: imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            width: 56,
                                            height: 56,
                                            errorBuilder: (_, __, ___) =>
                                                Icon(
                                              _serviceIcon(p.serviceType),
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          _serviceIcon(p.serviceType),
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                      Text(
                                        p.serviceLabel,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.gray,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 14,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            p.rating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.gray,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.attach_money_rounded,
                                            size: 14,
                                            color: AppColors.teal,
                                          ),
                                          Text(
                                            '${p.startingPrice.toStringAsFixed(0)} EGP',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.gray,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.gray,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
