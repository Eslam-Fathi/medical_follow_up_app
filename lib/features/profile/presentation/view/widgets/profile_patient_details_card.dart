import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/widgets/profile_info_row.dart';

/// Card that shows **patient‑specific** medical details (chronic diseases,
/// allergies, notes) in a collapsible "Medical History" section.
///
/// It expects a `patient` map coming from the profile API.
class ProfilePatientDetailsCard extends StatefulWidget {
  final Map<String, dynamic> patient;

  const ProfilePatientDetailsCard({super.key, required this.patient});

  @override
  State<ProfilePatientDetailsCard> createState() =>
      _ProfilePatientDetailsCardState();
}

class _ProfilePatientDetailsCardState extends State<ProfilePatientDetailsCard> {
  /// Tracks whether the ExpansionTile is currently expanded.
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    /// Helper to convert a List<dynamic> into a comma‑separated string.
    /// If the list is null or empty, we show "None".
    String formatList(dynamic value) {
      if (value is List && value.isNotEmpty) {
        return value.join(', ');
      }
      return 'None';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isExpanded ? 0.08 : 0.04),
            blurRadius: _isExpanded ? 15 : 10,
            offset: Offset(0, _isExpanded ? 8 : 4),
          ),
        ],
      ),
      // Wrap ExpansionTile in a Theme to hide the default Divider.
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // Keep local state in sync with the tile's expanded state.
          onExpansionChanged: (expanded) =>
              setState(() => _isExpanded = expanded),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(
            Icons.history_edu_rounded,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            'Medical History',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          subtitle: Text(
            _isExpanded
                ? 'Hide detailed records'
                : 'Allergies, Chronic Diseases...',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  const Divider(height: 24),

                  /// Chronic diseases list (from patient.chronicDiseases).
                  ProfileInfoRow(
                    icon: Icons.personal_injury_outlined,
                    label: 'Chronic Diseases',
                    value: formatList(widget.patient['chronicDiseases']),
                  ),
                  const SizedBox(height: 12),

                  /// Allergies list (from patient.allergies).
                  ProfileInfoRow(
                    icon: Icons.warning_amber_rounded,
                    label: 'Allergies',
                    value: formatList(widget.patient['allergies']),
                  ),
                  const SizedBox(height: 12),

                  /// Optional clinical notes; only shown if non‑empty.
                  if (widget.patient['notes'] != null &&
                      widget.patient['notes'].toString().isNotEmpty)
                    ProfileInfoRow(
                      icon: Icons.notes_rounded,
                      label: 'Clinical Notes',
                      value: widget.patient['notes'].toString(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
