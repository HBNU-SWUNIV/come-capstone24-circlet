import 'dart:io';

import 'package:circlet/screen/login_register/login/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../app/notification/firebase_cloud_messaging.dart';
import '../app/notification/local_notification_setting.dart';
import '../firebase/firebase_user.dart';
import '../provider/user_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static final storage = new FlutterSecureStorage();

  @override
  void initState() {
    _requestPermissions();
    LocalNotifyCation().initializeNotification();
    FCM().setNotifications();
    /// 스토리지에 저장된 이메일, 비밀번호를 읽어와서 정보가 있다면 로그인 함수 호출, 없으면 로그인 페이지로 이동
    Future.delayed(Duration.zero,()async{
      String? email = await storage.read(key: 'email');
      String? pw = await storage.read(key: 'pw');
      if(email != null && pw != null){
        await Login(email!, pw!);
      }else{
        Get.to(()=>LoginPage());
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold();
  }
  /// 알림 권한 여부 설정
  void _requestPermissions() {
    ///fcm
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    /// 안드로이드 일때
    if (Platform.isAndroid) {
      FirebaseMessaging.instance.requestPermission(
        badge: true,
        alert: true,
        sound: true,
      );
      var channel = const AndroidNotificationChannel(
        'steadyFcm', 'steadyFcm',
        description: 'this is steadyFcm channel', // description
        importance: Importance.high,
      );
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    /// Ios 일 때
    else {
      print('ios');
      // flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      //   alert: true,
      //   badge: true,
      //   sound: true,
      // );
    }
  }

  // Future<void> initPlatformState() async {
  //   try {
  //     jailbroken = await FlutterJailbreakDetection.jailbroken;
  //   } on PlatformException {
  //     jailbroken = true;
  //   }
  //   if (!mounted) return;
  //   setState(() {});
  // }

}