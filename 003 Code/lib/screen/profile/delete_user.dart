import 'package:circlet/provider/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../components/components.dart';
import '../../firebase/firebase_user.dart';
import '../../util/font/font.dart';
import '../../util/loadingScreen.dart';
import '../login_register/login/login_page.dart';

class DeleteUser extends StatefulWidget {
  const DeleteUser({super.key});

  @override
  State<DeleteUser> createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> {
  final us = Get.put(UserState());
  bool deleteChecked = false; /// 회원탈퇴 확인용 체크박스
  bool? cantDeleteUser = false; /// 회원탈퇴가 불가능하면 true, 가능하면 false
  bool _isLoading = false;

  static final storage = new FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(text: '회원탈퇴', onTap: (){Get.back();}),
      body: Padding(padding: EdgeInsets.only(top: 20, left: 20, right: 20),
        child: _isLoading
            ? LoadingScreen():Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('회원탈퇴 안내사항', style: f16bw700,),
            const SizedBox(height: 10,),
            Text('* 회원탈퇴는 가입 중인 스터디가 없어야 가능합니다.', style: f14bw400,),
            const SizedBox(height: 6,),
            Text('* 스테디 서비스 내에서 작성한 콘텐츠를 삭제하거나 수정할 수 없게됩니다. 삭제를 원하시면 회원탈퇴전에 지우거나 수정하세요. ', style: f14bw400,),
            const SizedBox(height: 50,),
            Row(
              children: [
                GestureDetector(
                  onTap: (){
                    deleteChecked = !deleteChecked;
                    setState(() {
                    });
                  },
                  child: SvgPicture.asset(
                    deleteChecked
                        ? 'assets/icon/checked.svg'
                        : 'assets/icon/unchecked.svg',
                  ),
                ),
                const SizedBox(width: 6,),
                Text('스테디 계정을 삭제하겠습니다.',style: f14bw400,),
              ],
            ),
            const SizedBox(height: 6,),
            cantDeleteUser == true?Text('회원탈퇴 이전에 가입된 스터디가 있는지 확인해주세요.', style: f12rw500,):SizedBox(),
          ],
        ),),
      bottomSheet: _isLoading?SizedBox():Padding(
        padding: const EdgeInsets.only(left: 13, right: 13, bottom: 40),
        child: GestureDetector(
          onTap: () async {
            print('로당?${_isLoading}');
            if(_isLoading == false){
              if(us.userDetailList[0]['studyList'].length == 0){
                cantDeleteUser = false;
                setState(() {
                  _isLoading = true;
                });
                await deleteUser(us.userList[0]['docId']).then((_) async {
                  await storage.deleteAll();
                  Get.offAll(()=>LoginPage());
                });
                _isLoading = false;

              }else{
                cantDeleteUser = true;
              }

              }
            setState(() {

            });
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: deleteChecked ? Colors.black : Color(0xffEBEBEB),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '탈퇴하기',
                style: TextStyle(
                    color: deleteChecked?Color(0xffFFFFFF):Color(0xffABABAB),fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
