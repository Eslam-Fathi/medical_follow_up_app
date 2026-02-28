import 'package:dio/dio.dart';
import 'package:medical_follow_up_app/core/errors/error_mapper.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';


class ProfileResponse {
  final UserDto user;
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? doctor;

  ProfileResponse({
    required this.user,
    this.patient,
    this.doctor,
  });
  

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      patient: json['patient'] as Map<String, dynamic>?,
      doctor: json['doctor'] as Map<String, dynamic>?,
    );
  }
}

class ProfileApi {
  final ApiClient _client;

  ProfileApi(this._client);

 Future<ProfileResponse> getProfile() async {
  try {
    final res = await _client.dio.get('/api/auth/profile');
    return ProfileResponse.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw mapDioError(e, fallback: 'Failed to load profile');
  } catch (_) {
    throw Exception('Failed to load profile');
  }
}

}


//here we define the ProfileApi class that uses the ApiClient to fetch the profile data from the backend. We also define a ProfileResponse model to parse the response. The getProfile method makes a GET request to the /api/auth/profile endpoint and returns a ProfileResponse object. We also handle Dio exceptions and map them to user-friendly error messages.


