import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/provider_model.dart';
import '../../models/request_model.dart';
import '../../services/request_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class UserRequestServiceScreen extends StatefulWidget {
  const UserRequestServiceScreen({super.key});
  @override State<UserRequestServiceScreen> createState() => _UserRequestServiceScreenState();
}

class _UserRequestServiceScreenState extends State<UserRequestServiceScreen> {
  bool _scheduleMode = false;
  bool _submitting = false;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _scheduledDateTime;

  ProviderModel _provider(BuildContext context) =>
      ModalRoute.of(context)!.settings.arguments as ProviderModel? ??
      sampleProviders.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = _provider(context);
      if (_labelController.text.isEmpty) {
        _labelController.text = provider.serviceLabel;
      }
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _labelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduledSlot() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime ?? now,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.teal,
            surface: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted || pickedDate == null) return;

    final initialTime = _scheduledDateTime != null
        ? TimeOfDay.fromDateTime(_scheduledDateTime!)
        : TimeOfDay.fromDateTime(now);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.teal,
            surface: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted || pickedTime == null) return;

    setState(() {
      _scheduledDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  String _formattedAppointment(BuildContext context) {
    final dt = _scheduledDateTime;
    if (dt == null) return '';
    final loc = MaterialLocalizations.of(context);
    final dateStr = loc.formatFullDate(dt);
    final timeStr = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return '$dateStr · $timeStr';
  }

  Future<void> _confirmBooking() async {
    if (_submitting) return;

    final provider = _provider(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to request a service.')),
      );
      return;
    }

    final location = _locationController.text.trim();
    final label = _labelController.text.trim();
    final description = _descriptionController.text.trim();

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your exact location (address or directions).')),
      );
      return;
    }
    if (label.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a short label and a full description of the problem.')),
      );
      return;
    }
    if (_scheduleMode && _scheduledDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap the schedule row and choose a date and time.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await RequestService.createRequest(
        userId: user.uid,
        providerId: provider.id,
        startingPrice: provider.startingPrice,
        label: label,
        description: description,
        location: location,
        bookingIsScheduled: _scheduleMode,
        scheduledAt: _scheduleMode ? _scheduledDateTime : null,
        status: RequestStatus.waiting,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/user_navigation',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit request: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        AppHeader(title: 'Book Service', subtitle: provider.serviceLabel,
            onBack: () => Navigator.pop(context)),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionLabel('Your address'),
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: TextField(
                controller: _locationController,
                maxLines: 3,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                decoration: const InputDecoration(
                  hintText: 'Street, building, floor, apartment, landmark…',
                  hintStyle: TextStyle(color: AppColors.gray, fontSize: 13, fontFamily: 'Cairo'),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SectionLabel('When do you need the service?'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _timeBtn(false, Icons.access_time_outlined, 'As soon as possible')),
              const SizedBox(width: 10),
              Expanded(child: _timeBtn(true, Icons.calendar_today_outlined, 'Pick date & time')),
            ]),
            if (_scheduleMode) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickScheduledSlot,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _scheduledDateTime != null ? AppColors.teal : AppColors.border,
                      width: _scheduledDateTime != null ? 2 : 1.5,
                    ),
                    color: AppColors.teal.withValues(alpha: 0.06),
                  ),
                  child: Row(children: [
                    Icon(Icons.event_available_outlined,
                        color: _scheduledDateTime != null ? AppColors.teal : AppColors.gray),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _scheduledDateTime == null
                            ? 'Tap to choose date and time'
                            : _formattedAppointment(context),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                          color: _scheduledDateTime != null ? AppColors.black : AppColors.gray,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.gray.withValues(alpha: 0.7)),
                  ]),
                ),
              ),
            ],
            const SizedBox(height: 18),
            const SectionLabel('Label for the problem'),
            const SizedBox(height: 8),
            AppInput(
              hint: 'e.g. Electrical repair, leaking pipe…',
              icon: Icons.label_outline_rounded,
              controller: _labelController,
            ),
            const SizedBox(height: 8),
            const SectionLabel('Required service description'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.border,
                      width: 1.5)
              ),
              child: TextField(
                  controller: _descriptionController,
                  maxLines: 8,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                  decoration: const InputDecoration(
                      hintText: 'Describe what you need in detail',
                      hintStyle: TextStyle(color: AppColors.gray, fontSize: 13, fontFamily: 'Cairo'),
                      border: InputBorder.none, isDense: true)),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: _submitting ? 'Submitting…' : 'Confirm Booking',
              color: AppColors.teal,
              onTap: _confirmBooking,
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _timeBtn(bool isSchedule, IconData icon, String label) {
    final bool sel = _scheduleMode == isSchedule;
    return GestureDetector(
      onTap: () {
        setState(() {
          _scheduleMode = isSchedule;
          if (!isSchedule) _scheduledDateTime = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? AppColors.teal : AppColors.border, width: sel ? 2.5 : 2),
          color: sel ? AppColors.teal.withValues(alpha: 0.07) : Colors.white,
        ),
        child: Column(children: [
          Icon(icon, size: 20, color: sel ? AppColors.teal : AppColors.gray),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: sel ? AppColors.teal : AppColors.gray,
              fontFamily: 'Cairo',
            ),
          ),
        ]),
      ),
    );
  }
}
