import 'package:circlet/screen/login_register/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../components/components.dart';
import '../../../dialog/dialog.dart';
import '../../../firebase/firebase_user.dart';
import '../../../util/color.dart';
import '../../../util/font/font.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController checkPasswordController = TextEditingController();
  late String docId;
  bool passwordVisible = false;
  bool checkPasswordVisible = false;
  bool isPasswordValid = false;///비밀번호 유효성 검사 여부

  @override
  void initState() {
    docId = Get.arguments;
    print('docId??${docId}');
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('비밀번호 재설정',
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
          padding: const EdgeInsets.only(top: 20, left: 12, right: 12,bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('새로운 비밀번호를 입력해주세요.', style: f20bw700,),
              const SizedBox(
                height: 43,
              ),
              Text('비밀번호', style: f15bw500,),
              const SizedBox(
                height: 9,
              ),
              suffixTextFormBox(
                hintText: '새 비밀번호',
                textController: passwordController,
                onTap: (){},
                isIcon: true,
                visible: passwordVisible,
                onpressed: (){
                  passwordVisible = !passwordVisible;
                  setState(() {});
                },
                onChange: (v){
                  setState(() {
                    isPasswordValid = validatePassword(v)?checkPasswordController.text==passwordController.text?true:false:false;
                  });
                },
                isContainer: true,
                textStyle: f14w300,
                backgroundColor: mainColor,
              ),
              const SizedBox(
                height: 17,
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
                    isPasswordValid = validatePassword(v)?checkPasswordController.text==passwordController.text?true:false:false;
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
                '* 비밀번호는 8~32 자의 영문, 숫자, 특수문자를 조합하여 설정해 주세요.',
                style: f12w300HintGray,
                softWrap: true,
              ),
              Text(
                '* 다른사이트에서 사용하는 것과 동일하거나 쉬운 비밀번호는 사용하지 마세요. ',
                style: f12w300HintGray,
                softWrap: true,
              ),Text(
                '* 안전한 계정 사용을 위해 비밀번호는 주기적으로 변경해 주세요.',
                style: f12w300HintGray,
                softWrap: true,
              ),
              Spacer(),
              GestureDetector(
                onTap: () async {
                  if(isPasswordValid == true){
                    await updateUserPassword(docId, passwordController.text);
                    showConfirmTapDialog(context, '비밀번호가 성공적으로 변경되었습니다.', (){
                      Get.offAll(LoginPage());
                    });

                  }

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
                      '비밀번호 재설정하기',
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
  String pattern = r'^(?=.*?[A-Za-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,32}$';

  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(password);
}