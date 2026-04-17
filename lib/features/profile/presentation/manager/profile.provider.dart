import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';
import 'package:medical_follow_up_app/features/profile/data/network/profile_api.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';


final profileApiProvider = Provider<ProfileApi>((ref) {
  final client = ApiClient(); // same singleton you already use
  return ProfileApi(client);
});

final profileProvider = FutureProvider<ProfileResponse>((ref) async {
  // Watch auth state to ensure this provider re-runs on logout/login
  ref.watch(authNotifierProvider);

  final api = ref.watch(profileApiProvider);
  return api.getProfile();
});
