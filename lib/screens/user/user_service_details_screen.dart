import 'package:ay_khedma/models/provider_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool? _isFavorite;
  bool _favoriteActionBusy = false;

  ProviderModel _provider(BuildContext context) =>
      ModalRoute.of(context)!.settings.arguments as ProviderModel? ??
      sampleProviders.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteStatus();
    });
  }

  Future<void> _loadFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isFavorite = false);
      return;
    }

    final provider = _provider(context);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(provider.id)
          .get();
      if (!mounted) return;
      setState(() => _isFavorite = doc.exists);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load favorites. Please try again.')),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite == null || _favoriteActionBusy) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to use favorites.')),
      );
      return;
    }

    final provider = _provider(context);
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(provider.id);

    setState(() => _favoriteActionBusy = true);

    try {
      if (_isFavorite == true) {
        await ref.delete();
        if (!mounted) return;
        setState(() {
          _isFavorite = false;
          _favoriteActionBusy = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      } else {
        await ref.set({
          'providerId': provider.id,
          'addedAt': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        setState(() {
          _isFavorite = true;
          _favoriteActionBusy = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _favoriteActionBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update favorites. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        // Hero header
        _buildHero(context, provider),
        // Scrollable body
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionLabel('About'),
            Text(provider.bio, style: const TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo', height: 1.8)),
            const SizedBox(height: 20),
            const SectionLabel('Service Info'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _infoPill(Icons.access_time_outlined, '30–60 min'),
              _infoPill(Icons.attach_money_rounded, '${provider.startingPrice.toInt()}+ EGP'),
              _infoPill(Icons.location_on_outlined, '${provider.distanceKm} km away'),
            ]),
            const SizedBox(height: 20),
            const SectionLabel('Reviews'),
            _reviewCard('Sara Ahmed', 5, '2 days ago', 'Excellent work! Fixed all issues quickly and professionally.'),
            _reviewCard('Omar Khalil', 4, '1 week ago', 'Good service, on time and reasonable price. Will use again.'),
          ]),
        )),
        // Footer
        _buildFooter(context, provider),
      ]),
    );
  }

  Widget _buildHero(BuildContext context, ProviderModel p) => Container(
    padding: const EdgeInsets.fromLTRB(24, 52, 24, 28),
    decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.navy, AppColors.blue])),
    child: Stack(children: [
      Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(onTap: () => Navigator.pop(context),
              child: Container(width: 40, height: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
                  child: const Icon(Icons.chevron_left, color: Colors.white, size: 22))),
          GestureDetector(
            onTap: _toggleFavorite,
            child: Container(width: 40, height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
                child: Icon(
                  _isFavorite == true
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  color: Colors.white,
                  size: 20,
                )),
          ),
        ]),
        const SizedBox(height: 14),
        Container(width: 76, height: 76,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22),
                color: Colors.white.withOpacity(0.15), border: Border.all(color: Colors.white.withOpacity(0.2), width: 2)),
            child: Icon(_icon(p.serviceType), size: 40, color: Colors.white)),
        const SizedBox(height: 12),
        Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Cairo')),
        Text('${p.serviceLabel} • Cairo, Egypt',
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.65), fontFamily: 'Cairo')),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _stat('${p.rating}', 'Rating'), _statDiv(),
          _stat('${p.jobsDone}+', 'Jobs'),  _statDiv(),
          // _stat('98%', 'Success'),          _statDiv(),
          _stat('${p.experience} yr', 'Exp.'),
        ]),
      ]),
    ]),
  );

  Widget _stat(String v, String l) => Column(children: [
    Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Cairo')),
    Text(l, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo')),
  ]);
  Widget _statDiv() => Container(height: 28, width: 1, margin: const EdgeInsets.symmetric(horizontal: 14), color: Colors.white.withOpacity(0.2));

  Widget _infoPill(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.light),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.teal),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.black, fontFamily: 'Cairo')),
    ]),
  );

  Widget _reviewCard(String name, int stars, String date, String text) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.light),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(radius: 18, backgroundColor: AppColors.teal, child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Cairo'))),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
          RatingStars(rating: stars.toDouble(), size: 11),
        ]),
        const Spacer(),
        Text(date, style: const TextStyle(fontSize: 11, color: AppColors.gray, fontFamily: 'Cairo')),
      ]),
      const SizedBox(height: 8),
      Text(text, style: const TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Cairo', height: 1.7)),
    ]),
  );

  Widget _buildFooter(BuildContext context, ProviderModel p) => Container(
    padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
    decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Starting from', style: TextStyle(fontSize: 11, color: AppColors.gray, fontFamily: 'Cairo')),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text('${p.startingPrice.toInt()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.navy, fontFamily: 'Cairo')),
          const Text(' EGP', style: TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Cairo')),
        ]),
      ]),
      const SizedBox(width: 16),
      Expanded(child: SizedBox(height: 50, child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/request', arguments: p),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), elevation: 4,
            shadowColor: AppColors.teal.withOpacity(0.4)),
        child: const Text('Book Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Cairo')),
      ))),
    ]),
  );

  IconData _icon(String type) {
    switch (type) {
      case 'electrician': return Icons.electrical_services_outlined;
      case 'plumber':     return Icons.plumbing_outlined;
      case 'delivery':    return Icons.delivery_dining_outlined;
      default:            return Icons.build_outlined;
    }
  }
}
