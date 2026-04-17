import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/manager/doctor_approval_provider.dart';

class AdminDashboardStats {
  final int totalDoctors;
  final int pendingApprovals;
  final int totalAppointments; // Placeholder for now
  final Map<String, int> specialtyDistribution;

  AdminDashboardStats({
    required this.totalDoctors,
    required this.pendingApprovals,
    required this.totalAppointments,
    required this.specialtyDistribution,
  });
}

final adminDashboardStatsProvider = FutureProvider<AdminDashboardStats>((ref) async {
  final doctorApi = ref.watch(doctorApiProvider);
  
  // Fetch all and pending concurrently
  final results = await Future.wait([
    doctorApi.getAllDoctors(),
    ref.watch(pendingDoctorsProvider.future),
  ]);

  final allDoctors = results[0] as List;
  final pendingDoctors = results[1] as List;

  // Calculate specialty distribution
  final Map<String, int> specialtyDistribution = {};
  for (final doctor in allDoctors) {
    final specialty = doctor.specialty;
    specialtyDistribution[specialty] = (specialtyDistribution[specialty] ?? 0) + 1;
  }

  return AdminDashboardStats(
    totalDoctors: allDoctors.length,
    pendingApprovals: pendingDoctors.length,
    totalAppointments: 156, // Mocked for now as Endpoint is limited
    specialtyDistribution: specialtyDistribution,
  );
});
