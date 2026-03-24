import 'dart:convert';
import 'dart:io';

void main() async {
  // We need an auth token first. So we login as admin to get token.
  final baseUrl = 'https://medical-app-tau-ten.vercel.app';
  final client = HttpClient();
  
  final loginReq = await client.postUrl(Uri.parse('$baseUrl/api/auth/login'));
  loginReq.headers.contentType = ContentType.json;
  loginReq.write(jsonEncode({
    'email': 'admin@medical.com',
    'password': 'Admin123456',
  }));
  final loginRes = await loginReq.close();
  final loginBody = await loginRes.transform(utf8.decoder).join();
  final token = jsonDecode(loginBody)['token'];

  // Now create appointment
  final apptReq = await client.postUrl(Uri.parse('$baseUrl/api/appointments'));
  apptReq.headers.contentType = ContentType.json;
  apptReq.headers.add('Authorization', 'Bearer $token');
  apptReq.write(jsonEncode({
    'patientId': '6985fbba2285dda262640e94', // super admin user id as mock
    'doctorId': '6985fbba2285dda262640e94', // dummy
    'date': DateTime.now().add(Duration(days:1)).toIso8601String(),
    'status': 'PENDING'
  }));

  final apptRes = await apptReq.close();
  final apptBody = await apptRes.transform(utf8.decoder).join();
  print('Status: ${apptRes.statusCode}');
  print('Body: $apptBody');
}
