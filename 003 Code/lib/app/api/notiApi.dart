import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> sendNotification(String token, String title, String body) async {
  final url = Uri.parse('http://localhost:1234/sendNotification');

  final data = {
    'token': token,    /// 클라이언트 토큰
    'title': title,    /// 알림 제목
    'body': body       /// 알림 본문
  };
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}