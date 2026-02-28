/// Matches the "user" object in the login/register responses.
class UserDto {
  final String id;
  final String name;
  final String email;
  final String role;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}

/// Full response for login/register: message, token, user.
// login_response.dart
class LoginResponse {
  final String message;
  final String token;
  final UserDto user;

  LoginResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
      token: json['token'] as String, // <-- important
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
