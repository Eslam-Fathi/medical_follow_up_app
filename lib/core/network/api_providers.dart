import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/auth/data/models/auth_api/auth_api.dart';
import 'api_client.dart';


/// Provides a singleton ApiClient instance.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provides AuthApi, which uses ApiClient internally.
final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApi(client);
});
