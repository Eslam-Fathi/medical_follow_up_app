import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';

final pendingDoctorsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(doctorApiProvider);
  return api.getPendingDoctors();
});
