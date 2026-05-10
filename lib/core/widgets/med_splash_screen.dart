import 'package:flutter/material.dart';

/// The initial splash screen of the application.
/// 
/// It features a pulse-animated medical icon and the app logo,
/// providing a polished first impression while the app initializes.
class MedSplashScreen extends StatefulWidget {
  const MedSplashScreen({super.key});

  @override
  State<MedSplashScreen> createState() => _MedSplashScreenState();
}

class _MedSplashScreenState extends State<MedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.8),
                    theme.colorScheme.primary.withOpacity(0.15),
                  ]
                : [
                    theme.colorScheme.primary.withOpacity(0.04),
                    theme.colorScheme.surface,
                    theme.colorScheme.secondary.withOpacity(0.08),
                  ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Placeholder Icon with glowing effect
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primaryContainer,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withOpacity(0.4 * _fadeAnimation.value),
                            blurRadius: 35,
                            spreadRadius: 8,
                          ),
                          BoxShadow(
                            color: theme.colorScheme.secondary
                                .withOpacity(0.2 * _fadeAnimation.value),
                            blurRadius: 20,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Icon(
                        // Placeholder Icon
                        Icons.medical_services_rounded,
                        size: 65,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 56),

            // App Title Placeholder
            Text(
              'MedME',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            AnimatedOpacity(
              opacity: 0.8,
              duration: const Duration(seconds: 1),
              child: Text(
                'Your Health Companion',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 64),

            // Loading Indicator
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                color: theme.colorScheme.primary.withOpacity(0.8),
                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
