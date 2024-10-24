import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/util/font/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../components/components.dart';
import '../../../../util/color.dart';
import '../../../provider/study_state.dart';
import '../../../provider/user_state.dart';
import '../../../util/loadingScreen.dart';
import '../../study/study_home/study_home_page.dart';
class PopularStudyPage extends StatefulWidget{
  @override
  State<PopularStudyPage> createState() => _PopularStudyPage();

}

class _PopularStudyPage extends State<PopularStudyPage>{
  StudyState ss = Get.put(StudyState());
  final us = Get.put(UserState());
  bool isLikeButtonDisabled = false;

  /// 좋아요 함수
  Future<void> toggleLike(String docId, bool like) async {
    if (isLikeButtonDisabled) return;
    isLikeButtonDisabled = true;
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('study').doc(docId);

      DocumentSnapshot docSnapshot = await docRef.get();

      if (like) {
        await docRef.update({
          'likeList': FieldValue.arrayRemove([us.userList[0]['docId']]),
        });
      } else {
        await docRef.update({
          'likeList': FieldValue.arrayUnion([us.userList[0]['docId']]),
        });
      }
      setState(() {
        isLikeButtonDisabled = false;
      });
    }
    catch (error) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('인기 스터디', style: f22bw700),
        ),
        body: SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: ss.popularMoreStudyList.length,
            itemBuilder: (context, index) {
              var isLiked = ss.popularMoreStudyList[index]['likeList']
                  .contains(us.userList[0]['docId']);
              return Padding(
                padding: EdgeInsets.only(top: 17),
                child: GestureDetector(
                  onTap: () {
                    List list = ss.popularMoreStudyList.value;
                    ss.studyList.clear();
                    ss.studyList.value = [list[index]];
                    Get.to(() => StudyHomePage())?.then((result){
                      setState(() {
                      });
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                      Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffF1F1F1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Color(0xffF5F5F5),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Color(0xffDDDDDD),
                          blurRadius: 10,
                          offset: Offset(0, 1),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    height: 95,
                    child: Row(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(
                                left: 10, right: 10),
                            child: Container(
                              width: 75,
                              height: 70,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Stack(
                                  fit: StackFit.expand,

                                  /// 이미지가 짤리는걸 막아줌
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl:
                                      'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/studyImage%2F${ss
                                          .popularMoreStudyList[index]['docId']}?alt=media',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Center(
                                              child: LoadingScreen()),
                                      errorWidget: (context, url,
                                          error) => Icon(Icons.error),
                                    ),
                                    Positioned(
                                        left: 4,
                                        /// 왼쪽에서의 위치 조정 값이 커질수록 오른쪽으로 이동
                                        bottom: 4,
                                        /// 아래에서의 위치 조정 값이 커질수록 위로 이동
                                        child: GestureDetector(
                                          onTap: () async {
                                            await toggleLike(ss
                                                .popularMoreStudyList[index]['docId'],
                                                isLiked);
                                            setState(() {
                                              if (isLiked) {
                                                ss.popularMoreStudyList[index]['likeList']
                                                    .remove(us.userList[0]['docId']);
                                              } else {
                                                ss.popularMoreStudyList[index]['likeList']
                                                    .add(us.userList[0]['docId']);
                                              }
                                            });
                                          },
                                          child: SvgPicture.asset(
                                              isLiked
                                                  ? 'assets/icon/Heart.svg'
                                                  : 'assets/icon/whiteEmptyHeart.svg',
                                              width: 25, height: 25),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            )

                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Wrap(
                                  children:
                                  ss.popularMoreStudyList[index]['interest']
                                      .map<Widget>(
                                          (interests) {
                                        Color? backgroundColors =
                                        interestBackgroundColor[
                                        interests];
                                        Color? interestTextColors =
                                        interestTextColor[interests];
                                        return Padding(
                                            padding:
                                            EdgeInsets.only(right: 7),
                                            child: Container(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5),
                                              decoration: BoxDecoration(
                                                color: backgroundColors,
                                                borderRadius:
                                                BorderRadius.circular(
                                                    30),
                                              ),
                                              child: Text(interests,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                      interestTextColors,
                                                      fontFamily:
                                                      'NotoSans',
                                                      fontWeight:
                                                      FontWeight
                                                          .w700)),
                                            ));
                                      }).toList()),
                              const SizedBox(height: 6),
                              Text(
                                ss.popularMoreStudyList[index][
                                'studyName'], // 스터디 이름
                                style: f14bw700,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10, right: 29),
                                child: Row(
                                  children: [
                                    Text(
                                        '${ss
                                            .popularMoreStudyList[index]['sido']} ${ss
                                            .popularMoreStudyList[index]['gungu']}',
                                        style: f10w400DeppGray),
                                    Spacer(),
                                    Text(
                                        '멤버 ${ss
                                            .popularMoreStudyList[index]['studyUserList']
                                            .length}',
                                        style: f10w400DeppGray),
                                    Spacer(),
                                    Text(
                                        '좋아요 ${(ss
                                            .popularMoreStudyList[index]['likeList'] as List)
                                            .length}',
                                        style: f10w400DeppGray),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
    );
  }

}