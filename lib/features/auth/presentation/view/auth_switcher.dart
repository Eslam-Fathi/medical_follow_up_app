import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:medical_follow_up_app/features/auth/presentation/view/login_screen.dart';
import 'package:medical_follow_up_app/features/auth/presentation/view/register_screen.dart';

class AuthSwitcher extends StatefulWidget {
  const AuthSwitcher({super.key});

  @override
  State<AuthSwitcher> createState() => _AuthSwitcherState();
}

class _AuthSwitcherState extends State<AuthSwitcher> {
  bool _showLogin = true;

  void _toggle() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
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
              transitionBuilder: (child, animation) {
                // child.key is ValueKey<bool>(_showLogin)
                final isLoginSide = (child.key as ValueKey<bool>).value;
  
                // Flip from left for login, from right for signup
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
                    final angle = rotateAnim.value * pi;
  
                    // Hide "back" side when more than 90 degrees
                    final isUnder = angle.abs() > (pi / 2);
  
                    return Opacity(
                      opacity: isUnder ? 0.0 : 1.0,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // perspective
                          ..rotateY(angle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 0,
                              sigmaY: 0,
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
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
                          Text('MedME', style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 4),
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
                          _buildToggleTabs(theme),
                          const SizedBox(height: 20),
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

  Widget _buildToggleTabs(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: SizedBox(
        height: 32,
        width: 240,
        child: Stack(
          children: [
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

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
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
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 32,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelMedium!.copyWith(
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
