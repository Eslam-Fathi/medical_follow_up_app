import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/features/chat/presentation/view/chat_screen.dart';
import 'package:medical_follow_up_app/features/doctors/data/models/doctor_model/doctor_model.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/view/widgets/doctor_photo_card.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/view/widgets/stat_card.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/view/widgets/weekly_schedule_table.dart';
import 'package:medical_follow_up_app/features/profile/data/network/profile_api.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/view/widgets/booking_section.dart';

// import your booking provider + profile model
// import 'package:medical_follow_up_app/features/appointments/presentation/providers/book_appointment_provider.dart';
// import 'package:medical_follow_up_app/features/profile/data/models/profile_response.dart';

class CareTeamDetailScreen extends ConsumerStatefulWidget {
  final DoctorModel doctor;
  final ProfileResponse profile; // <-- coming from Home

  const CareTeamDetailScreen({
    super.key,
    required this.doctor,
    required this.profile,
  });

  @override
  ConsumerState<CareTeamDetailScreen> createState() =>
      _CareTeamDetailScreenState();
}

class _CareTeamDetailScreenState extends ConsumerState<CareTeamDetailScreen> {
  DateTime? selectedDateTime;

  // DateTime picking is now handled by BookingSection widget

  Future<void> _bookAppointment() async {
    if (selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date & time')),
      );
      return;
    }

    // Attempt to extract the patient document ID
    final patientId =
        widget.profile.patient?['_id']?.toString() ??
        widget.profile.patient?['id']?.toString();

    if (patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your patient profile first.'),
        ),
      );
      return;
    }

    final appointment = await ref
        .read(bookAppointmentProvider.notifier)
        .book(
          patientId: patientId,
          doctorId: widget.doctor.id,
          dateTime: selectedDateTime!,
        );

    final state = ref.read(bookAppointmentProvider);

    if (appointment == null && state.error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!)));
    } else if (appointment != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully')),
      );
    }
    print("#########################################################");

    print(widget.profile.user.name);
    print('Doctor User ID: ${widget.doctor.userId}');
    print('Doctor Document ID: ${widget.doctor.id}');
    print("#########################################################");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900; // big-screen breakpoint

    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Center(
          child: ResponsiveWrapper(
            maxWidth: isWide ? 1100 : 800,
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        if (!isWide)
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        const Spacer(),
                        Text(
                          'Doctor Profile',
                          style: theme.textTheme.titleLarge,
                        ),
                        const Spacer(),
                        SizedBox(width: isWide ? 0 : 48),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // TOP SECTION
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT: photo
                          SizedBox(
                            width: 360,
                            child: DoctorPhotoCard(
                              doctorName: doctor.name,
                              specialty: doctor.specialty,
                              rating: doctor.rating,
                              reviewCount: doctor.reviewCount,
                            ),
                          ),
                          const SizedBox(width: 24),

                          // RIGHT: stats + chat + booking
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 50),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    StatCard(
                                      icon: AppIcons.activity,
                                      value: doctor.patientsCount,
                                      label: 'Patients',
                                      theme: theme,
                                    ),
                                    StatCard(
                                      icon: AppIcons.clock,
                                      value: doctor.yearsExperience,
                                      label: 'Years',
                                      theme: theme,
                                    ),
                                    StatCard(
                                      icon: AppIcons.starFilled,
                                      value: doctor.rating,
                                      label: 'Rating',
                                      theme: theme,
                                    ),
                                    StatCard(
                                      icon: Icons.chat_bubble_outline,
                                      value: doctor.reviewCount,
                                      label: 'Reviews',
                                      theme: theme,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 260,
                                      height: 48,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: voice call
                                        },
                                        icon: Icon(AppIcons.phone),
                                        label: const Text(
                                          'Voice Call (14:30 - 16:00 PM)',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 220,
                                      height: 48,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          final wide = size.width >= 600;
                                          if (!wide) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                      chatPartnerName: doctor.name,
                                                      otherUserId: doctor.userId,
                                                    ),
                                              ),
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (dialogContext) {
                                                return Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 24,
                                                          bottom: 24,
                                                        ),
                                                    child: Material(
                                                      elevation: 8,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      child: SizedBox(
                                                        width: 380,
                                                        height: 480,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                          child: ChatScreen(
                                                            chatPartnerName: doctor.name,
                                                            otherUserId: doctor.userId,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.message_outlined,
                                        ),
                                        label: const Text('Send Message'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // New Booking Section (wide)
                                Container(
                                  margin: const EdgeInsets.only(top: 24),
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark ? HealthCareColors.darkSurface : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: BookingSection(
                                    doctorId: doctor.id,
                                    isLoading: ref.watch(bookAppointmentProvider).isLoading,
                                    onDateTimeSelected: (dt) => setState(() => selectedDateTime = dt),
                                    onBookPressed: _bookAppointment,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      // MOBILE/TABLET: vertical layout
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: DoctorPhotoCard(
                              doctorName: doctor.name,
                              specialty: doctor.specialty,
                              rating: doctor.rating,
                              reviewCount: doctor.reviewCount,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StatCard(
                                icon: AppIcons.activity,
                                value: doctor.patientsCount,
                                label: 'Patients',
                                theme: theme,
                              ),
                              StatCard(
                                icon: AppIcons.clock,
                                value: doctor.yearsExperience,
                                label: 'Years',
                                theme: theme,
                              ),
                              StatCard(
                                icon: AppIcons.starFilled,
                                value: doctor.rating,
                                label: 'Rating',
                                theme: theme,
                              ),
                              StatCard(
                                icon: Icons.chat_bubble_outline,
                                value: doctor.reviewCount,
                                label: 'Reviews',
                                theme: theme,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              SizedBox(
                                width: size.width * 0.7,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: voice call
                                  },
                                  icon: Icon(AppIcons.phone),
                                  label: const Text(
                                    'Voice Call (14:30 - 16:00 PM)',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: size.width * 0.6,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    final wide = size.width >= 600;
                                    if (!wide) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            chatPartnerName: doctor.name,
                                            otherUserId: doctor.userId,
                                          ),
                                        ),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (dialogContext) {
                                          return Align(
                                            alignment: Alignment.bottomRight,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 24,
                                                bottom: 24,
                                              ),
                                              child: Material(
                                                elevation: 8,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: SizedBox(
                                                  width: 380,
                                                  height: 480,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    child: ChatScreen(
                                                      chatPartnerName: doctor.name,
                                                      otherUserId: doctor.userId,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.message_outlined),
                                  label: const Text('Send Message'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              BookingSection(
                                doctorId: doctor.id,
                                isLoading: ref.watch(bookAppointmentProvider).isLoading,
                                onDateTimeSelected: (dt) => setState(() => selectedDateTime = dt),
                                onBookPressed: _bookAppointment,
                              ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // About Me
                    Text(
                      'About Me',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? HealthCareColors.darkSurface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? HealthCareColors.darkBorder
                              : HealthCareColors.borderLight,
                        ),
                      ),
                      child: Text(
                        doctor.aboutMe,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 24),

                    WeeklyScheduleTable(
                      schedule: [
                        DoctorDaySchedule(
                          day: 'Monday',
                          timeRange: '09:00 - 13:00',
                        ),
                        DoctorDaySchedule(
                          day: 'Tuesday',
                          timeRange: '09:00 - 13:00',
                        ),
                        DoctorDaySchedule(day: 'Wednesday', timeRange: 'Off'),
                        DoctorDaySchedule(
                          day: 'Thursday',
                          timeRange: '14:00 - 18:00',
                        ),
                        DoctorDaySchedule(
                          day: 'Friday',
                          timeRange: '10:00 - 15:00',
                        ),
                        DoctorDaySchedule(day: 'Saturday', timeRange: 'Off'),
                        DoctorDaySchedule(day: 'Sunday', timeRange: 'Off'),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
