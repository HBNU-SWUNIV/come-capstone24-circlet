import 'dart:async';

import 'package:circlet/components/components.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:circlet/screen/login_register/register/register_page.dart';
import 'package:circlet/util/color.dart';
import 'package:circlet/util/font/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../dialog/dialog.dart';
import '../../../firebase/firebase_user.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final us = Get.put(UserState());
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;
  bool _phoneAuth = false;
  late Timer _timer;
  int _start = 0;
  bool _isCodeSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _start = 120; // 인증 유효 시간 120초
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
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: StyledAppBar(text: '핸드폰인증',),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 13, left: 13, right: 13, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '핸드폰 인증',
                style: f15bw500,
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
                '* 본인명의 핸드폰번호를 정확히 입력해 주시기 바랍니다.',
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
                      : showOnlyConfirmDialog(context, '핸드폰 인증', "인증요청을 눌러주세요.");
                  setState(() {
                  });
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: _isCodeSent == true ? Color(0xff3648EB) : Color(0xffEBEBEB),
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                    child: Text(
                      '인증확인', style: TextStyle(color: _isCodeSent == true ? Color(0xffFFFFFF) : Color(0xffABABAB), fontSize: 18),
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

    if(us.memberCheckPhone.value =='0') {
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
      showOnlyConfirmDialog(context, '중복된 번호', "이미 가입된 번호입니다.");

    }
  }
  void _signInWithPhoneNumber() async {
    //타이머가 유효하다면
    if (_timer.isActive) {
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: _otpController.text,
        );
        final authCredential = await _auth.signInWithCredential(credential);
        if (authCredential.user != null) {
          setState(() {
            _phoneAuth = true;
            _isCodeSent = false;
            us.registerPhone.value = _formatPhoneNumber(_phoneController.text);
            showOnlyConfirmTapDialog(context, '인증완료', "인증이 완료되었습니다.", () {
              Get.to(() => RegisterPage())?.then((value) {
                Get.back();
                _start = 0;
                _phoneController.clear();
                _otpController.clear();
                _timer.cancel();
              });
            });
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
