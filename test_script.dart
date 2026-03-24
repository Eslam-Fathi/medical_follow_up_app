import 'dart:convert';
import 'dart:io';

void main() async {
  final baseUrl = 'https://medical-app-tau-ten.vercel.app';
  final email = 'doc_test_${DateTime.now().millisecondsSinceEpoch}@medical.com';
  final password = 'Password123!';

  final client = HttpClient();
  
  print('1. Registering user...');
  final regReq = await client.postUrl(Uri.parse('$baseUrl/api/auth/register'));
  regReq.headers.contentType = ContentType.json;
  regReq.write(jsonEncode({
    'name': 'Test Doctor',
    'email': email,
    'password': password,
    'role': 'DOCTOR'
  }));
  final regRes = await regReq.close();
  final regBody = await regRes.transform(utf8.decoder).join();
  print('Register status: ${regRes.statusCode}');
  print('Register body: $regBody');

  if (regRes.statusCode == 200 || regRes.statusCode == 201) {
    print('2. Attempting login...');
    final loginReq = await client.postUrl(Uri.parse('$baseUrl/api/auth/login'));
    loginReq.headers.contentType = ContentType.json;
    loginReq.write(jsonEncode({
      'email': email,
      'password': password,
    }));
    final loginRes = await loginReq.close();
    final loginBody = await loginRes.transform(utf8.decoder).join();
    print('Login status: ${loginRes.statusCode}');
    print('Login body: $loginBody');
  }
}
