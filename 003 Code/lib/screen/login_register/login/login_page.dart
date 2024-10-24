
import 'dart:io';

import 'package:circlet/components/components.dart';
import 'package:circlet/dialog/dialog.dart';
import 'package:circlet/screen/login_register/id_password_search/id_search_page.dart';
import 'package:circlet/screen/login_register/id_password_search/password_search_page.dart';
import 'package:circlet/screen/login_register/register/phone_auth.dart';
import 'package:circlet/screen/main/bottom_navigator.dart';
import 'package:circlet/util/color.dart';
import 'package:circlet/util/font/font.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../app/notification/firebase_cloud_messaging.dart';
import '../../../app/notification/local_notification_setting.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final us = Get.put(UserState());

  /// 자동 로그인
  static final storage = new FlutterSecureStorage();

  /// text Con
  TextEditingController _emailCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();
  bool passwordVisible = false;

    @override
  void initState() {
    /// Fcm
    _requestPermissions();
    LocalNotifyCation().initializeNotification();
    FCM().setNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){FocusScope.of(context).unfocus();},
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(child: Text('Steady', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'NotoSans'),),),
            Center(child: Text('공부하며 머무르는 공간', style: f15bw400),),
            const SizedBox(height: 50,),
            Text('이메일', style: f15bw500,),
            const SizedBox(height: 6,),
            TextFormBox(
                hintText: '이메일을 입력해주세요.',
                textController: _emailCon,
                onTap: (){},
                onChange: (v){
                  setState(() {
                  });
                }),
            const SizedBox(
              height: 10,
            ),
            Text('비밀번호', style: f15bw500,),
            const SizedBox(
              height: 6,
            ),
            suffixTextFormBox(
              hintText: '비번번호를 입력해주세요.',
              textController: _pwCon,
              onTap: (){},
              isIcon: true,
              visible: passwordVisible,
              onpressed: (){
                passwordVisible = !passwordVisible;
                setState(() {});
              },
              onChange: (v){setState(() {});},
              isContainer: true,
              textStyle: f14w300,
              backgroundColor: mainColor,
            ),
            const SizedBox(height: 30,),
            GestureDetector(
              onTap: () async {
                await FirstLogin(_emailCon.text, _pwCon.text);
                if(us.userList.length!=0){
                  print('자동 로그인 저장');
                  await storage.write(key: 'email', value: _emailCon.text);
                  await storage.write(key: 'pw', value: _pwCon.text);
                  await Login(_emailCon.text, _pwCon.text);
                }
                else{
                  showConfirmTapDialog(context, '아이디 또는 비밀번호가 일치하지 않습니다', () {
                    Get.back();
                  });
                }
              },
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                    color: Color(0xff000000),
                    borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    '로그인',
                    style: f24w500,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  Get.to(PhoneAuth());

                });
              },
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                    color: Color(0xfffffff),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: blackColor,
                      width: 1,
                )
                ),
                child: Center(child: Text('회원가입', style: f24bw500,),),
              ),
            ),
            const SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){Get.to(IdSearchPage());},
                  child: Text('아이디 찾기',style: f14bw400,),
                ),
                Text(' | ', style: f14bw400),
                GestureDetector(
                  onTap: (){ Get.to(PasswordSearchPage());},
                  child: Text('비밀번호 찾기',style: f14bw400),
                ),
              ],
            )
          ],
          ),
        ),
      ),
    );
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
}
