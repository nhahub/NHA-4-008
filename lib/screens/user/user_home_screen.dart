import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../models/provider_model.dart';
import '../../widgets/common_widgets.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _selectedCategory = 'All';
  String _userFullName = 'User';
  String _userAddress = '';
  bool _filterSameAddressOnly = false;
  bool _isLoadingProviders = true;
  List<ProviderModel> _providers = [];
  final Map<String, String> _providerAddressById = {};
  final Map<String, String> _providerImageUrlById = {};

  String _normalizedAddress(String address) =>
      address.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  static String? _addressStringFromValue(dynamic value) {
    if (value == null) return null;
    if (value is GeoPoint) return null;
    if (value is String) {
      final t = value.trim();
      return t.isEmpty ? null : t;
    }
    if (value is Map) {
      final m = Map<String, dynamic>.from(value);
      const nestedKeys = [
        'label', 'name', 'street', 'formatted', 'address', 'formattedAddress'
      ];
      for (final k in nestedKeys) {
        final s = _addressStringFromValue(m[k]);
        if (s != null) return s;
      }
      return null;
    }
    final s = value.toString().trim();
    if (s.isEmpty || s == 'Instance of \'GeoPoint\'') return null;
    return s;
  }

  static String? _readUserAddressFromDoc(Map<String, dynamic>? data) {
    if (data == null) return null;
    const keys = [
      'address',
      'homeAddress',
      'userAddress',
      'locationLabel',
      'area',
    ];
    for (final k in keys) {
      final v = _addressStringFromValue(data[k]);
      if (v != null) return v;
    }
    return null;
  }

  List<ProviderModel> get _filteredByCategory {
    if (_selectedCategory == 'All') return List<ProviderModel>.from(_providers);
    return _providers
        .where((p) => p.serviceLabel == _selectedCategory)
        .toList();
  }

  List<ProviderModel> get _filtered {
    var list = _filteredByCategory;
    if (!_filterSameAddressOnly) return list;

    final userNorm = _normalizedAddress(_userAddress);
    if (userNorm.isEmpty) return [];

    return list.where((p) {
      final providerAddr = _providerAddressById[p.id] ?? '';
      final pNorm = _normalizedAddress(providerAddr);
      return pNorm.isNotEmpty && pNorm == userNorm;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadScreenData();
  }

  Future<void> _loadScreenData() async {
    await Future.wait([
      _loadCurrentUserName(),
      _loadProvidersFromFirestore(),
    ]);
  }

  Future<void> _loadCurrentUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = userDoc.data();
      final fullName = (data?['fullName'] as String?)?.trim();
      final address = _readUserAddressFromDoc(data);
      if (!mounted) return;
      setState(() {
        if (fullName != null && fullName.isNotEmpty) {
          _userFullName = fullName;
        }
        if (address != null && address.isNotEmpty) {
          _userAddress = address;
        }
      });
    } catch (_) {

    }
  }

  Future<void> _loadProvidersFromFirestore() async {
    const collections = <String, String>{
      'electricians': 'electrician',
      'plumbers': 'plumber',
      'delivery': 'delivery',
    };

    try {
      final db = FirebaseFirestore.instance;
      final futures = collections.entries
          .map((entry) => db.collection(entry.key).get())
          .toList();
      final snapshots = await Future.wait(futures);

      final loadedProviders = <ProviderModel>[];
      final loadedAddresses = <String, String>{};
      final loadedImageUrls = <String, String>{};
      for (var i = 0; i < snapshots.length; i++) {
        final serviceType = collections.values.elementAt(i);
        for (final doc in snapshots[i].docs) {
          final data = doc.data();
          final imageUrl = (data['profileImageUrl'] as String?)?.trim() ?? '';
          final address = (data['address'] as String?)?.trim() ?? '';
          loadedAddresses[doc.id] = address;
          loadedImageUrls[doc.id] = imageUrl;
          loadedProviders.add(
            ProviderModel(
              id: doc.id,
              name: (data['fullName'] as String?)?.trim().isNotEmpty == true
                  ? (data['fullName'] as String)
                  : 'Provider',
              serviceType: (data['serviceType'] as String?)?.trim().isNotEmpty ==
                      true
                  ? (data['serviceType'] as String)
                  : serviceType,
              rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
              jobsDone: (data['totalReviews'] as num?)?.toInt() ?? 0,
              experience: (data['yearsOfExperience'] as num?)?.toInt() ?? 0,
              startingPrice: (data['startingPrice'] as num?)?.toDouble() ?? 0.0,
              bio: (data['bio'] as String?) ?? '',
              distanceKm: 0.0,
              isAvailable: true,
            ),
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _providers = loadedProviders;
        _providerAddressById
          ..clear()
          ..addAll(loadedAddresses);
        _providerImageUrlById
          ..clear()
          ..addAll(loadedImageUrls);
        _isLoadingProviders = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _providers = [];
        _providerAddressById.clear();
        _providerImageUrlById.clear();
        _isLoadingProviders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          _buildHeader(context),

          Transform.translate(
            offset: const Offset(0, -24),
            child: _buildSearchBar(),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('What do you need?'),
                  _buildCategories(width),
                  const SizedBox(height: 25),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SectionLabel(
                          _selectedCategory == 'All'
                              ? 'Nearby Providers'
                              : '$_selectedCategory Providers',
                        ),
                      ),
                      _sameAddressFilterButton(),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildProvidersList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── HEADER ─────────────────
  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 60),
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Stack(
        children: [
          // ───── CONTENT ─────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome 👋',
                    style: TextStyle(
                      fontSize: width < 360 ? 12 : 13,
                      color: AppColors.white.withOpacity(0.7),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    _userFullName,
                    style: TextStyle(
                      fontSize: width < 360 ? 18 : 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.teal.withOpacity(0.2),
                    ),
                    child: const Text(
                      'Client Account',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),

              Container(
                width: width < 360 ? 36 : 40,
                height: width < 360 ? 36 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── SEARCH ─────────────────
  Widget _buildSearchBar() => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.navy.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        )
      ],
    ),
    child: const Row(
      children: [
        Icon(Icons.search_rounded, color: AppColors.gray, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            style: TextStyle(fontSize: 14, fontFamily: 'Cairo'),
            decoration: InputDecoration(
              hintText: 'What service do you need?',
              hintStyle: TextStyle(
                color: AppColors.gray,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    ),
  );

  // ───────────────── CATEGORIES ─────────────────
  Widget _buildCategories(double width) {
    final cats = [
      {'label': 'All', 'icon': Icons.apps_rounded, 'bg': AppColors.teal},
      {'label': 'Electrician', 'icon': Icons.electrical_services_outlined, 'bg': AppColors.teal},
      {'label': 'Plumber', 'icon': Icons.plumbing_outlined, 'bg': AppColors.blue},
      {'label': 'Delivery', 'icon': Icons.delivery_dining_outlined, 'bg': AppColors.red},
    ];

    final isSmall = width < 360;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: isSmall ? 110 : 125,
      ),
      itemBuilder: (context, index) {
        final c = cats[index];

        final label = c['label'] as String;
        final icon = c['icon'] as IconData;
        final color = c['bg'] as Color;

        final base = _filterSameAddressOnly
            ? (_normalizedAddress(_userAddress).isEmpty
                ? <ProviderModel>[]
                : _providers.where((p) {
                    final pa = _normalizedAddress(
                        _providerAddressById[p.id] ?? '');
                    final u = _normalizedAddress(_userAddress);
                    return pa.isNotEmpty && pa == u;
                  }).toList())
            : _providers;

        final count = label == 'All'
            ? base.length
            : base.where((p) => p.serviceLabel == label).length;

        final isSelected = _selectedCategory == label;

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = label),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? AppColors.teal : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isSmall ? 40 : 48,
                  height: isSmall ? 40 : 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: color.withOpacity(0.1),
                  ),
                  child: Icon(
                    icon,
                    size: isSmall ? 20 : 26,
                    color: color,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '$count available',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sameAddressFilterButton() {
    final hasUserAddress = _normalizedAddress(_userAddress).isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          var addr = _normalizedAddress(_userAddress);
          if (addr.isEmpty) {
            await _loadCurrentUserName();
            if (!mounted) return;
            addr = _normalizedAddress(_userAddress);
          }
          if (addr.isEmpty) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Set your address in your profile first to filter by location.',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            );
            return;
          }
          setState(() =>
              _filterSameAddressOnly = !_filterSameAddressOnly);
        },
        borderRadius: BorderRadius.circular(20),
        child: Tooltip(
          message: hasUserAddress
              ? 'Show only providers with the same address as you'
              : 'Add your address to use this filter',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _filterSameAddressOnly
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                  size: 20,
                  color: !hasUserAddress
                      ? AppColors.gray.withOpacity(0.5)
                      : (_filterSameAddressOnly
                          ? AppColors.teal
                          : AppColors.gray),
                ),
                const SizedBox(width: 6),
                Text(
                  'My address',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: !hasUserAddress
                        ? AppColors.gray.withOpacity(0.5)
                        : (_filterSameAddressOnly
                            ? AppColors.teal
                            : AppColors.gray),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── PROVIDERS ─────────────────
  Widget _buildProvidersList() {
    if (_isLoadingProviders) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_filterSameAddressOnly &&
        _normalizedAddress(_userAddress).isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Add your address in your profile to see providers in your area.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.gray,
            fontFamily: 'Cairo',
          ),
        ),
      );
    }

    if (_filtered.isEmpty) {
      final message = _filterSameAddressOnly
          ? 'No providers found with the same address as you for this category.'
          : 'No providers found.';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.gray,
            fontFamily: 'Cairo',
          ),
        ),
      );
    }

    return Column(
      children: _filtered
          .map(
            (p) => GestureDetector(
          onTap: () => Navigator.pushNamed(
              context, '/service-details',
              arguments: p),
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
                )
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
                  child: _providerImageUrlById[p.id] != null &&
                          _providerImageUrlById[p.id]!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _providerImageUrlById[p.id]!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.teal,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _providerAddressById[p.id]?.isNotEmpty == true
                                  ? _providerAddressById[p.id]!
                                  : 'Address not provided',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.gray,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .toList(),
    );
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
}