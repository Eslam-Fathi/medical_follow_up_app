import 'package:dio/dio.dart';
import 'package:medical_follow_up_app/core/errors/error_mapper.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';


/// Low‑level API layer for auth.
/// Talks directly to the backend and knows nothing about UI / Riverpod.

class AuthApi {
  final ApiClient _client;
  AuthApi(this._client);

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return LoginResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e, fallback: 'Login failed. Please try again.');
    } catch (_) {
      throw Exception('Login failed. Please try again.');
    }
  }

  Future<LoginResponse> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final res = await _client.dio.post(
        '/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return LoginResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e, fallback: 'Registration failed. Please try again.');
    } catch (_) {
      throw Exception('Registration failed. Please try again.');
    }
  }
}
