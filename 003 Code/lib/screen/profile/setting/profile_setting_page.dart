import 'package:circlet/screen/login_register/login/login_page.dart';
import 'package:circlet/screen/profile/delete_user.dart';
import 'package:circlet/screen/profile/edit/edit_password.dart';
import 'package:circlet/screen/profile/edit/profile_edit_page.dart';
import 'package:circlet/util/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../util/font/font.dart';

class ProfileSettingPage extends StatefulWidget {
  const ProfileSettingPage({super.key});

  @override
  State<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  static final storage = new FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정',
          style: f22bw500,),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1), // Divider의 높이 설정
          child: Divider(
            color: Color(0xffEBEBEB), // Divider의 색상 설정
            height: 1, // Divider의 높이 설정
            thickness: 1, // Divider의 두께 설정
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top:18, left: 20, right: 20,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('계정 관리', style: f20bw500,),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (){
                    Get.to(()=>ProfileEditPage());
                  },
                  child: Row(
                    children: [
                      Text('프로필 변경', style: f15bw400,),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: blackColor, size: 17,),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (){
                    Get.to(()=>EditPassword());
                  },
                  child: Row(
                    children: [
                      Text('비밀번호 변경', style: f15bw400,),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: blackColor, size: 17,),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async{
                    await storage.deleteAll();
                    Get.offAll(()=>LoginPage());
                  },
                  child: Row(
                    children: [
                      Text('로그아웃', style: f15bw400,),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: blackColor, size: 17,),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (){
                    Get.to(()=>DeleteUser());
                  },
                  child: Row(
                    children: [
                      Text('회원탈퇴', style: f15bw400,),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: blackColor, size: 17,),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          Divider(
            thickness: 10,
            color: Color(0xffF4F4F4),
          ),
          Padding(
            padding: EdgeInsets.only(top:15, left: 20, right: 20,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('정보', style: f20bw500,),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (){
                    //Get.to(()=>ProfileEditPage());
                  },
                  child: Row(
                    children: [
                      Text('버전', style: f15bw400,),
                      Spacer(),
                      Text('v 0.1', style: f15bw700,),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (){
                    Get.to(()=>EditPassword());
                  },
                  child: Row(
                    children: [
                      Text('약관 및 정책', style: f15bw400,),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: blackColor, size: 17,),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (){
                    print('1111');
                  },
                  child: Row(
                    children: [
                      Text('고객센터', style: f15bw400,),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: blackColor, size: 17,),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
