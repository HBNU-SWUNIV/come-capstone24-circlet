import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
class LocalNotifyCation {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //initialized
  Future<void> initializeNotification() async {
    tz.initializeTimeZones();

    ///IOS
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  /// 안드로이드
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher

    final InitializationSettings initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  Future onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    print('test notification print');
  }




  // 알림을 보내는 메서드
  Future<void> sendNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', // 채널 ID
      'your_channel_name', // 채널 이름
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // 알림 ID (고유해야 함)
      '스터디 가입 신청', // 알림 제목
      '스터디에 가입 신청한 유저가 있습니다.', // 알림 내용
      platformChannelSpecifics, // 알림 세부 정보
      payload: jsonEncode({'name': 'first'}), // 알림 선택 시 전달할 페이로드
    );
  }

  /// foreground 상태
  void selectNotification(NotificationResponse payload) async {
    // print('notification payload333333: ${payload.payload}');
    Map<String, dynamic> data = jsonDecode('${payload.payload}');
    switch (data['name']) {
      case 'first' :
        break;
    }
  }
}

