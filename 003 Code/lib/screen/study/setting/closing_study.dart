import 'package:circlet/components/components.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/util/font/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../firebase/firebase_study.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';
import '../../../util/loadingScreen.dart';
import '../../main/bottom_navigator.dart';

class ClosingStudy extends StatefulWidget {
  const ClosingStudy({super.key});

  @override
  State<ClosingStudy> createState() => _ClosingStudyState();
}

class _ClosingStudyState extends State<ClosingStudy> {
  final us = Get.put(UserState());
  final ss = Get.put(StudyState());
  bool closeChecked = false; /// 스터디 폐쇄 text 옆 체크박스
  bool? cantCloseStudy; /// 스터디 폐쇄가 불가능하면 true, 가능하면 false
  bool _isLoading = false; /// 스터디 폐쇄 작업 끝날때 까지 로딩
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(text: '스터디 폐쇄하기', onTap: (){Get.back();}),
      body: Padding(padding: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: _isLoading
          ? LoadingScreen():Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('스터디를 폐쇄하면', style: f16bw700,),
          const SizedBox(height: 10,),
          Text('* 스터디 일정, 스터디 게시물에 대한 내용이 모두 사라지고 복구가 불가능합니다. ', style: f14bw400,),
          const SizedBox(height: 6,),
          Text('* 스터디 폐쇄는 스터디장 외에 스터디원이 단 한 명이라도 있다면, 폐쇄가 불가능합니다. ', style: f14bw400,),
          const SizedBox(height: 50,),
          Row(
            children: [
              GestureDetector(
                onTap: (){
                  closeChecked = !closeChecked;
                  setState(() {
                  });
                },
                child: SvgPicture.asset(
                  closeChecked
                      ? 'assets/icon/checked.svg'
                      : 'assets/icon/unchecked.svg',
                ),
              ),
              const SizedBox(width: 6,),
              Text('스터디를 폐쇄하겠습니다.',style: f14bw400,),
            ],
          ),
          const SizedBox(height: 6,),
          cantCloseStudy == true?Text('스터디 폐쇄가 불가능합니다. 다른 스터디원이 있는지 확인해주세요.', style: f12rw500,):SizedBox(),
        ],
      ),),
      bottomSheet: _isLoading?SizedBox():Padding(
        padding: const EdgeInsets.only(left: 13, right: 13, bottom: 40),
        child: GestureDetector(
          onTap: () async {
            /// 스터디 유저 리스트에 본인 1명만 있어야함.
            print('로당?${_isLoading}');

            if(_isLoading == false){
              if(ss.studyList[0]['studyUserList'].length == 1&&ss.studyList[0]['studyUserList'][0] == ss.studyList[0]['studyHostDocId']){
                cantCloseStudy = false;
                setState(() {
                  _isLoading = true;
                });
                await closeStudy(ss.studyList[0]['docId']).then((_){
                  getUserDetailList(us.userList[0]['docId']);
                  Get.back();
                  Get.back();
                  Get.back();
                  Get.to(()=>BottomNavigator());

                });
                setState(() {
                  _isLoading = false;
                });
              }else{
                cantCloseStudy = true;
              }

            }
            setState(() {

            });
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: closeChecked ? Color(0xff3648EB) : Color(0xffEBEBEB),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '폐쇄하기',
                style: TextStyle(
                    color: closeChecked?Color(0xffFFFFFF):Color(0xffABABAB),fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
