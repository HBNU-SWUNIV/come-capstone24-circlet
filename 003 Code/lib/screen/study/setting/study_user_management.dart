import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/components/components.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../dialog/dialog.dart';
import '../../../firebase/firebase_study.dart';
import '../../../firebase/firebase_user.dart';
import '../../../util/color.dart';
import '../../../util/font/font.dart';

class StudyUserManagement extends StatefulWidget {
  const StudyUserManagement({super.key});

  @override
  State<StudyUserManagement> createState() => _StudyUserManagementState();
}

class _StudyUserManagementState extends State<StudyUserManagement> {
  final ss = Get.put(StudyState());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(text: '스터디 유저 관리', onTap: (){Get.back();}),
      body: Padding(padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: ss.studyList[0]['studyUserList'].length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ss.studyList[0]['studyUserList'][index] ==  ss.studyList[0]['studyHostDocId']?
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, // 원형으로 설정
                                  color: grayColor2,
                                  border: Border.all(
                                    color: hintGrayColor,
                                    width: 1,
                                  ),
                                ),
                                width: 40,
                                height: 40,
                                child: ClipOval( // 이미지를 원형으로 자르기 위해 ClipOval 사용
                                  child: CachedNetworkImage(
                                    imageUrl: 'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${ss.studyList[0]['studyUserList'][index]}?alt=media',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0, // 오른쪽 하단에 위치
                                bottom: 0,
                                child: Container(
                                  width: 16, // 동그라미 크기
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.black, // 배경 색상
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.star, // 별 모양 아이콘
                                    color: Colors.white, // 아이콘 색상
                                    size: 12, // 아이콘 크기
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20,),
                          FutureBuilder<String>(
                            future: getUserNickname(ss.studyList[0]['studyUserList'][index]),
                            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text('로딩...');
                              } else if (snapshot.hasError) {
                                return Text('에러');
                              } else {
                                return Text(snapshot.data ?? '',style: f14bw400,);
                              }
                            },
                          ),
                        ],
                      ):
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // 원형으로 설정
                              color: grayColor2,
                              border: Border.all(
                                color: hintGrayColor,
                                width: 1,
                              ),
                            ),
                            width: 40,
                            height: 40,
                            child: ClipOval( // 이미지를 원형으로 자르기 위해 ClipOval 사용
                              child: CachedNetworkImage(
                                imageUrl: 'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${ss.studyList[0]['studyUserList'][index]}?alt=media',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          SizedBox(width: 20,),
                          FutureBuilder<String>(
                            future: getUserNickname(ss.studyList[0]['studyUserList'][index]),
                            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text('로딩...');
                              } else if (snapshot.hasError) {
                                return Text('에러');
                              } else {
                                return Text(snapshot.data ?? '',style: f14bw400,);
                              }
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: (){
                              showComponentDialog(context,'해당 유저를 스터디에서 추방하시겠습니까?.', () async {
                                await banStudyUser(ss.studyList[0]['studyUserList'][index]);
                                await getOneStudyList();
                                Get.back();
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: redColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10 ),
                                  child: Text('추방하기',style: f12w500,),
                                )),
                          )
                        ],
                      ),
                      const SizedBox(height: 10,)
                    ],
                  );
                }
            ))

          ],
        ),
      ),

    );
  }
}
