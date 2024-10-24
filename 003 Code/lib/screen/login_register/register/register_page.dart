import 'package:circlet/components/components.dart';
import 'package:circlet/dialog/dialog.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:circlet/screen/login_register/Interest_page.dart';
import 'package:circlet/screen/main/bottom_navigator.dart';
import 'package:circlet/util/color.dart';
import 'package:circlet/util/font/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../firebase/firebase_user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  static final storage = new FlutterSecureStorage();
  final us = Get.put(UserState());
  TextEditingController _emailCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();
  TextEditingController _checkPwCon = TextEditingController();
  TextEditingController _nickNameCon = TextEditingController();
  String validatePasswordText = '*비밀번호는 8~32 자의 영문, 숫자, 특수문자를 조합하여 설정해 주세요.';

  ///유효성 검사 여부
  bool emailValid = false;
  bool passwordValid = false;
  bool nicknameValid = false;

  bool emailEnable = false;
  bool nicknameEnable = false;

  bool visible = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyledAppBar(text: '회원가입',),
      body: Padding(
        padding:
        const EdgeInsets.only(top: 13, left: 13, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '이메일',
              style: f16gray800w500,
            ),
            const SizedBox(height: 4,),
            suffixTextFormBox2(
              hintText: '이메일을 입력해주세요',
              textController: _emailCon,
              enabled: !emailEnable,
              onTap: () async {
                validateEmail(_emailCon.text);
                if(emailEnable==false&&emailValid==true){
                  await registerEmailDuplicate(_emailCon.text);
                  us.memberCheckEmail.value == '1' ?
                  showConfirmTapDialog(context, '이미 사용 중인 이메일입니다.', () {
                    Get.back();
                    emailEnable = false;
                  })
                      :showConfirmTapDialog(context, '사용 가능한 이메일입니다.', () {
                    Get.back();
                    emailEnable = true;
                    setState(() {
                    });
                  });
                }else if(emailValid==false){
                  showConfirmTapDialog(context, '올바른 이메일을 입력해주세요.', () {
                    Get.back();
                    setState(() {
                    });
                  });

                }
                else{
                  showConfirmTapDialog(context, '이메일을 수정할 수 있습니다.', () {
                    Get.back();
                    emailEnable = false;
                    setState(() {
                    });
                  });
                }
              },
              onChange: (v) {
                setState(() {
                  validateEmail(_emailCon.text);
                });
              },
              containerText: emailEnable?'수정하기':'중복체크',

            ),


            SizedBox(
              height: 18,
            ),
            Text(
              '비밀번호',
              style: f16gray800w500,
            ),
            const SizedBox(height: 4,),
            TextFormBox(
                hintText: '비밀번호를 입력해주세요.',
                textController: _pwCon,
                onTap: () {},
                onChange: (v) {
                  passwordValid = validatePassword(v)
                      ? _checkPwCon.text ==
                      _pwCon.text
                      ? true
                      : false
                      : false;
                  setState(() {
                    validatePasswordText = passwordValid
                        ? '사용가능한 비밀번호 입니다.'
                        : '*비밀번호는 8~20 자의 영문, 숫자, 특수문자를 조합하여 설정해 주세요.';
                  });
                }),
            const SizedBox(
              height: 13,
            ),
            Text(
              '비밀번호 확인',
              style: f16gray800w500,
            ),
            const SizedBox(height: 4,),
            TextFormBox(
                hintText: '비밀번호를 입력해주세요.',
                textController: _checkPwCon,
                onTap: () {},
                onChange: (v) {
                  passwordValid = validatePassword(v)
                      ? _checkPwCon.text ==
                      _pwCon.text
                      ? true
                      : false
                      : false;
                  setState(() {
                    validatePasswordText = passwordValid
                        ? '사용가능한 비밀번호 입니다.'
                        : '*비밀번호는 8~32 자의 영문, 숫자, 특수문자를 조합하여 설정해 주세요.';
                  });
                }),
            const SizedBox(
              height: 8,
            ),
            Text(validatePasswordText, style: TextStyle(fontSize: 12, color: passwordValid ? Color(0xff0DD675) : Color(0xffABABAB)),
            ),
            const SizedBox(
              height: 13,
            ),
            Text(
              '닉네임',
              style: f16gray800w500,
            ),
            const SizedBox(height: 4,),
            suffixTextFormBox2(
              hintText: '2~8자 이내로 닉네임을 입력해주세요',
              textController: _nickNameCon,
              enabled: !nicknameEnable,
              onTap: () async {
                validateNickname(_nickNameCon.text);
                if(nicknameEnable==false&&nicknameValid==true){
                  await registerNicknameDuplicate(_nickNameCon.text);
                  us.memberCheckNickname.value == '1' ?
                  showConfirmTapDialog(context, '이미 사용 중인 닉네임입니다.', () {
                    Get.back();
                    nicknameEnable = false;
                  })
                      :showConfirmTapDialog(context, '사용 가능한 닉네임입니다.', () {
                    Get.back();
                    nicknameEnable = true;
                    setState(() {
                    });
                  });
                }else if(nicknameValid==false){
                  showConfirmTapDialog(context, '올바른 닉네임을 입력해주세요.', () {
                    Get.back();
                    setState(() {
                    });
                  });

                }
                else{
                  showConfirmTapDialog(context, '이메일을 수정할 수 있습니다.', () {
                    Get.back();
                    nicknameEnable = false;
                    setState(() {
                    });
                  });
                }
              },
              onChange: (v) {
                setState(() {
                  validateNickname(_nickNameCon.text);
                });
              },
              containerText: nicknameEnable?'수정하기':'중복체크',

            ),
          ],
        ),
      ),
      bottomSheet: GestureDetector(
        onTap: () async {
          us.memberCheckEmail == '0'&&us.memberCheckNickname == '0'&&passwordValid
              ? await firebaseRegister().then((_) async {
            await storage.write(key: 'email', value: _emailCon.text);
            await storage.write(key: 'pw', value: _pwCon.text);
            await Login(_emailCon.text, _pwCon.text);
          }
              )
              : showConfirmTapDialog(context, '회원가입에 실패했습니다.', () {Get.back(); });
          setState(() {});
        },
        child: Container(
          height: 70,
          decoration: BoxDecoration(
              color: us.memberCheckEmail == '0'&&us.memberCheckNickname == '0'&&passwordValid ? Color(0xff3648EB) : Color(0xffEBEBEB),
          ),
          child: Center(
            child: Text(
              '회원가입',
              style: TextStyle(color: us.memberCheckEmail == '0'&&us.memberCheckNickname == '0'&&passwordValid ? Color(0xffFFFFFF) : Color(0xffABABAB), fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  /// 회원가입 함수
  Future<void> firebaseRegister() async {
    CollectionReference userRef = FirebaseFirestore.instance.collection('user');
    CollectionReference userDetailRef = FirebaseFirestore.instance.collection('userDetail');
    try {
      /// 1. user 컬렉션에 유저 정보 추가
      DocumentReference userDoc = await userRef.add({
        'email': us.registerEmail.value,
        'docId': '',
        'password': us.registerPassword.value,
        'nickname': us.registerNickname.value,
        'phone': us.registerPhone.value,
        'createDate': '${DateTime.now()}',
        'token': '',
      });

      /// 2. docId 가져오기
      await userDoc.update({'docId': userDoc.id});
      us.userDocId.value = userDoc.id;

      /// 3. userDetail 컬렉션에 유저 상세 정보 추가
      DocumentReference userDetailDoc = await userDetailRef.add({
        'createDate': '${DateTime.now()}',
        'docId': '',
        'userId': us.userDocId.value,
        'interest': '',
        'techStack': '',
        'introduce': '',
        'gitUrl': '',
        'blogUrl': '',
        'signUpList': [],
        'studyList': [],
      });
      print('successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }

  ///이메일 유효성 검사
  bool validateEmail(String value) {
    String pattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';

    RegExp regExp = RegExp(pattern);
    return (regExp.hasMatch(value)) ? emailValid = true : emailValid = false;
  }

  /// 비밀번호 유효성검사 8자리 이상 20자리 이하 특수문자 포함
  bool validatePassword(String password) {
    // 비밀번호 유효성 검사에 사용할 정규식
    String pattern = r'^(?=.*?[A-Za-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,20}$';

    RegExp regExp = RegExp(pattern);
    return (regExp.hasMatch(password)) ? passwordValid = true : passwordValid =
    false;
  }

  ///닉네임 유효성 검사 2자리 이상 8자리 이하
  bool validateNickname(String nickname) {
    int minLength = 2;
    int maxLength = 8;
    return (nickname.length >= minLength && nickname.length <= maxLength) ?
    nicknameValid = true : nicknameValid = false;
  }
}
