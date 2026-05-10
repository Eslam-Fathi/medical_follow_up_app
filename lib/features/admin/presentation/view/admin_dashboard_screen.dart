import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';
import 'package:medical_follow_up_app/core/theme/theme_provider.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/manager/doctor_approval_provider.dart';
import 'package:medical_follow_up_app/features/admin/presentation/manager/admin_dashboard_provider.dart';
import 'package:medical_follow_up_app/features/admin/presentation/view/widgets/dashboard_stats_grid.dart';
import 'package:medical_follow_up_app/features/admin/presentation/view/widgets/doctor_specialty_chart.dart';

/// The primary dashboard for administrative users.
/// 
/// It displays high-level statistics, doctor specialty distribution charts,
/// and a list of pending doctor applications for approval or rejection.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _updateStatus(
    WidgetRef ref,
    BuildContext context,
    String doctorId,
    String status,
  ) async {
    try {
      final docApi = ref.read(doctorApiProvider);
      await docApi.updateDoctorStatus(doctorId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile $status!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: status == 'APPROVED' ? Colors.green : Colors.red,
        ),
      );
      ref.invalidate(pendingDoctorsProvider);
      ref.invalidate(adminDashboardStatsProvider);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final pendingDoctorsAsync = ref.watch(pendingDoctorsProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(
                currentThemeMode == ThemeMode.system
                    ? Icons.brightness_auto
                    : currentThemeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              tooltip: 'Toggle Theme',
              onPressed: () {
                ref.read(themeModeProvider.notifier).cycleTheme();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
                Navigator.of(context).pushReplacementNamed('/auth');
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) =>
              Center(child: Text('Failed to load dashboard: $err')),
          data: (stats) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminDashboardStatsProvider);
              ref.invalidate(pendingDoctorsProvider);
            },
            child: ResponsiveWrapper(
              maxWidth: 1200.0, // Increased width for dashboard view
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 900;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DashboardStatsGrid(
                          totalDoctors: stats.totalDoctors,
                          pendingApprovals: stats.pendingApprovals,
                          totalAppointments: stats.totalAppointments,
                        ),
                        const SizedBox(height: 32),

                        if (isWideScreen)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Analytics Column
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Analytics',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    DoctorSpecialtyChart(
                                      specialtyDistribution:
                                          stats.specialtyDistribution,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 32),
                              // Pending Requests Column
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.pending_actions,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Pending Doctor Approval',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPendingList(pendingDoctorsAsync, ref),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          // Stacked layout for mobile/small tablets
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Analytics',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DoctorSpecialtyChart(
                                specialtyDistribution:
                                    stats.specialtyDistribution,
                              ),
                              const SizedBox(height: 40),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.pending_actions,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pending Doctor Approval',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildPendingList(pendingDoctorsAsync, ref),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingList(
    AsyncValue<List<dynamic>> pendingDoctorsAsync,
    WidgetRef ref,
  ) {
    return pendingDoctorsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error loading pending doctors: $err'),
      data: (pendingDoctors) {
        if (pendingDoctors.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: const Column(
              children: [
                Icon(Icons.done_all, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'All applications are processed!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pendingDoctors.length,
          itemBuilder: (context, index) {
            final doc = pendingDoctors[index];
            return _DoctorApprovalCard(
              doctor: doc,
              onApprove: (id) => _updateStatus(ref, context, id, 'APPROVED'),
              onReject: (id) => _updateStatus(ref, context, id, 'REJECTED'),
            );
          },
        );
      },
    );
  }
}

/// A card representing a doctor application pending administrative approval.
/// 
/// Displays doctor details such as specialization, experience, and license number,
/// with buttons to approve or reject the application.
class _DoctorApprovalCard extends StatelessWidget {
  final dynamic doctor;
  final Function(String) onApprove;
  final Function(String) onReject;

  const _DoctorApprovalCard({
    required this.doctor,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final docId = doctor['_id'] ?? '';
    final userName = doctor['userId'] is Map
        ? doctor['userId']['name']
        : 'Unknown User';
    final specialization = doctor['specialization'] ?? 'Unknown';
    final experience = doctor['yearsOfExperience'] ?? '?';
    final license = doctor['licenseNumber'] ?? '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          specialization,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$experience Years Exp.',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lic: $license',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => onReject(docId),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => onApprove(docId),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
