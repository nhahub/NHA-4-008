import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/provider_model.dart';
import '../../widgets/common_widgets.dart';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});
  @override State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  String _selectedCategory = 'All';
  List<ProviderModel> get _filtered {
    if (_selectedCategory == 'All') return sampleProviders;
    return sampleProviders.where((p) => p.serviceLabel == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(children: [
        // ── Header ──
        _buildHeader(),
        // ── Search bar overlapping header ──
        Transform.translate(
          offset: const Offset(0, -24),
          child: _buildSearchBar(),
        ),
        
        // ── Scrollable content ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionLabel('What do you need?'),
              _buildCategories(),
              const SizedBox(height: 8),
              SectionLabel(_selectedCategory == 'All'
                ? 'Nearby Providers'
                : '$_selectedCategory Providers'),
              _buildProvidersList(),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(24, 52, 24, 60),
    decoration: const BoxDecoration(color: AppColors.navy),
    child: Stack(children: [
      Positioned(top: -40, right: -40, child: Container(width: 180, height: 180,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.teal.withOpacity(0.12)))),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Good morning 👋', style: TextStyle(fontSize: 13, color: AppColors.white.withOpacity(0.7), fontFamily: 'Cairo')),
          const Text('Ahmed Mohamed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.white, fontFamily: 'Cairo')),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.teal.withOpacity(0.2)),
            child: const Text('Client Account', style: TextStyle(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ),
        ]),
        GestureDetector(
          onTap: () {},
          child: Container(width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.12)),
            child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22)),
        ),
      ]),
    ]),
  );

  Widget _buildSearchBar() => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8))],
    ),
    child: const Row(children: [
      Icon(
        Icons.search_rounded,
         color: AppColors.gray,
          size: 20,
          ),
      SizedBox(width: 10),
      Expanded(
        child: TextField(
        style: TextStyle(
          fontSize: 14,
           fontFamily: 'Cairo'
           ),
        decoration: InputDecoration(
          hintText: 'What service do you need?',
          hintStyle: TextStyle(
            color: AppColors.gray,
             fontSize: 14,
              fontFamily: 'Cairo'
              ),
          border: InputBorder.none, isDense: true,
        ),
      )),
    ]),
  );

  Widget _buildCategories() {
    final cats = [
      {'label': 'All',        'icon': Icons.apps_rounded,                  'bg': AppColors.teal,  'stroke': AppColors.teal},
      {'label': 'Electrician','icon': Icons.electrical_services_outlined,  'bg': AppColors.teal,  'stroke': AppColors.teal},
      {'label': 'Plumber',    'icon': Icons.plumbing_outlined,             'bg': AppColors.blue,  'stroke': AppColors.blue},
      {'label': 'Delivery',   'icon': Icons.delivery_dining_outlined,      'bg': AppColors.red,   'stroke': AppColors.red},
    ];
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.3,
      children: cats.map((c) {
        final label  = c['label'] as String;
        final icon   = c['icon']  as IconData;
        final color  = c['bg']    as Color;
        final count  = label == 'All' ? sampleProviders.length
                     : sampleProviders.where((p) => p.serviceLabel == label).length;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = label),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
               borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _selectedCategory == label ? AppColors.teal : Colors.transparent, width: 2),
              boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: color.withOpacity(0.1)),
                child: Icon(icon, size: 26, color: color)),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
              Text('$count available', style: const TextStyle(fontSize: 11, color: AppColors.gray, fontFamily: 'Cairo')),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProvidersList() => Column(
    children: _filtered.map((p) => GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/service-details', arguments: p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          // Avatar
          Container(width: 56, height: 56,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [AppColors.blue, AppColors.teal])),
            child: Icon(_serviceIcon(p.serviceType), color: Colors.white, size: 28)),
          const SizedBox(width: 14),
          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
            Text('${p.serviceLabel} • ${p.distanceKm} km away',
              style: const TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Cairo')),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
              const SizedBox(width: 3),
              Text('${p.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B), fontFamily: 'Cairo')),
              const SizedBox(width: 8),
              Text('From ${p.startingPrice.toInt()} EGP',
                style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                  color: p.isAvailable ? AppColors.teal.withOpacity(0.1) : AppColors.red.withOpacity(0.1)),
                child: Text(p.isAvailable ? 'Available' : 'Busy',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: p.isAvailable ? AppColors.teal : AppColors.red, fontFamily: 'Cairo')),
              ),
            ]),
          ])),
        ]),
      ),
    )).toList(),
  );

  IconData _serviceIcon(String type) {
    switch (type) {
      case 'electrician': return Icons.electrical_services_outlined;
      case 'plumber':     return Icons.plumbing_outlined;
      case 'delivery':    return Icons.delivery_dining_outlined;
      default:            return Icons.build_outlined;
    }
  }
}
