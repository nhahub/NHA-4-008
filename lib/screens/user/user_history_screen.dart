import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/request_model.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';
import '../../theme/app_colors.dart';
import 'user_payment_screen.dart';

class UserHistoryScreen extends StatefulWidget {
  const UserHistoryScreen({super.key});

  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  final Map<String, String> _providerFullNamesById = {};
  final Map<String, String> _providerPhonesById = {};
  final Map<String, String> _providerImagesById = {};
  final Set<String> _providerDisplayFetchInFlight = {};

  void _prefetchProviderDisplayFields(Iterable<RequestModel> requests) {
    if (!mounted) return;
    for (final r in requests) {
      final id = r.providerId.trim();
      if (id.isEmpty) continue;
      if (_providerFullNamesById.containsKey(id) && _providerPhonesById.containsKey(id) && _providerImagesById.containsKey(id)) {
        continue;
      }
      if (_providerDisplayFetchInFlight.contains(id)) continue;
      _providerDisplayFetchInFlight.add(id);
      AuthService.fetchProviderDisplayFields(id).then((fields) {
        if (!mounted) return;
        setState(() {
          _providerDisplayFetchInFlight.remove(id);
          _providerFullNamesById[id] =
              (fields.fullName != null && fields.fullName!.isNotEmpty)
                  ? fields.fullName!
                  : 'Provider';
          _providerPhonesById[id] =
              (fields.phone != null && fields.phone!.isNotEmpty) ? fields.phone! : '';
          _providerImagesById[id] = 
              (fields.profileImageUrl != null && fields.profileImageUrl!.isNotEmpty) ? fields.profileImageUrl! : '';
        });
      }).catchError((_) {
        if (!mounted) return;
        setState(() {
          _providerDisplayFetchInFlight.remove(id);
          _providerFullNamesById[id] = 'Provider';
          _providerPhonesById[id] = '';
          _providerImagesById[id] = '';
        });
      });
    }
  }

  String _providerDisplayName(String providerId) {
    final id = providerId.trim();
    if (id.isEmpty) return 'Provider';
    return _providerFullNamesById[id] ?? 'Provider';
  }

  String? _providerPhoneLine(String providerId) {
    final id = providerId.trim();
    if (id.isEmpty) return null;
    if (!_providerPhonesById.containsKey(id)) return null;
    final p = _providerPhonesById[id]!;
    return p.isEmpty ? null : p;
  }

  String? _providerProfileImage(String providerId) {
    final id = providerId.trim();
    if (id.isEmpty) return null;
    if (!_providerImagesById.containsKey(id)) return null;
    final img = _providerImagesById[id]!;
    return img.isEmpty ? null : img;
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

  IconData _serviceIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('electrician')) return Icons.electrical_services_outlined;
    if (l.contains('plumb')) return Icons.plumbing_outlined;
    if (l.contains('deliver')) return Icons.local_shipping_outlined;
    return Icons.handyman_outlined;
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

  Widget _buildStatusBadge(RequestStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case RequestStatus.waiting:
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange;
        text = 'Waiting';
        break;
      case RequestStatus.accepted:
        bgColor = AppColors.green.withOpacity(0.15);
        textColor = AppColors.green;
        text = 'Accepted';
        break;
      case RequestStatus.declined:
        bgColor = AppColors.red.withOpacity(0.15);
        textColor = AppColors.red;
        text = 'Declined';
        break;
      case RequestStatus.completed:
        bgColor = AppColors.blue.withOpacity(0.15);
        textColor = AppColors.blue;
        text = 'Completed';
        break;
      case RequestStatus.paymentRequired:
        bgColor = Colors.purple.withOpacity(0.15);
        textColor = Colors.purple;
        text = 'Payment Required';
        break;
      default:
        bgColor = AppColors.gray.withOpacity(0.15);
        textColor = AppColors.gray;
        text = status.firestoreValue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _requestCard({
    required BuildContext context,
    required RequestModel request,
    required String providerName,
    String? providerPhone,
    String? providerImage,
  }) {
    final timeAgo = _formatTimeAgo(request.createdAt);
    final address = request.location?.trim().isNotEmpty == true ? request.location!.trim() : '—';
    final displayPrice = request.totalPrice ?? request.startingPrice;
    final price = displayPrice > 0 ? displayPrice.toStringAsFixed(0) : '—';
    final icon = _serviceIcon(request.label);
    
    bool showPayButton = request.status == RequestStatus.paymentRequired;

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
                backgroundImage: providerImage != null ? NetworkImage(providerImage) : null,
                child: providerImage == null
                    ? const Icon(Icons.person, color: AppColors.gray, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  providerName,
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
                if (providerPhone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: AppColors.teal),
                      const SizedBox(width: 4),
                      Text(
                        providerPhone,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.teal.withOpacity(0.08)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 13, color: AppColors.teal),
                const SizedBox(width: 5),
                Text(request.label, style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              ]),
            ),
            _buildStatusBadge(request.status),
          ],
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
        if (showPayButton) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserPaymentScreen(
                    request: request,
                    providerName: providerName,
                  )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'Pay',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.white,
            fontFamily: 'Cairo',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildRequestsList(),
    );
  }

  Widget _buildRequestsList() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(
        child: Text(
          'Sign in to see history.',
          style: TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo'),
        ),
      );
    }

    return StreamBuilder<List<RequestModel>>(
      stream: RequestService.watchRequestsForUser(uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text(
              'Could not load history.',
              style: TextStyle(fontSize: 13, color: AppColors.red.withOpacity(0.9), fontFamily: 'Cairo'),
            ),
          );
        }
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final history = snap.data ?? const <RequestModel>[];
            
        if (history.isEmpty) {
          return const Center(
            child: Text(
              'No history yet.',
              style: TextStyle(fontSize: 14, color: AppColors.gray, fontFamily: 'Cairo'),
            ),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _prefetchProviderDisplayFields(history);
        });
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = history[index];
            return _requestCard(
              context: context,
              request: request,
              providerName: _providerDisplayName(request.providerId),
              providerPhone: _providerPhoneLine(request.providerId),
              providerImage: _providerProfileImage(request.providerId),
            );
          },
        );
      },
    );
  }
}

