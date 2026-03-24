import 'dart:convert';
import 'dart:io';

void main() async {
  final baseUrl = 'https://medical-app-tau-ten.vercel.app';
  final client = HttpClient();
  
  print('Attempting login with admin@medical.com / Admin123456...');
  final loginReq = await client.postUrl(Uri.parse('$baseUrl/api/auth/login'));
  loginReq.headers.contentType = ContentType.json;
  loginReq.write(jsonEncode({
    'email': 'admin@medical.com',
    'password': 'Admin123456',
  }));
  final loginRes = await loginReq.close();
  final loginBody = await loginRes.transform(utf8.decoder).join();
  print('Login status: ${loginRes.statusCode}');
  print('Login body: $loginBody');
}
