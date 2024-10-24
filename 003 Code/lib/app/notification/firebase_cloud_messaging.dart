import 'dart:async';
import 'dart:convert';

import 'package:circlet/provider/user_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class FCM {
  final us = Get.put(UserState());
  final _firebaseMessaging = FirebaseMessaging.instance;
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  var channel = const AndroidNotificationChannel(
    'steadyFcm', 'steadyFcm',
    description: 'this is fcm channel', // description
    importance: Importance.high,
  );
  setNotifications() {
    print('Token???');
    foregroundNotification();
    backgroundNotification();
    terminateNotification();
    final token = _firebaseMessaging.getToken().then((value){{
      print('Token: $value');
      us.token.value = '${value}';
    }});
    print('--');
  }
  ///버튼 눌렀을 때 포그라운드
  foregroundNotification() {
    const String darwinNotificationCategoryPlain = 'steadyFcm';

    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          'id',
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    );

    ///IOS 알림
    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('111');
      flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title,
          message.notification?.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: iosNotificationDetails
          ),
          payload: '${message?.data}');
      print('eeeee');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message);
    });
  }

  backgroundNotification() async {
    FirebaseMessaging.onMessageOpenedApp.listen(
          (message) async {
        Map<String, dynamic> dataMap = json.decode('${message.data}');
        // print('ㄴㄹㅁㄴㅁㅁㅁㅁ : ${message.notification!.title!}');
        // print('ㄴㄹㅁㄴㅁㅁㅁㅁ22 : ${message.notification!.body!}');
        // print('ㄴㄹㅁㄴㅁㅁㅁㅁ33 : ${dataMap['name']}');

        // up.fcmDocId = '${message.data['docId']}';
        titleCtlr.sink.add(message.notification!.title!);
        bodyCtlr.sink.add(message.notification!.body!);
      },
    );
  }
  //
  terminateNotification() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      //
      // print('ㅋㅋㅋㅋㅋ : ${initialMessage.notification!.title!}');
      // print('ㅋㅋㅋㅋㅋㅋ22 : ${initialMessage.notification!.body!}');
      // print('ㅋㅋㅋㅋㅋㅋ33 : ${initialMessage.data['name']}');

      titleCtlr.sink.add(initialMessage.notification!.title!);
      bodyCtlr.sink.add(initialMessage.notification!.body!);
    }
  }
  dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }
}