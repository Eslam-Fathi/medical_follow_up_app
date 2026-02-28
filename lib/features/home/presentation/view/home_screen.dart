import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/core/utils/responsive.dart';

import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/appointment_card.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/drawer_content_widget.dart';
import 'package:medical_follow_up_app/features/profile/presentation/manager/profile.provider.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/profile_screen.dart';

import 'widgets/home_header.dart';
import 'widgets/search_and_filter_row.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/next_follow_up_card.dart';
import 'widgets/upcoming_checks_section.dart';
import 'widgets/care_team_section.dart';
import 'widgets/main_drawer.dart';

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

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colorScheme.background,
          drawer: !isDesktop
              ? SizedBox(
                  width: 260,
                  child: MainDrawer(
                    userName: user.name,
                    userEmail: user.email,
                    userRole: user.role,
                   onLogout: () async {
  await ref.read(authNotifierProvider.notifier).logout();

  // Clear user-specific providers
  ref.invalidate(profileProvider);
  ref.invalidate(appointmentsProvider);
  // (you can add others later)

  if (context.mounted) {
    Navigator.of(context).pushReplacementNamed('/auth');
  }
},

                  ),
                )
              : null,
          endDrawer: isMobile
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Drawer(
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: CareTeamSection(),
                      ),
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            child: isDesktop
                ? _buildDesktopLayout(context, user, patient, doctor)
                : _buildMobileLayout(context, user, patient, doctor),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context),
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
      return _buildChecksTab();
    }
      // Profile tab
  if (_selectedBottomIndex == 3) {
    return const ProfileScreen();
  }

    // Home tab
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            userName: user.name,
            userRole: user.role,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
            onCareTeamPressed: () =>
                _scaffoldKey.currentState?.openEndDrawer(),
          ),
          const SizedBox(height: 24),
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
          const UpcomingChecksSection(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    UserDto user,
    Map<String, dynamic>? patient,
    Map<String, dynamic>? doctor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isChecksTab = _selectedBottomIndex == 1;
final bool isProfileTab = _selectedBottomIndex == 3;

    return Row(
      children: [
        // LEFT: drawer
        Expanded(
          flex: 2,
          child: Container(
            color: isDark ? HealthCareColors.darkSurface : Colors.white,
            child: DrawerContentWidget(
              theme: theme,
              isDark: isDark,
              userName: user.name,
              userEmail: user.email,
              userRole: user.role,
            onLogout: () async {
  await ref.read(authNotifierProvider.notifier).logout();

  // Clear user-specific providers
  ref.invalidate(profileProvider);
  ref.invalidate(appointmentsProvider);
  // (you can add others later)

  if (context.mounted) {
    Navigator.of(context).pushReplacementNamed('/auth');
  }
},

            ),
          ),
        ),

        // CENTER: main content
        Expanded(
          flex: 7,
          child: isChecksTab
    ? _buildChecksTab()
    : isProfileTab
        ? const ProfileScreen()
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
                      const UpcomingChecksSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),

        // RIGHT: care team
        Expanded(
          flex: 3,
          child: Container(
            color: isDark ? HealthCareColors.darkSurface : Colors.white,
            child: const SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: CareTeamSection(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecksTab() {
    final asyncAppointments = ref.watch(appointmentsProvider);

    return asyncAppointments.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(err.toString())),
      data: (appointments) {
        if (appointments.isEmpty) {
          return const Center(child: Text('No appointments yet'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          itemCount: appointments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final a = appointments[index];
            return AppointmentCard(appointment: a);
          },
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedBottomIndex,
      onTap: (index) {
        setState(() => _selectedBottomIndex = index);
        // TODO: navigate per tab if needed
      },
      items:  [
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
          icon: Icon(AppIcons.reports),
          activeIcon: Icon(AppIcons.reportsFilled),
          label: 'Reports',
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
