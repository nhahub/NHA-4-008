import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/app_state.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});
  @override State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(children: [
        _buildHeader(state),
        Expanded(child: SingleChildScrollView(
          child: Column(children: [
            _buildEarningsCard(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(alignment: Alignment.centerLeft,
                child: Text(
                    'Incoming Requests',
                    style: const TextStyle(
                  fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        fontFamily: 'Cairo')
                )
              ),
            ),
            _buildRequestsList(),
          ]),
        )),
      ]),
    );
  }

  Widget _buildHeader(AppState state) => Container(
    padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        colors: [AppColors.black, AppColors.navy]
      )
    ),
    child: Stack(
        children: [
      Positioned(top: -40,
          right: -40,
          child: Container(
              width: 160,
              height: 160,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.teal.withOpacity(0.1))
          )
      ),
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

            Text(
                'Welcome back 👷',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.white.withOpacity(0.65),
                    fontFamily: 'Cairo')
            ),
            const Text(
                'Mohamed Ali',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                    fontFamily: 'Cairo')
            ),
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.blue.withOpacity(0.3)
              ),
              child: Text(
                  _serviceLabel(state.serviceType),
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFADD8F0),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo')
              ),
            ),
          ]),
          Container(
              width: 40,
              height: 40,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12)
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: Colors.white,
                size: 22
              ),
            ),
          ]
        ),
        const SizedBox(height: 16),
        // Online toggle
        GestureDetector(
          onTap: () => context.read<AppState>().toggleOnline(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withOpacity(0.1),
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
              // Toggle switch
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: state.isOnline ? AppColors.green : const Color(0xFF555555),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  alignment: state.isOnline ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(width: 18, height: 18,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white)
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                state.isOnline ? 'Online — Ready to accept' : 'Offline — Not receiving',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white.withOpacity(0.85),
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ),
      ]),
    ]),
  );

  Widget _buildEarningsCard() => Container(
    margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue]),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("TODAY'S EARNINGS", style: TextStyle(color: AppColors.white.withOpacity(0.65), fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Cairo', letterSpacing: 1)),
      const SizedBox(height: 4),
      const Text('350 EGP', style: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _earnStat('3', 'Jobs Done'),
        _earnStat('4.9', 'Rating'),
        _earnStat('98%', 'Accept Rate'),
      ]),
    ]),
  );

  Widget _earnStat(String val, String lbl) => Column(children: [
    Text(val, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
    Text(lbl, style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 11, fontFamily: 'Cairo')),
  ]);

  Widget _buildRequestsList() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
    child: Column(children: [
      _requestCard(
        userName: 'Sara Ahmed',
        timeAgo: '2 min ago • 1.2 km',
        service: 'Electrical Repair',
        desc: 'Electricity went out in the living room. Tripped breaker won\'t reset.',
        address: '12 El Nasr St, Nasr City',
        price: '150',
      ),
      const SizedBox(height: 12),
      _requestCard(
        userName: 'Omar Khalil',
        timeAgo: '8 min ago • 2.5 km',
        service: 'New Installation',
        desc: 'Need to install 3 ceiling fans and replace old light fixtures.',
        address: '7 Abbas El Akkad, Nasr City',
        price: '200',
      ),
    ]),
  );

  Widget _requestCard({required String userName, required String timeAgo,
    required String service, required String desc, required String address, required String price}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(userName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
            Text(timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.gray, fontFamily: 'Cairo')),
          ]),
          Text('$price EGP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.teal, fontFamily: 'Cairo')),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.teal.withOpacity(0.08)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.electrical_services_outlined, size: 13, color: AppColors.teal),
            const SizedBox(width: 5),
            Text(service, style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ]),
        ),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo', height: 1.6)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.teal),
          const SizedBox(width: 4),
          Text(address, style: const TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Cairo')),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical: 11)),
            child: const Text('✓ Accept', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Cairo')),
          )),
          const SizedBox(width: 10),
          Expanded(flex: 0, child: SizedBox(width: 100, child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.red,
              side: BorderSide(color: AppColors.red.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical: 11)),
            child: const Text('✗ Decline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ))),
        ]),
      ]),
    );
  }

  String _serviceLabel(String type) {
    switch (type) {
      case 'electrician': return 'Electrician';
      case 'plumber':     return 'Plumber';
      case 'delivery':    return 'Delivery Driver';
      default:            return 'Service Provider';
    }
  }
}
