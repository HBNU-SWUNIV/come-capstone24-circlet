import 'dart:io';
import 'package:circlet/screen/study/setting/study_setting.dart';
import 'package:circlet/screen/study/study_home/study_home_tap_page.dart';
import 'package:circlet/screen/study/post/study_post_tap_page.dart';
import 'package:circlet/screen/study/register/study_register_page.dart';
import 'package:circlet/util/font/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../dialog/dialog.dart';
import '../../../firebase/firebase_study.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/study_state.dart';
import '../../../provider/user_state.dart';
import '../schedule/show_schedule.dart';

class StudyHomePage extends StatefulWidget {
  StudyHomePage({super.key});

  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // tab 컨트롤러
  final ScrollController scrollController = ScrollController();
  int _selectedCategoryIndex = 0; // 게시판에 있는 카테고리 인덱스
  String join = '스터디 가입하기'; // 스터디에 가입이 되어있지 않으면 스터디 가입하기 가입신청을 하면 대기중으로
  List<String> boardName = [
    '공지사항',
    '가입인사',
    '자유',
    '질문',
    '모임후기',
    '자료실'
  ]; // 카테고리 이름

  bool isLoading = true;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  final int pageSize = 10;
  UserState us = Get.find<UserState>();
  bool isJoined = false;
  bool signUp = false;
  FirebaseStorage storage =
  FirebaseStorage.instanceFor(bucket: 'gs://circlet-9c202.appspot.com');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String image = '';
  Map<String, String> userImageUrlMap = {};
  final ss = Get.put(StudyState());
  bool isLikeButtonDisabled = false;
  bool isJoinButtonDisabled = false;
  bool isHost = false;
  int index = 0; // 게시판에 있는 카테고리 인덱스


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 탭 3개
    _tabController.addListener(_handleTabSelection); // 핸들러 추가

    print('studyList??${ss.studyList.value}');
    if (ss.studyList[0]['studyUserList'] != null &&
        ss.studyList[0]['studyUserList'].contains(us.userList[0]['docId'])) {
      isJoined = true; // 스터디의 유저리스트에 현재 로그인된 사용자의 아이디가 있다면 가입된 상태
    }

    if (ss.studyList[0]['signUpList'] != null &&
        ss.studyList[0]['signUpList'].contains(us.userList[0]['docId'])) {
      signUp = true;
    }

    if(ss.studyList[0]['studyHost'] == us.userList[0]['nickname']){
      isHost = true;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // 핸들러 제거
    _tabController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }


  void _handleTabSelection() {
    setState(() {
      if(_tabController.index != 1){
        index = 0;
      }
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoading || !hasMore) return;
    final thresholdReached = scrollController.position.extentAfter < 200;

    if (thresholdReached) {}
  }

  void _selectTab(int index) {
    _tabController.animateTo(index);
  }

  void _onCategoryTap(int index) {
    // 해당하는 카테고리 화면이 나오게 하기 위해서
    setState(() {
      _selectedCategoryIndex =
          index; //_onCategoryTab이 _selectedCategoryIndex를 변환
    });
  }
  /// 가입하기 다이얼로그
  void _showJoinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("가입 확인"),
          content: Text("이 스터디에 가입하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "취소",
                style: TextStyle(color: Colors.blue), // 텍스트 색상 지정
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "확인",
                style: TextStyle(color: Colors.blue), // 텍스트 색상 지정
              ),
              onPressed: () async {
                final firestore = FirebaseFirestore.instance;

                try {
                  final docRef = firestore
                      .collection('study')
                      .doc(ss.studyList[0]['docId']);
                  await docRef.update({
                    'signUpList':
                    FieldValue.arrayUnion([us.userList[0]['docId']])
                  });
                  final userRef = firestore
                      .collection('userDetail')
                      .doc(us.userDetailList[0]['docId']);
                  await userRef.update({
                    'signUpList':
                    FieldValue.arrayUnion([ss.studyList[0]['docId']])
                  });
                } catch (e) {
                  print(e);
                }
                setState(() {
                  signUp = true;
                  ss.studyList[0]['signUpList']
                      .add(us.userList[0]['docId']);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  /// 가입취소 다이얼로그
  void _showJoinCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("가입 취소"),
          content: Text("이 스터디에 가입신청을 취소하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "취소",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "확인",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () async {
                final firestore = FirebaseFirestore.instance;

                try {
                  final docRef = firestore
                      .collection('study')
                      .doc(ss.studyList[0]['docId']);
                  await docRef.update({
                    'signUpList':
                    FieldValue.arrayRemove([us.userList[0]['docId']])
                  });

                  final userRef = firestore
                      .collection('userDetail')
                      .doc(us.userDetailList[0]['docId']); /// user디테일 컬렉션의 studyList에다가 값 추가
                  await userRef.update({
                    'signUpList':
                    FieldValue.arrayRemove([ss.studyList[0]['docId']])
                  });

                } catch (e) {
                  print(e);
                }
                setState(() {
                  signUp = false;
                  ss.studyList[0]['signUpList']
                      .remove(us.userList[0]['docId']);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showStudyReportDialog() {
    TextEditingController reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('스터디 신고하기'),
          content: Container(
            width: double.infinity,
            height: 200,
            child: TextField(
              controller: reportController,
              enableInteractiveSelection: true,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '신고할 사유를 입력해주세요.' '\n' '\n' '\n' '\n',
                hintStyle: f14gw500,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('취소', style: f12bw500),
            ),
            TextButton(
              onPressed: () async {
                ///  reportReason 가져오기
                String reportReason = reportController.text;

                /// 문서 추가
                if (reportReason.isNotEmpty) {
                  String docId = FirebaseFirestore.instance
                      .collection('studyReport')
                      .doc()
                      .id; /// 문서 ID 생성
                  DateTime createdAt = DateTime.now(); // 신고 시간

                  await FirebaseFirestore.instance
                      .collection('studyReport')
                      .doc(docId) /// 지정된 docId로 문서 생성
                      .set({
                    'createdAt': createdAt,    /// 신고 시간
                    'docId': docId,            /// 문서 ID
                    'reportReason': reportReason, /// 신고 사유
                    'result': '진행 중',       /// 초기 신고 결과 상태
                    'studyId': ss.studyList[0]['docId'],         /// 신고된 스터디 ID
                    'userId': us.userList[0]['docId'],           /// 신고자 ID
                    'resultDate': ''
                  });

                  // 신고 제출 후 다이얼로그 닫기
                  Get.back();
                } else {
                  // 유효하지 않은 입력일 때 메시지 처리
                  print("신고 사유를 입력하지 않습니다.");
                }
              },
              child: Text('제출', style: f12bw500),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isLiked =
    ss.studyList[0]['likeList'].contains(us.userList[0]['docId']);
    print("Building StudyHomePage"); // 디버깅 로그
    return Scaffold(
      floatingActionButton: !isJoined
          ? Align(
          alignment: Alignment.bottomCenter, // 버튼을 화면 가운데 하단에 배치
          child: Padding(
            padding: EdgeInsets.only(left: 7, right: 7),
            child: SizedBox(
              width: Get.width, // 버튼의 너비 조정
              height: 60, // 버튼의 높이 조정
              child: FloatingActionButton.extended(
                onPressed: () {
                  signUp ? showConfirmationDialog(context, '스터디 가입을 취소하시겠습니까?', f16bw500, () async {
                    final firestore = FirebaseFirestore.instance;
                    try {
                      final docRef = firestore
                          .collection('study')
                          .doc(ss.studyList[0]['docId']);
                      await docRef.update({
                        'signUpList':
                        FieldValue.arrayRemove([us.userList[0]['docId']])
                      });

                      final userRef = firestore
                          .collection('userDetail')
                          .doc(us.userDetailList[0]['docId']); /// user디테일 컬렉션의 studyList에다가 값 추가
                      await userRef.update({
                        'signUpList':
                        FieldValue.arrayRemove([ss.studyList[0]['docId']])
                      });
                    } catch (e) {}
                    setState(() {
                      signUp = false;
                      ss.studyList[0]['signUpList']
                          .remove(us.userList[0]['docId']);
                    });}) /// 가입취소
                      : showConfirmationDialog(context, '스터디에 가입하시겠습니까?', f16bw500, () async { /// 가입신청
                    final firestore = FirebaseFirestore.instance;

                    try {
                      final docRef = firestore
                          .collection('study')
                          .doc(ss.studyList[0]['docId']);
                      await docRef.update({
                        'signUpList':
                        FieldValue.arrayUnion([us.userList[0]['docId']])
                      });
                      final userRef = firestore
                          .collection('userDetail')
                          .doc(us.userDetailList[0]['docId']);
                      await userRef.update({
                        'signUpList':
                        FieldValue.arrayUnion([ss.studyList[0]['docId']])
                      });
                    } catch (e) {
                    }
                    setState(() {
                      signUp = true;
                      ss.studyList[0]['signUpList']
                          .add(us.userList[0]['docId']);
                    });
                  });
                },
                label:
                Text(signUp ? "가입 취소하기" : "스터디 가입하기", style: f22w500),
                backgroundColor: Color(0xff3479FF), // 버튼 배경 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 모서리 둥글기
                ),
              ),
            ),
          ))
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(
          ss.studyList[0]['studyName'],
          style: f20bw700,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Row(
              children: [
                _tabController.index == 0 &&
                    ss.studyList[0]['studyHost'] ==
                        us.userList[0]
                        ['nickname'] // 홈화면일 때만 신청관리가 나올 수 있게 함
                    ? GestureDetector(
                  onTap: () {
                    Get.to(StudyRegisterPage(studyInfo: ss.studyList[0]))
                        ?.then((value) {
                      setState(() {});
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset('assets/icon/person.svg'),
                      Positioned(
                        bottom: 20,
                        left: 13,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                          child: Center(
                            child: Text(
                              '${ss.studyList[0]['signUpList'].length}',
                              style: f8w700,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
                    : SizedBox(),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    if (isLikeButtonDisabled) return;

                    setState(() {
                      isLikeButtonDisabled = true;
                    });

                    String docId = ss.studyList[0]['docId'];
                    String userId = us.userList[0]['docId'];
                    bool isLiked = ss.studyList[0]['likeList'].contains(userId);

                    // Update the like status in the local state
                    if (isLiked) {
                      ss.studyList[0]['likeList'].remove(userId);
                    } else {
                      ss.studyList[0]['likeList'].add(userId);
                    }

                    try {
                      // Update the like status in Firestore
                      await FirebaseFirestore.instance
                          .collection('study')
                          .doc(docId)
                          .update({'likeList': ss.studyList[0]['likeList']});

                      setState(() {
                        isLikeButtonDisabled = false;
                      });
                    } catch (e) {
                      print("Failed to update: $e");
                      setState(() {
                        isLikeButtonDisabled = false;
                      });
                    }
                  },
                  child: SvgPicture.asset(
                    ss.studyList[0]['likeList'].contains(us.userList[0]['docId'])
                        ? 'assets/icon/Heart.svg'
                        : 'assets/icon/emptyHeart.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 10),
                if(isHost)
                  GestureDetector(
                    onTap: (){
                      Get.to(()=>StudySetting());
                    },
                    child: SvgPicture.asset('assets/icon/gear.svg'),
                  )
                else
                  PopupMenuButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      icon: SvgPicture.asset('assets/icon/Menu.svg'),
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry>[
                          if (!isHost)
                            PopupMenuItem(
                              value: '스터디 신고',
                              onTap: () {
                                _showStudyReportDialog();
                              },
                              child: Center(
                                child: Text(
                                    '신고하기',
                                    style: f12bw500
                                ),
                              ),
                            ),
                          PopupMenuItem(
                            value: '',
                            onTap: () async {
                              await leaveStudy(ss.studyList[0]['docId']).then((_) async {
                                await getUserDetailList(us.userList[0]['docId']);
                                Get.back();
                              });
                            },
                            child: Center(
                              child: Text(
                                  '탈퇴하기',
                                  style: f12bw500
                              ),
                            ),
                          ),
                        ];
                      }
                  )
              ],
            ),
          )
        ],
        bottom: TabBar(
          labelStyle: f12bw500,
          unselectedLabelStyle: f12hgw500,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.black,
          controller: _tabController,
          indicatorWeight: 1,
          labelPadding: EdgeInsets.symmetric(horizontal: 12),
          tabs: [
            Tab(
              text: '홈',
            ),
            Tab(text: '게시판'),
            Tab(text: '일정'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StudyHomeTapPage(onMoreButtonPressed: (){
            setState(() {
              index = 1;
            });
            _selectTab(1);
          }),
          StudyPostTapPage(selectedCategoryIndex: index == 1 ? 1 : 0),
          Center(
            child: ShowSchedule(),
          ),
          // StudyChatPage(studyInfo: widget.studyInfo),
        ],
      ),
    );
  }
}

class postCategory extends StatefulWidget {
  String name;
  final bool isSelected;
  final VoidCallback onTap;

  postCategory(
      {required this.name, required this.isSelected, required this.onTap});

  @override
  State<postCategory> createState() => _postCategoryState();
}

class _postCategoryState extends State<postCategory> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.name.length == 2
            ? 38
            : widget.name.length == 3
            ? 44
            : widget.name.length == 4
            ? 50
            : 56,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Color(0xffE5E5E5)),
          color: widget.isSelected
              ? Color(0xff444444)
              : Colors.white, // 선택되면 444444색깔로 바뀜
        ),
        child: Center(
          child: Text(
            widget.name,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'NotoSans',
              color: widget.isSelected
                  ? Colors.white
                  : Color(0xff6E6E6E), // 선택되면 글씨색 하얀색으로
            ),
          ),
        ),
      ),
    );
  }
}
