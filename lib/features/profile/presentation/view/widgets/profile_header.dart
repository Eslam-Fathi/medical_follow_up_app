import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

/// Profile header used on the profile screen.
///
/// Shows:
/// - a medical‑themed banner background
/// - the user's avatar (initials)
/// - the user's name
/// - a role badge (doctor vs patient)
class ProfileHeader extends StatefulWidget {
  final UserDto user;
  final bool isDoctor;

  /// When [large] is true, the header/avatars are rendered bigger
  /// (used on tablet / desktop layouts).
  final bool large;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isDoctor,
    this.large = false,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Single animation controller used for both fade and slide effects.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Simple ease‑in fade for avatar + texts.
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Slight "pop‑up" effect from below for name / role.
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Avatar scales with layout size.
    final avatarRadius = widget.large ? 54.0 : 44.0;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Gradient banner with a custom "medical heartbeat" pattern.
            Container(
              height: widget.large ? 160 : 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    HealthCareColors.primary,
                    HealthCareColors.primaryLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: MedicalPatternPainter(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
              ),
            ),

            // Centered avatar, visually overlapping the bottom of the banner.
            Positioned(
              bottom: -avatarRadius,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _fadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // White border to separate avatar from the banner.
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: HealthCareColors.primaryLighter,
                      // Fallback to initials from the user's name.
                      child: Text(
                        _initials(widget.user.name),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: HealthCareColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Spacer to account for the overlapping avatar height.
        SizedBox(height: avatarRadius + 12),

        // Name + Role badge with slide/fade entrance.
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  widget.user.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDoctor
                        ? colorScheme.primary.withOpacity(0.1)
                        : colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.isDoctor ? 'Healthcare Professional' : 'Patient',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: widget.isDoctor
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Derives initials from the full name, used when there is no avatar image.
  ///
  /// - "Ahmed" -> "A"
  /// - "Ahmed Youssef" -> "AY"
  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

/// Custom painter that draws a subtle medical‑themed pattern
/// (heartbeat‑like lines + crosses) on the banner background.
class MedicalPatternPainter extends CustomPainter {
  final Color color;

  MedicalPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw a repeating "heartbeat" line across the banner width.
    double x = 0;
    while (x < size.width) {
      path.moveTo(x, size.height * 0.7);
      path.lineTo(x + 20, size.height * 0.7);
      path.lineTo(x + 25, size.height * 0.4);
      path.lineTo(x + 30, size.height * 0.9);
      path.lineTo(x + 35, size.height * 0.7);
      path.lineTo(x + 60, size.height * 0.7);
      x += 80;
    }

    canvas.drawPath(path, paint);

    // Add small decorative crosses at various positions.
    for (int i = 0; i < 5; i++) {
      final px = (i * 70.0 + 30) % size.width;
      final py = (i * 40.0 + 20) % size.height;
      canvas.drawLine(Offset(px - 5, py), Offset(px + 5, py), paint);
      canvas.drawLine(Offset(px, py - 5), Offset(px, py + 5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
