import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';

/// A widget that allows users to select a date and time slot for booking an appointment.
/// 
/// It generates available dates (excluding weekends) and time slots, 
/// and checks against already booked appointments for the selected doctor.
class BookingSection extends ConsumerStatefulWidget {
  final String doctorId;
  final Function(DateTime) onDateTimeSelected;
  final VoidCallback onBookPressed;
  final bool isLoading;

  const BookingSection({
    super.key,
    required this.doctorId,
    required this.onDateTimeSelected,
    required this.onBookPressed,
    this.isLoading = false,
  });

  @override
  ConsumerState<BookingSection> createState() => _BookingSectionState();
}

class _BookingSectionState extends ConsumerState<BookingSection> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedTime;

  @override
  void initState() {
    super.initState();
    // If initial date is weekend, move to next available
    while (_isWeekend(_selectedDate)) {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    }
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
  }

  List<DateTime> _generateDates() {
    List<DateTime> dates = [];
    DateTime current = DateTime.now();
    for (int i = 0; i < 30; i++) {
      DateTime date = current.add(Duration(days: i));
      if (!_isWeekend(date)) {
        dates.add(date);
      }
    }
    return dates;
  }

  List<DateTime> _generateTimeSlots(DateTime date) {
    List<DateTime> slots = [];
    DateTime now = DateTime.now();
    for (int hour = 9; hour < 17; hour++) {
      DateTime slot1 = DateTime(date.year, date.month, date.day, hour, 0);
      DateTime slot2 = DateTime(date.year, date.month, date.day, hour, 30);
      
      if (slot1.isAfter(now)) slots.add(slot1);
      if (slot2.isAfter(now)) slots.add(slot2);
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final availabilityAsync = ref.watch(doctorAvailabilityProvider(widget.doctorId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _generateDates().length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = _generateDates()[index];
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              return _DateItem(
                date: date,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedTime = null;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Available Slots',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        availabilityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error loading availability: $err'),
          data: (bookedAppointments) {
            final slots = _generateTimeSlots(_selectedDate);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: slots.length,
              itemBuilder: (context, index) {
                final slot = slots[index];
                final isBooked = bookedAppointments.any((app) => 
                  app.date.year == slot.year &&
                  app.date.month == slot.month &&
                  app.date.day == slot.day &&
                  app.date.hour == slot.hour &&
                  app.date.minute == slot.minute &&
                  app.status.toUpperCase() != 'CANCELLED'
                );
                final isSelected = _selectedTime != null && 
                                  _selectedTime!.hour == slot.hour && 
                                  _selectedTime!.minute == slot.minute;

                return _TimeSlotItem(
                  time: slot,
                  isBooked: isBooked,
                  isSelected: isSelected,
                  onTap: isBooked ? null : () {
                    setState(() => _selectedTime = slot);
                    widget.onDateTimeSelected(slot);
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_selectedTime == null || widget.isLoading) ? null : widget.onBookPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: HealthCareColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: widget.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Confirm Appointment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}

class _DateItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateItem({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 65,
        decoration: BoxDecoration(
          color: isSelected ? HealthCareColors.primary : (isDark ? HealthCareColors.darkSurface : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? HealthCareColors.primary : (isDark ? Colors.white10 : Colors.transparent),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE').format(date),
              style: TextStyle(
                color: isSelected ? Colors.white70 : theme.hintColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotItem extends StatelessWidget {
  final DateTime time;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlotItem({
    required this.time,
    required this.isBooked,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    if (isBooked) {
      bgColor = isDark ? Colors.white10 : Colors.grey[200]!;
      textColor = theme.hintColor.withOpacity(0.5);
    } else if (isSelected) {
      bgColor = HealthCareColors.primary.withOpacity(0.1);
      textColor = HealthCareColors.primary;
    } else {
      bgColor = isDark ? HealthCareColors.darkSurface : Colors.white;
      textColor = isDark ? Colors.white70 : Colors.black87;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? HealthCareColors.primary : (isDark ? Colors.white10 : Colors.grey[300]!),
          ),
        ),
        child: Text(
          DateFormat('HH:mm').format(time),
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            decoration: isBooked ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
