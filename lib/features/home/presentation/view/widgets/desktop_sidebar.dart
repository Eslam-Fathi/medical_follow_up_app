import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/theme_provider.dart';

/// Desktop-only sidebar used in the web/large-screen layout.
///
/// Features:
/// - Hover to expand/collapse (icon-only vs icon+label)
/// - Main navigation (Home / Checks / Chatbot / Profile)
/// - Theme toggle (light/dark)
/// - Logout action at the bottom.
/// A vertical navigation sidebar for desktop and web viewports.
/// 
/// Supports an expandable "hover" state to reveal labels, includes theme toggling,
/// and handles high-level app navigation.
class DesktopSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onLogout;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  /// Whether the sidebar is in expanded mode (hover) or compact.
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isExpanded = true),
      onExit: (_) => setState(() => _isExpanded = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: _isExpanded ? 260 : 80,
        decoration: BoxDecoration(
          color: isDark ? HealthCareColors.darkSurface : Colors.white,
          border: Border(
            right: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
        ),
        child: ClipRect(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: _isExpanded ? 260 : 80,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Logo / app name at the top.
                  _buildSidebarHeader(isDark, theme),
                  const SizedBox(height: 32),
                  // Main menu items.
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isExpanded)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                'MAIN MENU',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark
                                      ? HealthCareColors.darkTextSecondary
                                      : HealthCareColors.textSecondary,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          _SidebarItem(
                            icon: AppIcons.home,
                            activeIcon: AppIcons.homeFilled,
                            label: 'Home',
                            isSelected: widget.selectedIndex == 0,
                            isExpanded: _isExpanded,
                            onTap: () => widget.onTabSelected(0),
                          ),
                          _SidebarItem(
                            icon: AppIcons.calendar,
                            activeIcon: AppIcons.calendarFilled,
                            label: 'Checks',
                            isSelected: widget.selectedIndex == 1,
                            isExpanded: _isExpanded,
                            onTap: () => widget.onTabSelected(1),
                          ),
                          _SidebarItem(
                            icon: AppIcons.chat,
                            activeIcon: AppIcons.chatFilled,
                            label: 'Chatbot',
                            isSelected: widget.selectedIndex == 2,
                            isExpanded: _isExpanded,
                            onTap: () => widget.onTabSelected(2),
                          ),
                          _SidebarItem(
                            icon: AppIcons.profile,
                            activeIcon: AppIcons.profileFilled,
                            label: 'Profile',
                            isSelected: widget.selectedIndex == 3,
                            isExpanded: _isExpanded,
                            onTap: () => widget.onTabSelected(3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom actions: theme toggle + logout.
                  const Divider(height: 1),
                  Consumer(
                    builder: (context, ref, child) {
                      final isDarkMode =
                          ref.watch(themeModeProvider) == ThemeMode.dark;
                      return _SidebarItem(
                        icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        activeIcon: isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        label: isDarkMode ? 'Light Mode' : 'Dark Mode',
                        isSelected: false,
                        isExpanded: _isExpanded,
                        onTap: () {
                          ref.read(themeModeProvider.notifier).state =
                              isDarkMode ? ThemeMode.light : ThemeMode.dark;
                        },
                      );
                    },
                  ),
                  _SidebarItem(
                    icon: Icons.logout_rounded,
                    activeIcon: Icons.logout_rounded,
                    label: 'Logout',
                    isSelected: false,
                    isExpanded: _isExpanded,
                    iconColor: Colors.redAccent,
                    onTap: widget.onLogout,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top header with logo icon and app name (when expanded).
  Widget _buildSidebarHeader(bool isDark, ThemeData theme) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: _isExpanded ? Alignment.centerLeft : Alignment.center,
      child: Row(
        mainAxisAlignment: _isExpanded
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HealthCareColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              AppIcons.activity,
              color: Colors.white,
              size: _isExpanded ? 24 : 20,
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(width: 12),
            Text(
              'HealFolio',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// A single clickable row in the sidebar (icon [+ text when expanded]).
///
/// Handles hover styling and selected state visuals.
/// A private helper widget for individual sidebar navigation rows.
class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final Color? iconColor;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.iconColor,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = HealthCareColors.primary;
    final activeBgColor = isDark
        ? primaryColor.withOpacity(0.15)
        : primaryColor.withOpacity(0.1);
    final hoverBgColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: widget.isExpanded ? 16 : 0,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? activeBgColor
                : (_isHovered ? hoverBgColor : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: widget.isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                widget.isSelected ? widget.activeIcon : widget.icon,
                color:
                    widget.iconColor ??
                    (widget.isSelected
                        ? primaryColor
                        : (isDark
                              ? HealthCareColors.darkTextSecondary
                              : HealthCareColors.textSecondary)),
                size: 24,
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          widget.iconColor ??
                          (widget.isSelected
                              ? primaryColor
                              : (isDark
                                    ? HealthCareColors.darkTextPrimary
                                    : HealthCareColors.textPrimary)),
                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
