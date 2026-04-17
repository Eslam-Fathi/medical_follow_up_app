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
import 'widgets/search_and_filter_row.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/next_follow_up_card.dart';
import 'widgets/upcoming_checks_section.dart';
import 'widgets/care_team_section.dart';
import 'widgets/main_drawer.dart';
import 'widgets/desktop_sidebar.dart';
import 'widgets/doctor_appointments_section.dart';
import 'widgets/recent_chats_section.dart';

class HomeFollowUpScreen extends ConsumerStatefulWidget {
  const HomeFollowUpScreen({super.key});

  @override
  ConsumerState<HomeFollowUpScreen> createState() =>
      _HomeFollowUpScreenState();
}

class _HomeFollowUpScreenState extends ConsumerState<HomeFollowUpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedBottomIndex = 0;
  int _selectedFilterIndex = 0;
  final List<String> _filters =
      const ['All', 'Upcoming', 'Missed', 'Completed'];

  Future<void> _onRefresh() async {
    // Refresh the core providers that drive the home screen
    await ref.refresh(profileProvider.future);
    await ref.refresh(appointmentsProvider.future);
    // nextAppointmentProvider will follow automatically as it watches appointmentsProvider
  }

  @override
  Widget build(BuildContext context) {
    // Listen for profile errors → show SnackBar
    ref.listen(profileProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err.toString())),
          );
        },
      );
    });

    // Listen for appointments errors → show SnackBar
    ref.listen(appointmentsProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err.toString())),
          );
        },
      );
    });

    // Listen for upcoming reminders (next 7 days) → schedule hardware alarms
    ref.listen(upcomingRemindersProvider, (previous, next) {
      next.whenData((reminders) {
        NotificationService().scheduleAppointmentReminders(reminders);
      });
    });

    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text(err.toString())),
      ),
      data: (profile) {
        final user = profile.user;
        final patient = profile.patient;
        final doctor = profile.doctor;

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDesktop = Responsive.isDesktop(context);
        final isMobile = Responsive.isMobile(context);

        return PopScope(
          canPop: false,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: colorScheme.background,
            drawer: isMobile
                ? MainDrawer(
                    userName: user.name,
                    userEmail: user.email,
                    userRole: user.role,
                    onLogout: () async {
                      await ref.read(authNotifierProvider.notifier).logout();
                      if (!context.mounted) return;
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/auth', (route) => false);
                    },
                  )
                : null,
            endDrawer: isMobile
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Drawer(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: CareTeamSection(
                            profile: profile, // <-- pass here (mobile)
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
            bottomNavigationBar:
                isDesktop ? null : _buildBottomNavigationBar(context),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    UserDto user,
    Map<String, dynamic>? patient,
    Map<String, dynamic>? doctor,
  ) {
    if (_selectedBottomIndex == 1) {
      // Checks tab
      return _buildChecksTab(user);
    }

    // Chatbot tab
    if (_selectedBottomIndex == 2) {
      return const ChatBotScreen();
    }

    // Profile tab
    if (_selectedBottomIndex == 3) {
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

    // Home tab
    final bool isDoctor = user.role.toUpperCase() == 'DOCTOR';

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ResponsiveWrapper(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                userName: user.name,
                userRole: user.role,
                onMenuPressed: () =>
                    _scaffoldKey.currentState?.openDrawer(),
                onCareTeamPressed: () =>
                    _scaffoldKey.currentState?.openEndDrawer(),
              ),
              const SizedBox(height: 24),
              if (isDoctor) ...[
                DoctorAppointmentsSection(
                  onSeeAll: () {
                    setState(() => _selectedBottomIndex = 1);
                  },
                ),
                const SizedBox(height: 24),
                const RecentChatsSection(),
              ] else ...[
                const SearchAndFilterRow(),
                const SizedBox(height: 16),
                FilterChipsRow(
                  filters: _filters,
                  selectedIndex: _selectedFilterIndex,
                  onFilterSelected: (index) {
                    setState(() => _selectedFilterIndex = index);
                  },
                ),
                const SizedBox(height: 24),
                const NextFollowUpCard(),
                const SizedBox(height: 24),
                UpcomingChecksSection(
                  onSeeAll: () {
                    setState(() => _selectedBottomIndex = 1);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    UserDto user,
    Map<String, dynamic>? patient,
    Map<String, dynamic>? doctor,
    dynamic profile, // add profile param
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
            Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
          },
        ),
        // CENTER: main content
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
                              padding:
                                  const EdgeInsets.fromLTRB(20, 24, 20, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  HomeHeader(
                                    userName: user.name,
                                    userRole: user.role,
                                    onMenuPressed: null,
                                    onCareTeamPressed: null,
                                  ),
                                  const SizedBox(height: 24),
                                  if (user.role.toUpperCase() == 'DOCTOR') ...[
                                    DoctorAppointmentsSection(
                                      onSeeAll: () {
                                        setState(() => _selectedBottomIndex = 1);
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    const RecentChatsSection(),
                                  ] else ...[
                                    const SearchAndFilterRow(),
                                    const SizedBox(height: 16),
                                    FilterChipsRow(
                                      filters: _filters,
                                      selectedIndex: _selectedFilterIndex,
                                      onFilterSelected: (index) {
                                        setState(
                                            () => _selectedFilterIndex = index);
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    const NextFollowUpCard(),
                                    const SizedBox(height: 24),
                                    UpcomingChecksSection(
                                      onSeeAll: () {
                                        setState(() => _selectedBottomIndex = 1);
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
        ),

        // RIGHT: care team
        Expanded(
          flex: 3,
          child: Container(
            color: isDark ? HealthCareColors.darkSurface : Colors.white,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: CareTeamSection(
                  profile: profile, // <-- pass here (desktop)
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecksTab(UserDto user) {
    final asyncAppointments = ref.watch(appointmentsProvider);
    final isDoctor = user.role.toUpperCase() == 'DOCTOR';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        automaticallyImplyLeading: false, // Don't show back button if nested
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
