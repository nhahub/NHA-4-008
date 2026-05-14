import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/request_model.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';
import '../../theme/app_colors.dart';

class ProviderHistoryScreen extends StatefulWidget {
  const ProviderHistoryScreen({super.key});

  @override
  State<ProviderHistoryScreen> createState() => _ProviderHistoryScreenState();
}

class _ProviderHistoryScreenState extends State<ProviderHistoryScreen> {
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

  Widget _buildStatusBadge(RequestStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
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
      case RequestStatus.pending:
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange;
        text = 'Pending';
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

  Future<void> _showModifyOfferDialog(BuildContext context, RequestModel request) async {
    final expenseCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Modify Offer', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: expenseCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Additional Expense (EGP)',
                  labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.gray, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () async {
                final expense = double.tryParse(expenseCtrl.text) ?? 0;
                final reason = reasonCtrl.text.trim();
                if (expense > 0 && reason.isNotEmpty) {
                  await RequestService.modifyOffer(
                    requestId: request.requestId,
                    additionalExpense: expense,
                    reason: reason,
                    currentPrice: request.startingPrice,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Confirm', style: TextStyle(color: AppColors.white, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
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
    final displayPrice = request.totalPrice ?? request.startingPrice;
    final price = displayPrice > 0 ? displayPrice.toStringAsFixed(0) : '—';
    final icon = _serviceIcon(state.serviceType);

    bool showStartService = false;
    if (request.status == RequestStatus.accepted) {
      if (request.scheduledAt == null) {
        showStartService = true;
      } else if (DateTime.now().isAfter(request.scheduledAt!) || DateTime.now().isAtSameMomentAs(request.scheduledAt!)) {
        showStartService = true;
      }
    }

    bool showServiceDone = request.status == RequestStatus.pending;
    bool showCompletedActions = request.status == RequestStatus.completed;

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
        if (showStartService) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                RequestService.updateRequestStatus(request.requestId, RequestStatus.pending);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'Start Service',
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
        if (showServiceDone) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                RequestService.updateRequestStatus(request.requestId, RequestStatus.completed);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'Service Done',
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
        if (showCompletedActions) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showModifyOfferDialog(context, request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal.withOpacity(0.15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Modify Offer',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    RequestService.updateRequestStatus(request.requestId, RequestStatus.paymentRequired);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Request Payment',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
            "History",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
                fontFamily: 'Cairo'
            )
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildRequestsList(state),
    );
  }

  Widget _buildRequestsList(AppState state) {
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
      stream: RequestService.watchRequestsForProvider(uid),
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
        // Filter out "waiting" requests. Show history (accepted, declined, etc.)
        final history = (snap.data ?? const <RequestModel>[])
            .where((r) => r.status != RequestStatus.waiting)
            .toList();
            
        if (history.isEmpty) {
          return const Center(
            child: Text(
              'No history yet.',
              style: TextStyle(fontSize: 14, color: AppColors.gray, fontFamily: 'Cairo'),
            ),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _prefetchClientDisplayFields(history);
        });
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = history[index];
            return _requestCard(
              context: context,
              state: state,
              request: request,
              customerName: _customerDisplayName(request.userId),
              customerPhone: _customerPhoneLine(request.userId),
              customerImage: _customerProfileImage(request.userId),
            );
          },
        );
      },
    );
  }
}
