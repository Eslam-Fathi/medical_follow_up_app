import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/core/utils/responsive.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';

import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/core/services/notification_service.dart';

import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/appointment_card.dart';
import 'package:medical_follow_up_app/features/profile/presentation/manager/profile.provider.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/profile_screen.dart';
import 'package:medical_follow_up_app/features/chatbot/presentation/view/chatbot_screen.dart';

import 'widgets/home_header.dart';
import 'widgets/home_insights_card.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/next_follow_up_card.dart';
import 'widgets/upcoming_checks_section.dart';
import 'widgets/care_team_section.dart';
import 'widgets/desktop_sidebar.dart';
import 'widgets/doctor_appointments_section.dart';
import 'widgets/recent_chats_section.dart';
import 'widgets/doctor_home_content.dart';

/// Main home screen for follow-up.
///
/// Responsibilities:
/// - Fetch profile & appointments
/// - Adapt layout for mobile vs desktop
/// - Handle navigation between tabs (home, checks, chatbot, profile)
/// - Schedule OS-level appointment reminders via [NotificationService].
class HomeFollowUpScreen extends ConsumerStatefulWidget {
  const HomeFollowUpScreen({super.key});

  @override
  ConsumerState<HomeFollowUpScreen> createState() => _HomeFollowUpScreenState();
}

class _HomeFollowUpScreenState extends ConsumerState<HomeFollowUpScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _controller;
  int _selectedBottomIndex = 0;

  /// Filters for the appointments list on the home tab.
  final List<String> _filters = const [
    'All',
    'Upcoming',
    'Missed',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    // One-time entrance animation for the home content.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Pull-to-refresh handler.
  ///
  /// Refreshes profile and appointments in parallel.
  Future<void> _onRefresh() async {
    await ref.refresh(profileProvider.future);
    await ref.refresh(appointmentsProvider.future);
    // nextAppointmentProvider will recalculate from appointmentsProvider.
  }

  /// Staggered fade + slide animation for child widgets.
  Widget _animate(Widget child, int index) {
    final start = 0.1 * index;
    final end = start + 0.6;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: Interval(
          start.clamp(0, 1),
          end.clamp(0, 1),
          curve: Curves.easeIn,
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  start.clamp(0, 1),
                  end.clamp(0, 1),
                  curve: Curves.easeOut,
                ),
              ),
            ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for profile errors and show a SnackBar.
    ref.listen(profileProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });

    // Listen for appointments errors and show a SnackBar.
    ref.listen(appointmentsProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });

    // Listen for upcoming reminders (next 7 days) and schedule hardware alarms.
    ref.listen(upcomingRemindersProvider, (previous, next) {
      next.whenData((reminders) {
        NotificationService().scheduleAppointmentReminders(reminders);
      });
    });

    final profileAsync = ref.watch(profileProvider);

    // Handle profile loading/error states.
    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) {
        // If the user is being logged out, avoid flashing an error.
        final auth = ref.read(authNotifierProvider);
        if (auth.loginResponse == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(body: Center(child: Text(err.toString())));
      },
      data: (profile) {
        final user = profile.user;
        final patient = profile.patient;
        final doctor = profile.doctor;

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDesktop = Responsive.isDesktop(context);
        final isMobile = Responsive.isMobile(context);

        return PopScope(
          canPop: false, // Prevents back navigation from home.
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: colorScheme.background,
            // On mobile, the care team is accessed via an end drawer.
            endDrawer: isMobile
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Drawer(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: CareTeamSection(
                            profile: profile, // mobile care team panel
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
            body: SafeArea(
              child: isDesktop
                  ? _buildDesktopLayout(context, user, patient, doctor, profile)
                  : _buildMobileLayout(context, user, patient, doctor),
            ),
            bottomNavigationBar: isDesktop
                ? null
                : _buildBottomNavigationBar(context),
          ),
        );
      },
    );
  }

  // ---------------- MOBILE LAYOUT ----------------

  /// Builds the mobile/tab layout, switching content based on
  /// the currently selected bottom navigation tab.
  Widget _buildMobileLayout(
    BuildContext context,
    UserDto user,
    Map<String, dynamic>? patient,
    Map<String, dynamic>? doctor,
  ) {
    if (_selectedBottomIndex == 1) {
      return _buildChecksTab(user);
    }
    if (_selectedBottomIndex == 2) {
      return const ChatBotScreen();
    }
    if (_selectedBottomIndex == 3) {
      // Profile tab.
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(AppIcons.heart),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              tooltip: 'Your care team',
            ),
          ],
        ),
        body: const ProfileScreen(),
      );
    }

    final bool isDoctor = user.role.toUpperCase() == 'DOCTOR';

    // Home tab (index 0).
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ResponsiveWrapper(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: greeting, role, care team button.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _animate(
                  HomeHeader(
                    userName: user.name,
                    userRole: user.role,
                    onCareTeamPressed: () =>
                        _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                  0,
                ),
              ),
              if (isDoctor)
                _animate(const DoctorHomeContent(), 1)
              else ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _animate(
                    HomeInsightsCard(role: user.role, patientRecord: patient),
                    1,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _animate(
                    FilterChipsRow(
                      filters: _filters,
                      selectedIndex: ref.watch(homeFilterProvider),
                      onFilterSelected: (index) {
                        ref.read(homeFilterProvider.notifier).state = index;
                      },
                    ),
                    2,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _animate(const NextFollowUpCard(), 3),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _animate(
                    UpcomingChecksSection(
                      onSeeAll: () {
                        setState(() => _selectedBottomIndex = 1);
                      },
                    ),
                    4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- DESKTOP LAYOUT ----------------

  /// Desktop layout:
  /// - Left: sidebar (navigation + logout).
  /// - Center: main content (home/checks/chatbot/profile).
  /// - Right: care team panel.
  Widget _buildDesktopLayout(
    BuildContext context,
    UserDto user,
    Map<String, dynamic>? patient,
    Map<String, dynamic>? doctor,
    dynamic profile,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isChecksTab = _selectedBottomIndex == 1;
    final bool isChatbotTab = _selectedBottomIndex == 2;
    final bool isProfileTab = _selectedBottomIndex == 3;

    return Row(
      children: [
        DesktopSidebar(
          selectedIndex: _selectedBottomIndex,
          onTabSelected: (index) {
            setState(() => _selectedBottomIndex = index);
          },
          onLogout: () async {
            await ref.read(authNotifierProvider.notifier).logout();
            if (!context.mounted) return;
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/auth', (route) => false);
          },
        ),
        // Center content.
        Expanded(
          flex: 7,
          child: isChecksTab
              ? _buildChecksTab(user)
              : isChatbotTab
              ? const ChatBotScreen()
              : isProfileTab
              ? const ProfileScreen()
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _animate(
                            HomeHeader(
                              userName: user.name,
                              userRole: user.role,
                              onCareTeamPressed: null,
                            ),
                            0,
                          ),
                        ),
                        if (user.role.toUpperCase() == 'DOCTOR')
                          _animate(const DoctorHomeContent(), 1)
                        else ...[
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _animate(
                              HomeInsightsCard(
                                role: user.role,
                                patientRecord: patient,
                              ),
                              1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _animate(
                              FilterChipsRow(
                                filters: _filters,
                                selectedIndex: ref.watch(homeFilterProvider),
                                onFilterSelected: (index) {
                                  ref.read(homeFilterProvider.notifier).state =
                                      index;
                                },
                              ),
                              2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _animate(const NextFollowUpCard(), 3),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _animate(
                              UpcomingChecksSection(
                                onSeeAll: () {
                                  setState(() => _selectedBottomIndex = 1);
                                },
                              ),
                              4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
        // Right: care team sidebar.
        Expanded(
          flex: 3,
          child: Container(
            color: isDark ? HealthCareColors.darkSurface : Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: CareTeamSection(
                  profile: profile, // desktop care team column
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- CHECKS TAB (APPOINTMENTS) ----------------

  /// Shared "Checks / Appointments" tab used on both mobile and desktop.
  Widget _buildChecksTab(UserDto user) {
    final asyncAppointments = ref.watch(appointmentsProvider);
    final isDoctor = user.role.toUpperCase() == 'DOCTOR';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        automaticallyImplyLeading: false, // No back button when nested in home.
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(appointmentsProvider);
            },
            tooltip: 'Refresh Appointments',
          ),
          if (Responsive.isMobile(context))
            IconButton(
              icon: Icon(AppIcons.heart),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              tooltip: 'Your care team',
            ),
        ],
      ),
      floatingActionButton: isDoctor
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pushNamed('/doctors_list');
              },
              icon: const Icon(Icons.search),
              label: const Text('Find Doctor'),
            ),
      body: asyncAppointments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (appointments) {
          if (appointments.isEmpty) {
            // Empty-state UX when there are no appointments yet.
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(appointmentsProvider),
              child: ResponsiveWrapper(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 100),
                    const Center(child: Text('No appointments yet')),
                    if (!isDoctor) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/doctors_list');
                          },
                          icon: const Icon(Icons.search),
                          label: const Text('Find Doctor'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          // Non-empty appointments list.
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(appointmentsProvider),
            child: ResponsiveWrapper(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                itemCount: appointments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return AppointmentCard(
                    appointment: appointment,
                    isDoctorView: isDoctor,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- BOTTOM NAV (MOBILE) ----------------

  /// Bottom navigation for mobile / tablet:
  /// 0 = Home, 1 = Checks, 2 = Chatbot, 3 = Profile.
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedBottomIndex,
      onTap: (index) {
        setState(() => _selectedBottomIndex = index);
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(AppIcons.home),
          activeIcon: Icon(AppIcons.homeFilled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.calendar),
          activeIcon: Icon(AppIcons.calendarFilled),
          label: 'Checks',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.chat),
          activeIcon: Icon(AppIcons.chatFilled),
          label: 'Chatbot',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.profile),
          activeIcon: Icon(AppIcons.profileFilled),
          label: 'Profile',
        ),
      ],
    );
  }
}
