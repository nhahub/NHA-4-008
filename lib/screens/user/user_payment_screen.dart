import 'package:flutter/material.dart';
import '../../models/provider_model.dart';
import '../../models/request_model.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class UserPaymentScreen extends StatefulWidget {
  final RequestModel? request;
  final String? providerName;

  const UserPaymentScreen({super.key, this.request, this.providerName});
  @override State<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends State<UserPaymentScreen> {
  int _selectedPayment = 0; // 0=card, 1=digital, 2=cash
  String? _fetchedFullName;
  String? _fetchedServiceType;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetchProviderInfo();
  }

  Future<void> _fetchProviderInfo() async {
    if (widget.request?.providerId != null) {
      final profile = await AuthService.fetchProfile(widget.request!.providerId);
      if (mounted) {
        setState(() {
          _fetchedFullName = profile.fullName;
          _fetchedServiceType = profile.serviceType;
          _isFetching = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ModalRoute.of(context)?.settings.arguments as ProviderModel?
        ?? sampleProviders.first;

    final request = widget.request;
    final providerName = _fetchedFullName ?? widget.providerName ?? provider.name;
    final serviceLabel = _fetchedServiceType ?? (request != null ? request.label : provider.serviceLabel);
    
    // Calculations
    final startingPrice = request?.startingPrice ?? provider.startingPrice;
    final additional = request?.additionalExpense ?? 0;
    final platformFee = 15.0;
    final subtotal = startingPrice + additional + platformFee;
    final tax = subtotal * 0.14;
    final total = request?.totalPrice != null 
        ? (request!.totalPrice! + platformFee + ((request!.totalPrice! + platformFee) * 0.14))
        : (subtotal + tax);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        AppHeader(title: 'Payment', subtitle: 'Almost done!',
            onBack: () => Navigator.pop(context)),
        if (_isFetching)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _orderSummary(providerName, serviceLabel, startingPrice, additional, platformFee, tax, total),
            const SectionLabel('Payment Method'),
            _payOption(0, Icons.credit_card_outlined, AppColors.teal, 'Credit / Debit Card', 'Visa, Mastercard'),
            _payOption(1, Icons.phone_iphone_rounded, AppColors.black, 'Apple / Google Pay', 'Digital wallet'),
            _payOption(2, Icons.attach_money_rounded, AppColors.green, 'Cash on Delivery', 'Pay when done'),
            if (_selectedPayment == 0) ...[
              const SizedBox(height: 4),
              _cardFields(),
            ],
            const SizedBox(height: 16),
            PrimaryButton(text: 'Pay ${total.toStringAsFixed(1)} EGP', color: AppColors.teal,
                onTap: () => _handlePayment(context)),
          ]),
        )),
      ]),
    );
  }

  Widget _orderSummary(String providerName, String serviceLabel, double startingPrice, double additional, double platformFee, double tax, double total) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue])),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ORDER SUMMARY', style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Cairo', letterSpacing: 1)),
      const SizedBox(height: 10),
      _sumRow('$providerName — $serviceLabel', ''),
      _sumRow('Starting fee', '${startingPrice.toStringAsFixed(1)} EGP'),
      if (additional > 0)
        _sumRow('Additional expense', '${additional.toStringAsFixed(1)} EGP'),
      _sumRow('Platform fee', '${platformFee.toStringAsFixed(1)} EGP'),
      _sumRow('Tax (14%)', '${tax.toStringAsFixed(1)} EGP'),
      Container(height: 1, color: Colors.white.withOpacity(0.15), margin: const EdgeInsets.symmetric(vertical: 8)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Total', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
        Text('${total.toStringAsFixed(1)} EGP', style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
      ]),
    ]),
  );

  Widget _sumRow(String l, String r) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.75), fontFamily: 'Cairo')),
      Text(r, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
    ]),
  );

  Widget _payOption(int idx, IconData icon, Color color, String label, String sub) {
    final sel = _selectedPayment == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? AppColors.teal : AppColors.border, width: sel ? 2.5 : 2),
          color: sel ? AppColors.teal.withOpacity(0.05) : Colors.white,
        ),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withOpacity(0.1)),
              child: Icon(icon, size: 22, color: color)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
            Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Cairo')),
          ])),
          Container(width: 20, height: 20,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  border: Border.all(color: sel ? AppColors.teal : AppColors.border, width: 2),
                  color: sel ? AppColors.teal : Colors.white),
              child: sel ? const Icon(Icons.circle, size: 10, color: Colors.white) : null),
        ]),
      ),
    );
  }

  Widget _cardFields() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.light),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Card Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
      const SizedBox(height: 12),
      _cardInput('Card Number', TextInputType.number),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _cardInput('MM/YY', TextInputType.datetime)),
        const SizedBox(width: 10),
        Expanded(child: _cardInput('CVV', TextInputType.number)),
      ]),
    ]),
  );

  Widget _cardInput(String hint, TextInputType type) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border), color: Colors.white),
    child: TextField(keyboardType: type,
        style: const TextStyle(fontSize: 14, fontFamily: 'Cairo'),
        decoration: InputDecoration(hintText: hint,
            hintStyle: const TextStyle(color: AppColors.gray, fontSize: 13, fontFamily: 'Cairo'),
            border: InputBorder.none, isDense: true)),
  );

  Future<void> _handlePayment(BuildContext context) async {
    if (widget.request != null) {
      String paymentMethod = 'Card';
      if (_selectedPayment == 1) paymentMethod = 'Digital Wallet';
      else if (_selectedPayment == 2) paymentMethod = 'Cash';

      await RequestService.payRequest(widget.request!.requestId, paymentMethod);
    }
    if (context.mounted) _showSuccess(context);
  }

  void _showSuccess(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 68, height: 68, decoration: const BoxDecoration(shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF22C55E), AppColors.green])),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 34)),
          const SizedBox(height: 14),
          const Text('Payment Successful!', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.black, fontFamily: 'Cairo')),
          const SizedBox(height: 7),
          const Text('Your paying is confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo', height: 1.7)),
          const SizedBox(height: 24),
          PrimaryButton(text: 'Confirm', onTap: () {
            Navigator.pushNamedAndRemoveUntil(context, '/user_navigation', (route) => false);
          }),
        ]),
      ),
    );
  }
}