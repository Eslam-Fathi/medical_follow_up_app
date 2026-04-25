import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFECFEFF), Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium Illustration/Icon
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: HealthCareColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FeatherIcons.map,
                size: 80,
                color: HealthCareColors.primary,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              '404',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: HealthCareColors.primary,
                fontSize: 80,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lost your way?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : HealthCareColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The page you are looking for doesn\'t exist or has been moved to a new location.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white70 : HealthCareColors.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            // Home Button
            SizedBox(
              width: 250,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                icon: const Icon(FeatherIcons.home),
                label: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HealthCareColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Go Back',
                style: TextStyle(
                  color: HealthCareColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
