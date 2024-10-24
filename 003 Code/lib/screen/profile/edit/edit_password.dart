import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:get/get_core/src/get_main.dart';

import '../../../components/components.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';
import '../../../util/color.dart';
import '../../../util/font/font.dart';
import '../../login_register/login/login_page.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({super.key});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  final us = Get.put(UserState());
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController checkPasswordController = TextEditingController();
  bool passwordVisible = false;
  bool checkPasswordVisible = false;
  bool isPasswordValid = false;///비밀번호 유효성 검사 여부
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('비밀번호 변경',
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
        body: Padding(
          padding: const EdgeInsets.only(top: 14, left: 12, right: 12,bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('현재 비밀번호', style: f15bw500,),
              const SizedBox(
                height: 6,
              ),
              suffixTextFormBox(
                hintText: '현재 비밀번호',
                textController: oldPasswordController,
                onTap: (){},
                isIcon: true,
                visible: passwordVisible,
                onpressed: (){
                  passwordVisible = !passwordVisible;
                  setState(() {});
                },
                onChange: (v){
                  setState(() {
                  });
                },
                isContainer: true,
                textStyle: f14w300,
                backgroundColor: mainColor,
              ),
              const SizedBox(
                height: 21,
              ),
              Text('새 비밀번호', style: f15bw500,),
              const SizedBox(
                height: 6,
              ),
              suffixTextFormBox(
                hintText: '새 비밀번호',
                textController: newPasswordController,
                onTap: (){},
                isIcon: true,
                visible: passwordVisible,
                onpressed: (){
                  passwordVisible = !passwordVisible;
                  setState(() {});
                },
                onChange: (v){
                  setState(() {
                    isPasswordValid = validatePassword(v)?checkPasswordController.text==newPasswordController.text?true:false:false;
                  });
                },
                isContainer: true,
                textStyle: f14w300,
                backgroundColor: mainColor,
              ),
              const SizedBox(
                height: 18,
              ),Text('새 비밀번호 확인', style: f15bw500,),
              const SizedBox(
                height: 6,
              ),
              suffixTextFormBox(
                hintText: '새 비밀번호 확인',
                textController: checkPasswordController,
                onTap: (){},
                isIcon: true,
                visible: checkPasswordVisible,
                onpressed: (){
                  checkPasswordVisible = !checkPasswordVisible;
                  setState(() {});
                },
                onChange: (v){
                  setState(() {
                    isPasswordValid = validatePassword(v)?checkPasswordController.text==newPasswordController.text?true:false:false;
                  });
                },
                isContainer: true,
                textStyle: f14w300,
                backgroundColor: mainColor,
              ),
              const SizedBox(
                height: 19,
              ),
              Text(
                '* 비밀번호는 6~32 자의 영문, 숫자를 조합하여 설정해 주세요.',
                style: f12w300HintGray,
                softWrap: true,
              ),
              Spacer(),
              GestureDetector(
                onTap: (){
                  if(isPasswordValid == true) updateUserPassword2(context,us.userList[0]['docId'], oldPasswordController.text,newPasswordController.text);
                  setState(() {
                  });

                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: isPasswordValid == true? Color(0xff3648EB):Color(0xffEBEBEB),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center( // 텍스트를 가운데에 위치시키기 위해 Center 위젯 추가
                    child: Text(
                      '변경하기',
                      style: TextStyle(
                          color: isPasswordValid == true? Color(0xffFFFFFF):Color(0xffABABAB)
                          ,fontSize: 18),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),

      ),
    );
  }
}
bool validatePassword(String password) {
  // 비밀번호 유효성 검사에 사용할 정규식
  String pattern = r'^(?=.*?[A-Za-z])(?=.*?[0-9]).{6,32}$';

  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(password);
}