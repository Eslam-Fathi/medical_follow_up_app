import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';

final pendingDoctorsProvider = FutureProvider<List<dynamic>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  if (authState.loginResponse == null) return [];

  final api = ref.watch(doctorApiProvider);
  return api.getPendingDoctors();
});
