import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/components/components.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/util/font/font.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../firebase/firebase_study.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';
import '../../../util/loadingScreen.dart';

class StudyRegisterPage extends StatefulWidget {
  @override
  State<StudyRegisterPage> createState() => _StudyRegisterPageState();

  Map<String, dynamic> studyInfo;

  StudyRegisterPage({required this.studyInfo});
}

class _StudyRegisterPageState extends State<StudyRegisterPage> {
  bool showText = false;
  final ss = Get.put(StudyState());
  bool _isLoading = true;

  @override
  void initState() {
    print('initState------');
    Future.delayed(Duration.zero, () async {
      print('------------');
      print(ss.studyList[0]['signUpList']);
     await getSignUpListMap(ss.studyList[0]['signUpList']);

      _isLoading = false;
     print('----dhddd${ss.signUpList}');
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(
        text: '가입 신청 관리',
        onTap: (){
          Get.back();
        },
      ),
      body: _isLoading
          ? Center(child: LoadingScreen())
          : ListView.builder(
        itemCount: ss.signUpList.length,
        itemBuilder: (context, index) {
          var user = ss.signUpList[index]['docId'];
          return GestureDetector(
            onTap: () {
              setState(() {
                showText = !showText;
              });
            },
            child: Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffD0D0D0)))),
              child: Padding(
                padding: EdgeInsets.only(left: 21, right: 24, bottom: 12, top: 20),
                child: Row(
                  children: [
                    Container(
                      width: 53,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffCDCDCD)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: CachedNetworkImage(
                        imageUrl:
                        'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${user}?alt=media',
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Center(child: LoadingScreen()),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${ss.signUpList[index]['nickname']}', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    Spacer(),
                    Container(
                      width: 120,
                      height: 60,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await acceptUser(index);
                            },
                            child: Container(
                              width: 45,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xff0DD675),
                              ),
                              child: Center(
                                child: Text(
                                  '수락',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () async {
                              await rejectUser(user);
                            },
                            child: Container(
                              width: 45,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xffFF4040),
                              ),
                              child: Center(
                                child: Text(
                                  '거절',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> acceptUser(int index) async {
    final us = Get.put(UserState());
    final ss = Get.put(StudyState());
    var user = ss.signUpList[index]['docId'];
    await getOtherUserDetailList(ss.signUpList[index]['docId']);
    var studyRef = FirebaseFirestore.instance.collection('study').doc(widget.studyInfo['docId']);
    var userDetailRef = FirebaseFirestore.instance.collection('userDetail').doc(us.otherUserDetailList[0]['docId']);

    print('형태??');
    print(user);
    print([user]);
    print(ss.studyList[0]['docId']);
    print([ss.studyList[0]['docId']]);
    await studyRef.update({
      'signUpList': FieldValue.arrayRemove([user]),
      'studyUserList': FieldValue.arrayUnion([user]),
    });
    await userDetailRef.update({
      'signUpList': FieldValue.arrayRemove([ss.studyList[0]['docId']]),
      'studyList': FieldValue.arrayUnion([ss.studyList[0]['docId']]),
    });
    await getOneStudyList();

    setState(() {
      ss.signUpList.removeAt(index);
    });
  }

  Future<void> rejectUser(String user) async {
    var studyRef = FirebaseFirestore.instance.collection('study').doc(widget.studyInfo['docId']);

    // signUpList에서 사용자 이름 제거
    await studyRef.update({
      'signUpList': FieldValue.arrayRemove([user]),
    });

    setState(() {
      widget.studyInfo['signUpList'].remove(user);
    });
  }
}
