import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/core/utils/responsive.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/drawer_content_widget.dart';

import 'widgets/home_header.dart';
import 'widgets/search_and_filter_row.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/next_follow_up_card.dart';
import 'widgets/upcoming_checks_section.dart';
import 'widgets/care_team_section.dart';
import 'widgets/main_drawer.dart';

class HomeFollowUpScreen extends StatefulWidget {
  const HomeFollowUpScreen({super.key});

  @override
  State<HomeFollowUpScreen> createState() => _HomeFollowUpScreenState();
}

class _HomeFollowUpScreenState extends State<HomeFollowUpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedBottomIndex = 0;
  int _selectedFilterIndex = 0;
  final List<String> _filters = const ['All', 'Upcoming', 'Missed', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isDesktop = Responsive.isDesktop(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.background,

      // Drawer behavior on non-desktop (mobile/tablet)
      drawer: !isDesktop
          ? const SizedBox(
              width: 260,
              child: MainDrawer(),
            )
          : null,

      // End drawer only on mobile (to show care team)
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
            ? _buildDesktopLayout(context)
            : _buildMobileLayout(context),
      ),

      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // ====== MOBILE / TABLET LAYOUT (single column, scrollable) ======
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            onCareTeamPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          const SizedBox(height: 24),
          const SearchAndFilterRow(),
          const SizedBox(height: 16),
          FilterChipsRow(
            filters: _filters,
            selectedIndex: _selectedFilterIndex,
            onFilterSelected: (index) {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
          ),
          const SizedBox(height: 24),
          const NextFollowUpCard(),
          const SizedBox(height: 24),
          const UpcomingChecksSection(),
          const SizedBox(height: 24),
          // Care team moved to endDrawer on mobile, so we can omit it here
          // const CareTeamSection(),
        ],
      ),
    );
  }

  // ====== DESKTOP LAYOUT (side-by-side) ======
  Widget _buildDesktopLayout(BuildContext context) {
     final theme = Theme.of(context);
   
     final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        // LEFT: fixed side menu (MainDrawer content)
        Expanded(
          flex: 2,
          child: Container(
            
            color: Theme.of(context).brightness == Brightness.dark
                ? HealthCareColors.darkSurface
                : Colors.white,
            child: DrawerContentWidget(theme: theme, isDark: isDark), 
          ),
        ),

        // CENTER: main dashboard content
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(
                  // On desktop we don't open drawer, since it's always visible
                  onMenuPressed: null,
                  // Could show a quick scroll to right panel if you want
                  onCareTeamPressed: null,
                ),
                const SizedBox(height: 24),
                const SearchAndFilterRow(),
                const SizedBox(height: 16),
                FilterChipsRow(
                  filters: _filters,
                  selectedIndex: _selectedFilterIndex,
                  onFilterSelected: (index) {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
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

        // RIGHT: fixed care team summary panel
        Expanded(
          flex: 3,
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? HealthCareColors.darkSurface
                : Colors.white,
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

  // Bottom navigation (same for all breakpoints)
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedBottomIndex,
      onTap: (index) {
        setState(() {
          _selectedBottomIndex = index;
          // TODO: navigation per tab
        });
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
