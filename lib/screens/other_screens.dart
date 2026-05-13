import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/provider_model.dart';
import '../widgets/common_widgets.dart';


// ═══════════════════════════════════════════════════════
//  PAYMENT
// ═══════════════════════════════════════════════════════
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPayment = 0; // 0=card, 1=digital, 2=cash

  @override
  Widget build(BuildContext context) {
    final provider = ModalRoute.of(context)!.settings.arguments as ProviderModel?
        ?? sampleProviders.first;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        AppHeader(title: 'Payment', subtitle: 'Almost done!',
          onBack: () => Navigator.pop(context)),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _orderSummary(provider),
            const SectionLabel('Payment Method'),
            _payOption(0, Icons.credit_card_outlined, AppColors.teal, 'Credit / Debit Card', 'Visa, Mastercard'),
            _payOption(1, Icons.phone_iphone_rounded, AppColors.black, 'Apple / Google Pay', 'Digital wallet'),
            _payOption(2, Icons.attach_money_rounded, AppColors.green, 'Cash on Delivery', 'Pay when done'),
            if (_selectedPayment == 0) ...[
              const SizedBox(height: 4),
              _cardFields(),
            ],
            const SizedBox(height: 16),
            PrimaryButton(text: 'Pay 188.1 EGP', color: AppColors.teal,
              onTap: () => _showSuccess(context)),
          ]),
        )),
      ]),
    );
  }

  Widget _orderSummary(ProviderModel p) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue])),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ORDER SUMMARY', style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Cairo', letterSpacing: 1)),
      const SizedBox(height: 10),
      _sumRow('${p.name} — ${p.serviceLabel}', ''),
      _sumRow('Service fee', '${p.startingPrice.toInt()} EGP'),
      _sumRow('Platform fee', '15 EGP'),
      _sumRow('Tax (14%)', '23.1 EGP'),
      Container(height: 1, color: Colors.white.withOpacity(0.15), margin: const EdgeInsets.symmetric(vertical: 8)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Total', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
        const Text('188.1 EGP', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
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
          const Text('Your booking is confirmed.\nThe provider will arrive shortly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo', height: 1.7)),
          const SizedBox(height: 24),
          PrimaryButton(text: 'Track Order', onTap: () {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(context, '/tracking', (r) => r.settings.name == '/user_navigation');
          }),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  ORDER TRACKING
// ═══════════════════════════════════════════════════════
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        AppHeader(title: 'Track Order', subtitle: 'Order #YS-2024-0892',
          onBack: () => Navigator.pushNamedAndRemoveUntil(context, '/user_navigation', (_) => false)),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _mapBox(),
            _providerEnRoute(),
            const SectionLabel('Order Status'),
            _timeline(),
            const SizedBox(height: 20),
            PrimaryButton(text: 'Rate After Completion', color: AppColors.teal,
              onTap: () => Navigator.pushNamed(context, '/rating')),
          ]),
        )),
      ]),
    );
  }

  Widget _mapBox() => Container(
    width: double.infinity, height: 185, margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
      color: AppColors.teal.withOpacity(0.08),
      border: Border.all(color: AppColors.teal.withOpacity(0.2))),
    child: Stack(children: [
      // Grid pattern
      CustomPaint(size: const Size(double.infinity, 185), painter: _GridPainter()),
      const Center(child: Icon(Icons.location_on_rounded, size: 40, color: AppColors.teal)),
      Positioned(bottom: 10, left: 10,
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
          child: const Text('📍 Your Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy, fontFamily: 'Cairo')))),
    ]),
  );

  Widget _providerEnRoute() => Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.light),
    child: Row(children: [
      Container(width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(colors: [AppColors.blue, AppColors.teal])),
        child: const Icon(Icons.electrical_services_outlined, color: Colors.white, size: 26)),
      const SizedBox(width: 13),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Mohamed Ali', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
        Text('🚗 Arriving in ~12 minutes', style: TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
      ])),
      Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.teal),
        child: const Icon(Icons.call_rounded, color: Colors.white, size: 18)),
    ]),
  );

  Widget _timeline() => Column(children: [
    _tlStep(true, false, Icons.check_rounded, 'Order Confirmed', '2:30 PM'),
    _tlStep(true, false, Icons.check_rounded, 'Provider Accepted', '2:32 PM'),
    _tlStep(false, true,  Icons.local_shipping_outlined, 'On The Way', 'Now'),
    _tlStep(false, false, Icons.build_outlined, 'Service Completed', 'Est. 3:15 PM'),
  ]);

  Widget _tlStep(bool done, bool active, IconData icon, String label, String time) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 34, height: 34,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: done ? AppColors.teal : active ? AppColors.navy : AppColors.border),
          child: Icon(icon, size: 16, color: done || active ? Colors.white : AppColors.gray)),
        if (label != 'Service Completed')
          Container(width: 2, height: 28, color: done ? AppColors.teal : AppColors.border),
      ]),
      const SizedBox(width: 14),
      Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
          Text(time, style: const TextStyle(fontSize: 11, color: AppColors.gray, fontFamily: 'Cairo')),
        ]),
      ),
    ]);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.teal.withOpacity(0.08)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 28) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += 28) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════
//  RATING
// ═══════════════════════════════════════════════════════
class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});
  @override State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 0;
  int _emoji = 2;
  final List<String> _emojis = ['😞', '😐', '😊', '🤩'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        AppHeader(title: 'Rate Service', subtitle: 'Your feedback matters',
          onBack: () => Navigator.pop(context)),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
          child: Column(children: [
            // Success icon
            Container(width: 84, height: 84,
              decoration: const BoxDecoration(shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppColors.teal, AppColors.blue])),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 44)),
            const SizedBox(height: 18),
            const Text('Service Completed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.black, fontFamily: 'Cairo')),
            const SizedBox(height: 6),
            const Text('Mohamed Ali finished the job.\nPlease rate your experience.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo', height: 1.7)),
            const SizedBox(height: 28),

            // Stars
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
              GestureDetector(
                onTap: () => setState(() => _stars = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    i < _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 44,
                    color: i < _stars ? const Color(0xFFF59E0B) : AppColors.border,
                  ),
                ),
              )
            )),
            const SizedBox(height: 28),

            // Emoji
            const Text('How do you feel?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.black, fontFamily: 'Cairo')),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) =>
              GestureDetector(
                onTap: () => setState(() => _emoji = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _emoji == i ? AppColors.teal : AppColors.border, width: _emoji == i ? 1.5 : 1.5),
                    color: _emoji == i ? AppColors.teal.withOpacity(0.07) : Colors.white,
                  ),
                  child: Text(_emojis[i], style: const TextStyle(fontSize: 20)),
                ),
              )
            )),
            const SizedBox(height: 22),

            // Comment
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1.5)),
              child: const TextField(maxLines: 3,
                style: TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                decoration: InputDecoration(
                  hintText: 'Write your review here...',
                  hintStyle: TextStyle(color: AppColors.gray, fontSize: 13, fontFamily: 'Cairo'),
                  border: InputBorder.none, isDense: true)),
            ),
            const SizedBox(height: 20),

            PrimaryButton(text: 'Submit Review',
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/user_navigation', (_) => false)),
            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/user_navigation', (_) => false),
              child: const Text('Skip for now', style: TextStyle(fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo')),
            ),
          ]),
        )),
      ]),
    );
  }
}
