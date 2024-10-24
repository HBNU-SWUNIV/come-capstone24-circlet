import 'dart:async';

import 'package:circlet/screen/login_register/id_password_search/password_reset_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../components/components.dart';
import '../../../dialog/dialog.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';
import '../../../util/font/font.dart';

class PasswordSearchPage extends StatefulWidget {
  const PasswordSearchPage({super.key});

  @override
  State<PasswordSearchPage> createState() => _PasswordSearchPageState();
}

class _PasswordSearchPageState extends State<PasswordSearchPage> {
  final us = Get.put(UserState());
  bool _phoneAuth = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;
  late Timer _timer;
  int _start = 0;
  bool _isCodeSent = false;

  void startTimer() {
    _start = 120; /// 인증 유효 시간 120초
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer.cancel();
          print(_timer.isActive);
        });
      } else {
        _start--;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('비밀번호 찾기',
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
              Text('이메일',
                style: f17bw500,
              ),
              const SizedBox(height: 16,),
              TextFormBox(hintText: '이메일을 입력해주세요',
                  textController: emailController,
                  onTap: (){},
                  onChange: (v){
                    setState(() {
                    });
                  }),
              const SizedBox(
                height: 43,
              ),
              Text(
                '핸드폰 인증',
                style: f17bw500,
              ),
              const SizedBox(
                height: 17,
              ),
              suffixTextFormBox(
                hintText: '핸드폰 번호를 입력해주세요',
                textController: _phoneController,
                keyboardType: TextInputType.phone,
                onTap: () {
                  _verifyPhoneNumber();
                },
                onChange: (v) {
                  setState(() {});
                },
                isContainer: true,
                containerText: '인증요청',
                textStyle: f14bw300,
                backgroundColor: Color(0xffF3F3F3),
              ),
              const SizedBox(
                height: 15,
              ),
              suffixTextFormBox(
                hintText: '인증번호 6자리를 입력해주세요',
                textController: _otpController,
                onTap: () {},
                onChange: (v) {},
                suffixText: _isCodeSent ? '$_start 초' : '',
              ),
              const SizedBox(
                height: 9,
              ),
              Text(
                '* 회원가입시 입력한 핸드폰번호를 정확히 입력해 주시기 바랍니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xffABABAB),
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  _isCodeSent
                      ? _signInWithPhoneNumber()
                      : showOnlyConfirmDialog(
                      context, '핸드폰 인증', "인증요청을 눌러주세요.");
                  setState(() {
                  });
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: _isCodeSent == true
                          ? Color(0xff3648EB)
                          : Color(0xffEBEBEB),
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                    // 텍스트를 가운데에 위치시키기 위해 Center 위젯 추가
                    child: Text(
                      '인증확인',
                      style: TextStyle(
                          color: _isCodeSent == true
                              ? Color(0xffFFFFFF)
                              : Color(0xffABABAB),
                          fontSize: 18),
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

  /// 전화번호를 국제 형식으로 변환하는 함수, 예: '01012345678' -> '+82 1012345678'
  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return phoneNumber.replaceFirst('0', '+82 ');
    }
    return phoneNumber;
  }

  /// 전화번호 중복검사 및 파이어베이스 인증을 시작하는 함수
  void _verifyPhoneNumber() async {
    // 사용자 입력 전화번호 포멧팅
    String formattedPhoneNumber = _formatPhoneNumber(_phoneController.text);
    await registerPhoneDuplicate(formattedPhoneNumber);

    if(us.memberCheckPhone.value !='0') {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        // 잘못된 전화번호, SMS할당량 초과시 실패 이벤트
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = true;
          });
          startTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
      // 중복된 전화번호 일 경우
    }else{
      showOnlyConfirmDialog(context, '회원가입', "가입되어있지 않은 번호입니다.");

    }
  }
  void _signInWithPhoneNumber() async {
    ///타이머가 유효하다면
    if (_timer.isActive) {
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: _otpController.text,
        );
        final authCredential = await _auth.signInWithCredential(credential);
        if (authCredential.user != null) {
          _phoneAuth = true;
          _isCodeSent = false;
          us.registerPhone.value = _formatPhoneNumber(_phoneController.text);
          var pwSearchResult = await searchUserPw('${us.registerPhone.value}', emailController.text);

          print('결과는???${pwSearchResult}');
          print('null여부');
          print(pwSearchResult=='');

          if(pwSearchResult!=''){
            Get.to(()=>PasswordResetPage(), arguments: '${pwSearchResult}');
          }else{
            showConfirmTapDialog(context, '잘못된 이메일주소 입니다.', (){
              Get.back();
            });
          }


          setState(() {

          });
          await _auth.currentUser!.delete();
          _auth.signOut();
        }
      } on FirebaseAuthException catch (e) {
        // 인증이 실패한 경우
        setState(() {
          _phoneAuth = false;
        });
        showOnlyConfirmDialog(context, '인증번호', "인증번호가 일치하지 않습니다.");
        print('Error Log Phone Auth : ${e.message}');
      }
    } else {
      showOnlyConfirmDialog(context, '인증번호', "인증번호의 유효시간이 종료되었습니다.");
    }
  }
}

