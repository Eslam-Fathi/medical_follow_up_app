import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:medical_follow_up_app/features/auth/presentation/view/login_screen.dart';
import 'package:medical_follow_up_app/features/auth/presentation/view/register_screen.dart';

/// A container widget that hosts both [LoginScreen] and [RegisterScreen] and
/// switches between them with a 3D flip card animation.
///
/// ### Responsibilities
/// - Owns the boolean `_showLogin` toggle state.
/// - Provides a shared visual container (gradient background, white card,
///   "MedME" branding) so neither the login nor the register screen needs to
///   re-implement the outer shell.
/// - Implements the **flip card transition**: uses [AnimatedSwitcher] combined
///   with a 3D Y-axis rotation (via [Matrix4.rotateY]) to create the illusion
///   of flipping a physical card over when switching between login and register.
///
/// ### Why AnimatedSwitcher?
/// [AnimatedSwitcher] detects when its `child` widget changes (via `key`) and
/// runs a configurable transition. By assigning [ValueKey<bool>(_showLogin)]
/// as the child's key, the switcher knows to animate whenever `_showLogin` flips.
///
/// ### Flip animation implementation
/// The flip effect has three components:
/// 1. **Rotation** — A [Tween] from ±0.5 turns (π radians) to 0.0 turns,
///    applied to the incoming widget. The direction (-0.5 for login, +0.5 for
///    signup) determines whether it flips left or right.
/// 2. **Perspective** — Setting `Matrix4.entry(3, 2) = 0.001` adds a slight
///    perspective distortion that makes the rotation look 3D.
/// 3. **Back-face hiding** — When the rotation angle exceeds π/2 (90°), the
///    widget's opacity is set to 0 so the "back side" of the card is invisible,
///    simulating an opaque card.
///
/// ### Back navigation guard
/// [PopScope(canPop: false)] prevents the user from navigating back from the
/// auth screen with the hardware back button, since there is no meaningful
/// previous screen to return to.
class AuthSwitcher extends StatefulWidget {
  const AuthSwitcher({super.key});

  @override
  State<AuthSwitcher> createState() => _AuthSwitcherState();
}

class _AuthSwitcherState extends State<AuthSwitcher> {
  /// Whether the login form is currently visible (`true`) or the register
  /// form is visible (`false`).
  bool _showLogin = true;

  /// Toggles between the login and register screens.
  ///
  /// Called both by the tab bar buttons ([_buildToggleTabs]) and by the
  /// callback passed to [LoginScreen.onCreateAccountTap] /
  /// [RegisterScreen.onLoginTap].
  void _toggle() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      // Prevent the user from accidentally navigating "back" past the auth screen.
      canPop: false,
      child: Scaffold(
        body: Container(
          // Subtle gradient background that fills the entire screen behind the card.
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.08),
                theme.colorScheme.secondary.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 550),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              // ── Custom Flip Transition ────────────────────────────────────
              transitionBuilder: (child, animation) {
                // Determine the flip direction based on which card is incoming.
                // child.key tells us if it's the login card or the signup card.
                final isLoginSide = (child.key as ValueKey<bool>).value;

                // Tween from ±half-turn (π radians) to 0 — the animation plays
                // forward (0→1), so the widget starts rotated and ends at 0.
                final rotateAnim = Tween<double>(
                  begin: isLoginSide ? -0.5 : 0.5, // in "turns" (0.5 = half turn)
                  end: 0.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                );

                return AnimatedBuilder(
                  animation: rotateAnim,
                  child: child,
                  builder: (context, child) {
                    // Convert turns to radians: turns * π
                    final angle = rotateAnim.value * pi;

                    // When the rotation exceeds 90°, hide the widget to
                    // simulate an opaque card (no see-through back-face).
                    final isUnder = angle.abs() > (pi / 2);

                    return Opacity(
                      opacity: isUnder ? 0.0 : 1.0,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          // Add perspective depth: 0.001 is a standard value
                          // for a subtle but visible 3D effect.
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            // BackdropFilter is included for future glassmorphism
                            // enhancement. Currently sigma = 0 (no blur).
                            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              // ── The Switching Child ───────────────────────────────────────
              // ValueKey<bool>(_showLogin) changes when _showLogin flips, which
              // triggers AnimatedSwitcher to run the transition above.
              child: Card(
                key: ValueKey<bool>(_showLogin),
                elevation: 18,
                shadowColor: theme.colorScheme.primary.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 24),
                          // App name branding at the top of the auth card.
                          Text('MedME', style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          // Subtitle animates between "Login to continue" and
                          // "Create your account" as the tab switches.
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              _showLogin
                                  ? 'Login to continue'
                                  : 'Create your account',
                              key: ValueKey<bool>(_showLogin),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Pill-shaped tab bar for Login / Sign up.
                          _buildToggleTabs(theme),
                          const SizedBox(height: 20),
                          // Inline the appropriate screen (not a route push).
                          _showLogin
                              ? LoginScreen(onCreateAccountTap: _toggle)
                              : RegisterScreen(onLoginTap: _toggle),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the pill-shaped Login / Sign up toggle tab bar.
  ///
  /// **How it works:**
  /// - A [Stack] contains two layers:
  ///   1. An [AnimatedAlign] that slides a filled pill indicator left or right.
  ///   2. A [Row] of two [_TabButton] widgets positioned over the indicator.
  /// - The indicator's color contrasts against the tab text, creating the
  ///   "active tab" visual without needing a [TabBar] or [TabController].
  Widget _buildToggleTabs(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999), // Fully rounded pill shape.
      ),
      child: SizedBox(
        height: 32,
        width: 240,
        child: Stack(
          children: [
            // Animated sliding indicator pill.
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              alignment:
                  _showLogin ? Alignment.centerLeft : Alignment.centerRight,
              curve: Curves.easeOutCubic,
              child: Container(
                width: 120,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Tab labels drawn over the indicator.
            Row(
              children: [
                _TabButton(
                  label: 'Login',
                  selected: _showLogin,
                  onTap: () {
                    if (!_showLogin) _toggle();
                  },
                ),
                _TabButton(
                  label: 'Sign up',
                  selected: !_showLogin,
                  onTap: () {
                    if (_showLogin) _toggle();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A private tab button used inside [AuthSwitcher._buildToggleTabs].
///
/// Uses [GestureDetector] (rather than [TextButton]) for full control over
/// the touch target size and to avoid Material button padding that would
/// break the layout inside the pill indicator.
///
/// [AnimatedDefaultTextStyle] smoothly transitions the text color and weight
/// between selected and unselected states when the tab changes.
class _TabButton extends StatelessWidget {
  /// The text label for this tab (e.g. "Login" or "Sign up").
  final String label;

  /// Whether this tab is currently selected/active.
  final bool selected;

  /// Callback invoked when the user taps this tab.
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        // opaque ensures the gesture recognizer covers the full area,
        // even where the widget has no visible color (transparent center).
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 32,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelMedium!.copyWith(
                // Active tab: white text (on colored pill).
                // Inactive tab: subtle grey text (on transparent background).
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
