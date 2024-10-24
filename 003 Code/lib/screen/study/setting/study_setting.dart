import 'package:circlet/components/components.dart';
import 'package:circlet/screen/study/setting/closing_study.dart';
import 'package:circlet/screen/study/setting/study_user_management.dart';
import 'package:circlet/screen/study/setting/transfer_study.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/color.dart';
import '../../../util/font/font.dart';

class StudySetting extends StatefulWidget {
  const StudySetting({super.key});

  @override
  State<StudySetting> createState() => _StudySettingState();
}

class _StudySettingState extends State<StudySetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(text: '스터디 설정', onTap: (){Get.back();}),
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
                GestureDetector(
                  onTap: (){
                    Get.to(StudyUserManagement());
                  },
                  child: Row(
                    children: [
                      Text('스터디 유저 관리', style: f15bw400,),
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
                    Get.to(TransferStudy());
                  },
                  child: Row(
                    children: [
                      Text('스터디 양도하기', style: f15bw400,),
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
                    Get.to(()=>ClosingStudy());
                  },
                  child: Row(
                    children: [
                      Text('스터디 폐쇄하기', style: f15bw400,),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: blackColor, size: 17,),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
