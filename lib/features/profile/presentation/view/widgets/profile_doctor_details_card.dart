import 'package:flutter/material.dart';
import 'profile_info_row.dart';

/// Extra info for doctor role, now collapsible for UI consistency.
class ProfileDoctorDetailsCard extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const ProfileDoctorDetailsCard({super.key, required this.doctor});

  @override
  State<ProfileDoctorDetailsCard> createState() => _ProfileDoctorDetailsCardState();
}

class _ProfileDoctorDetailsCardState extends State<ProfileDoctorDetailsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(
            Icons.school_outlined,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            'Professional Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          subtitle: Text(
            _isExpanded ? 'Hide certification info' : 'Specialization, License, Experience...',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  const Divider(height: 24),
                  if (widget.doctor['status'] != null)
                    ProfileInfoRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Account Status',
                      value: widget.doctor['status'].toString().toUpperCase(),
                    ),
                  const SizedBox(height: 12),
                  if (widget.doctor['specialization'] != null)
                    ProfileInfoRow(
                      icon: Icons.local_hospital_outlined,
                      label: 'Specialization',
                      value: widget.doctor['specialization'].toString(),
                    ),
                  const SizedBox(height: 12),
                  if (widget.doctor['yearsOfExperience'] != null)
                    ProfileInfoRow(
                      icon: Icons.timeline_outlined,
                      label: 'Clinical Experience',
                      value: '${widget.doctor['yearsOfExperience']} years',
                    ),
                  const SizedBox(height: 12),
                  if (widget.doctor['licenseNumber'] != null)
                    ProfileInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Medical License',
                      value: widget.doctor['licenseNumber'].toString(),
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
