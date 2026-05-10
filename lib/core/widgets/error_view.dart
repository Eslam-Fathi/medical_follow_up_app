import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/errors/failure.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

/// A widget that displays an error message with an optional retry button.
/// 
/// This widget handles displaying different types of [Failure]s and provides
/// a consistent UI for error states across the app.
class ErrorView extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final bool isFullPage;

  const ErrorView({
    super.key,
    required this.failure,
    this.onRetry,
    this.isFullPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isFullPage ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // Error Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(failure.icon, size: 48, color: Colors.redAccent),
        ),
        const SizedBox(height: 24),
        // Error Title
        Text(
          failure.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : HealthCareColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Error Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            failure.message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : HealthCareColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        if (failure.code != null) ...[
          const SizedBox(height: 8),
          Text(
            'Error Code: ${failure.code}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
          ),
        ],
        const SizedBox(height: 32),
        // Retry Button
        if (onRetry != null)
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: HealthCareColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );

    if (isFullPage) {
      return Scaffold(body: Center(child: content));
    }

    return Center(child: content);
  }
}
