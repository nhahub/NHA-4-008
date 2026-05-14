import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/request_model.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';
import '../../theme/app_colors.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});
  @override State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {

  final Map<String, String> _clientFullNamesByUserId = {};
  final Map<String, String> _clientPhonesByUserId = {};
  final Map<String, String> _clientImagesByUserId = {};
  final Set<String> _clientDisplayFetchInFlight = {};

  void _prefetchClientDisplayFields(Iterable<RequestModel> requests) {
    if (!mounted) return;
    for (final r in requests) {
      final id = r.userId.trim();
      if (id.isEmpty) continue;
      if (_clientFullNamesByUserId.containsKey(id) && _clientPhonesByUserId.containsKey(id) && _clientImagesByUserId.containsKey(id)) {
        continue;
      }
      if (_clientDisplayFetchInFlight.contains(id)) continue;
      _clientDisplayFetchInFlight.add(id);
      AuthService.fetchClientDisplayFields(id).then((fields) {
        if (!mounted) return;
        setState(() {
          _clientDisplayFetchInFlight.remove(id);
          _clientFullNamesByUserId[id] =
              (fields.fullName != null && fields.fullName!.isNotEmpty)
                  ? fields.fullName!
                  : 'Customer';
          _clientPhonesByUserId[id] =
              (fields.phone != null && fields.phone!.isNotEmpty) ? fields.phone! : '';
          _clientImagesByUserId[id] = 
              (fields.profileImageUrl != null && fields.profileImageUrl!.isNotEmpty) ? fields.profileImageUrl! : '';
        });
      }).catchError((_) {
        if (!mounted) return;
        setState(() {
          _clientDisplayFetchInFlight.remove(id);
          _clientFullNamesByUserId[id] = 'Customer';
          _clientPhonesByUserId[id] = '';
          _clientImagesByUserId[id] = '';
        });
      });
    }
  }

  String _customerDisplayName(String userId) {
    final id = userId.trim();
    if (id.isEmpty) return 'Customer';
    return _clientFullNamesByUserId[id] ?? 'Customer';
  }

  /// `null` while loading or if the client has no phone on file.
  String? _customerPhoneLine(String userId) {
    final id = userId.trim();
    if (id.isEmpty) return null;
    if (!_clientPhonesByUserId.containsKey(id)) return null;
    final p = _clientPhonesByUserId[id]!;
    return p.isEmpty ? null : p;
  }

  String? _customerProfileImage(String userId) {
    final id = userId.trim();
    if (id.isEmpty) return null;
    if (!_clientImagesByUserId.containsKey(id)) return null;
    final img = _clientImagesByUserId[id]!;
    return img.isEmpty ? null : img;
  }
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(alignment: Alignment.centerLeft,
                child: Text(
                    'Incoming Requests',
                    style: TextStyle(
                  fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        fontFamily: 'Cairo')
                )
              ),
            ),
            _buildRequestsList(state),
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
            Text(
                state.loggedInFullName.isNotEmpty
                    ? state.loggedInFullName
                    : 'Provider',
                style: const TextStyle(
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
          onTap: () => context.read<AppState>().toggleProviderAvailability(),
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

  Widget _buildRequestsList(AppState state) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 80),
        child: Text(
          'Sign in to see incoming requests.',
          style: TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      child: StreamBuilder<List<RequestModel>>(
        stream: RequestService.watchRequestsForProvider(uid),
        builder: (context, snap) {
          if (snap.hasError) {
            return Text(
              'Could not load requests.',
              style: TextStyle(fontSize: 13, color: AppColors.red.withOpacity(0.9), fontFamily: 'Cairo'),
            );
          }
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final incoming = (snap.data ?? const <RequestModel>[])
              .where((r) => r.status == RequestStatus.waiting)
              .toList();
          if (incoming.isEmpty) {
            return const Text(
              'No incoming requests yet.',
              style: TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo'),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _prefetchClientDisplayFields(incoming);
          });
          return Column(
            children: [
              for (var i = 0; i < incoming.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _requestCard(
                  context: context,
                  state: state,
                  request: incoming[i],
                  customerName: _customerDisplayName(incoming[i].userId),
                  customerPhone: _customerPhoneLine(incoming[i].userId),
                  customerImage: _customerProfileImage(incoming[i].userId),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  IconData _serviceIcon(String serviceType) {
    switch (serviceType) {
      case 'electrician':
        return Icons.electrical_services_outlined;
      case 'plumber':
        return Icons.plumbing_outlined;
      case 'delivery':
        return Icons.local_shipping_outlined;
      default:
        return Icons.handyman_outlined;
    }
  }

  String _formatScheduledAt(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    final dateStr = loc.formatFullDate(dt);
    final timeStr = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return '$dateStr · $timeStr';
  }

  Widget _requestCard({
    required BuildContext context,
    required AppState state,
    required RequestModel request,
    required String customerName,
    String? customerPhone,
    String? customerImage,
  }) {
    final timeAgo = _formatTimeAgo(request.createdAt);
    final address = request.location?.trim().isNotEmpty == true ? request.location!.trim() : '—';
    final price = request.startingPrice > 0 ? request.startingPrice.toStringAsFixed(0) : '—';
    final icon = _serviceIcon(state.serviceType);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.gray.withOpacity(0.1),
                backgroundImage: customerImage != null ? NetworkImage(customerImage) : null,
                child: customerImage == null
                    ? const Icon(Icons.person, color: AppColors.gray, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  timeAgo.isEmpty ? ' ' : timeAgo,
                  style: const TextStyle(fontSize: 11, color: AppColors.gray, fontFamily: 'Cairo'),
                ),
                if (customerPhone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: AppColors.teal),
                      const SizedBox(width: 4),
                      Text(
                        customerPhone,
                        style: const TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                ],
              ]),
            ],
          ),
          Text('$price EGP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.teal, fontFamily: 'Cairo')),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.teal.withOpacity(0.08)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 13, color: AppColors.teal),
            const SizedBox(width: 5),
            Text(request.label, style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ]),
        ),
        const SizedBox(height: 8),
        Text(request.description, style: const TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo', height: 1.6)),
        const SizedBox(height: 8),
        if (request.scheduledAt != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.teal),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _formatScheduledAt(context, request.scheduledAt!),
                  style: const TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(children: [
          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.teal),
          const SizedBox(width: 4),
          Text(address, style: const TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Cairo')),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: () {
              RequestService.updateRequestStatus(request.requestId, RequestStatus.accepted);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical: 11)),
            child: const Text('✓ Accept', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Cairo')),
          )),
          const SizedBox(width: 10),
          Expanded(flex: 0, child: SizedBox(width: 100, child: OutlinedButton(
            onPressed: () {
              RequestService.updateRequestStatus(request.requestId, RequestStatus.declined);
            },
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
