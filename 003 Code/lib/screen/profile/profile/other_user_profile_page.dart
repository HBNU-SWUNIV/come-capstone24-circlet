import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/components/components.dart';
import 'package:circlet/firebase/firebase_study.dart';
import 'package:circlet/provider/study_post_state.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/screen/lounge/lounge/lounge_view_page.dart';
import 'package:circlet/util/font/font.dart';
import 'package:circlet/util/loadingScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../dialog/dialog.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';
import '../../../util/color.dart';
import '../uri_view/pdfview.dart';
import '../uri_view/webview.dart';

class OtherUserProfilePage extends StatefulWidget {
  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage>
    with TickerProviderStateMixin {
  late TabController _UserProfilePageTabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  final us = Get.put(UserState());
  XFile? image;
  List postList = [];

  /// 라운지 게시글
  final sps = Get.put(StudyPostState());
  final ss = Get.put(StudyState());
  String nickname = '';
  var post = [];
  bool isSubmittingUser = false;
  bool userWithdraw = false;

  @override
  void initState() {
    super.initState();
    _UserProfilePageTabController = TabController(length: 3, vsync: this);

    Future.delayed(Duration.zero, () async {
      await getOtherUserDetailList(sps.post[0]['userDocId']);

      /// 탈퇴한 사용자 체크
      if (us.otherUserDetailList.value[0] == '탈퇴한 사용자') {
        setState(() {
          userWithdraw = true; // 사용자 탈퇴 상태 업데이트
          _isLoading = false;
        });
        return;

        /// 탈퇴한 사용자일 경우 나머지 메서드 실행 중지
      }

      // 탈퇴하지 않은 경우에만 아래 메서드 실행
      nickname = await getUserNickname(sps.post[0]['userDocId']);
      await getLoungePostsByUserId(sps.post[0]['userDocId']);
      await getUserDetailStudy(
          List<String>.from(us.otherUserDetailList[0]['studyList']));

      setState(() {
        if (us.otherUserDetailList.isNotEmpty) {
          _isLoading = false;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 유저아이디로 라운지 글 가져오는 함수
  Future<void> getLoungePostsByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('loungePostInfo')
          .where('userDocId', isEqualTo: userId)
          .get();
      postList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      /// 내림차순 정렬
      postList.sort((a, b) => (b['createDate']).compareTo(a['createDate']));
    } catch (e) {}
  }

  /// 유저신고 데베에 저장하는 함수
  Future<void> _saveUserReport(TextEditingController controller) async {
    if (isSubmittingUser) return;

    setState(() {
      isSubmittingUser = true;
    });

    ///  reportReason 가져오기
    String reportReason = controller.text;

    /// 문서 추가
    if (reportReason.isNotEmpty) {
      String docId =
          FirebaseFirestore.instance.collection('userReport').doc().id;

      /// 문서 ID 생성
      DateTime createdAt = DateTime.now(); // 신고 시간

      try {
        await FirebaseFirestore.instance
            .collection('userReport')
            .doc(docId)

        /// 지정된 docId로 문서 생성
            .set({
          'createdAt': createdAt,

          /// 신고 시간
          'docId': docId,

          /// 문서 ID
          'reportReason': reportReason,

          /// 신고 사유
          'result': '진행 중',

          /// 초기 신고 결과 상태
          'userId': us.userList[0]['docId'],

          /// 신고자 ID
          'resultDate': '',

          /// 신고받은 사람 ID
          'reportedUserId': '${sps.post[0]['userDocId']}'
        });
      } catch (e) {
      } finally {
        setState(() {
          isSubmittingUser = false;
        });
      }
      Get.back();
    } else {
      setState(() {
        isSubmittingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext a) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필', style: f20bw500),
        leading: GestureDetector(
          child:
          SvgPicture.asset('assets/icon/leftArrow.svg', fit: BoxFit.none),
          onTap: () {
            Get.back();
          },
        ),
        actions: [
          !userWithdraw
              ? Padding(
            padding: EdgeInsets.only(right: 16),
            child: PopupMenuButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                icon: SvgPicture.asset('assets/icon/Menu.svg'),
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry>[
                    PopupMenuItem(
                      value: '유저 신고',
                      onTap: () async {
                        TextEditingController reportReasonController1 =
                        TextEditingController();
                        showReportDialog(context, reportReasonController1,
                                () async {
                              _saveUserReport(reportReasonController1);
                            });
                      },
                      child: Center(
                        child: Text('신고하기', style: f12rw500),
                      ),
                    ),
                  ];
                }),
          )
              : const SizedBox()
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1), // Divider의 높이 설정
          child: Divider(
            color: Color(0xffEBEBEB), // Divider의 색상 설정
            height: 1, // Divider의 높이 설정
            thickness: 1, // Divider의 두께 설정
          ),
        ),
      ),
      body: _isLoading
          ? LoadingScreen()
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 75,
                  child: Row(
                    children: [
                      Stack(children: [
                        Container(
                          width: 75,
                          height: 75,
                          decoration:
                          BoxDecoration(shape: BoxShape.circle),
                          child: ClipOval(
                            // 이미지를 원형으로 자르기 위해 ClipOval 사용
                            child: CachedNetworkImage(
                              imageUrl: userWithdraw
                                  ? '' // 탈퇴한 사용자일 경우 이미지 URL 비우기
                                  : 'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${us.otherUserDetailList[0]['userId']}?alt=media',
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Image.asset(
                                    'assets/image/default_profile.png',
                                    // 에셋 경로를 지정
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
                        ),
                      ]),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userWithdraw ? '탈퇴한 사용자' : '$nickname',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'NotoSans',
                                  height: 1.2),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  userWithdraw
                      ? ''
                      : '${us.otherUserDetailList[0]['introduce']}',
                  style: f15bw400,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          DecoratedTabBar(
            tabBar: TabBar(
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 24),
              controller: _UserProfilePageTabController,
              unselectedLabelColor: Colors.grey,
              unselectedLabelStyle: f15gw500,
              labelStyle: f15bw700,
              tabs: [
                Tab(
                  text: '정보',
                ),
                Tab(text: '라운지'),
                Tab(text: '스터디그룹')
              ],
            ),
            decoration: BoxDecoration(
                border:
                Border(bottom: BorderSide(color: Color(0xffDBDBDB)))),
          ),
          const SizedBox(height: 5),
          userWithdraw
              ? const SizedBox()
              : Expanded(
            child: TabBarView(
              physics:
              BouncingScrollPhysics(), // 스크롤 physics 아무것도 안 나오게
              controller: _UserProfilePageTabController,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 22),
                  child: Column(
                    children: [
                      /// 관심분야
                      Row(
                        children: [
                          Text('관심분야', style: f15bw500),
                          const SizedBox(width: 35),

                          /// 관심분야 리스트
                          userWithdraw
                              ? const SizedBox()
                              : Obx(
                                () => Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.start,
                              spacing: 5,
                              runSpacing: 5,
                              children: us
                                  .otherUserDetailList[0]
                              ['interest']
                                  .map<Widget>((item) {
                                return Container(
                                  height: 20,
                                  padding: EdgeInsets.only(
                                      top: 3,
                                      left: 10,
                                      right: 10,
                                      bottom: 3),
                                  decoration: BoxDecoration(
                                    color:
                                    interestBackgroundColor[
                                    item],
                                    borderRadius:
                                    BorderRadius.circular(
                                        30),
                                  ),
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                        fontFamily:
                                        'NotoSans',
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w700,
                                        color:
                                        interestTextColor[
                                        item],
                                        height: 1.2),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      /// 기술스텍
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Text('기술스택', style: f15bw500),
                          const SizedBox(width: 35),
                          if (!userWithdraw)
                            ...?us.otherUserDetailList[0]
                            ['techStack']
                                ?.asMap()
                                .entries
                                .map<Widget>((entry) {
                              int index = entry.key;
                              String stack = entry.value;

                              if (index < 3) {
                                return Row(
                                  children: [
                                    Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius
                                            .circular(30),
                                        color:
                                        Color(0xffEBEBEB),
                                      ),
                                      child: Padding(
                                        padding:
                                        const EdgeInsets
                                            .symmetric(
                                            horizontal: 8),
                                        child: Center(
                                          child: Text(
                                            '#${stack}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(
                                                  0xff4F4F4F),
                                              fontWeight:
                                              FontWeight
                                                  .w500,
                                              fontFamily:
                                              'NotoSans',
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                  ],
                                );
                              } else if (index == 3) {
                                return Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 20,
                                      child: Center(
                                        child: Text(
                                          '외 ${us.otherUserDetailList[0]['techStack'].length - 3}개',
                                          style: f12bw500,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Container(); // Return an empty container for the rest
                              }
                            }).toList() ??
                                [],
                        ],
                      ),

                      /// 깃허브
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Text('깃허브', style: f15bw500),
                          const SizedBox(width: 1),
                          SvgPicture.asset(
                              'assets/icon/github.svg'),
                          const SizedBox(width: 33),
                          userWithdraw
                              ? SizedBox()
                              : Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => WebView(
                                    uri:
                                    '${us.otherUserDetailList[0]['gitUrl']}',
                                    title: 'Github'));
                              },
                              child: Container(
                                height: 30,
                                padding:
                                EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(
                                            0xffEBEBEB)),
                                    borderRadius:
                                    BorderRadius.circular(
                                        6)),
                                child: Align(
                                  alignment:
                                  Alignment.centerLeft,
                                  child: Text(
                                    '${us.otherUserDetailList[0]['gitUrl']}',
                                    style: f12bw400,
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// 블로그
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Text('블로그', style: f15bw500),
                          const SizedBox(width: 1),
                          SvgPicture.asset('assets/icon/blog.svg'),
                          const SizedBox(width: 33),
                          userWithdraw
                              ? SizedBox()
                              : Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => WebView(
                                    uri:
                                    '${us.otherUserDetailList[0]['blogUrl']}',
                                    title: 'Blog'));
                              },
                              child: Container(
                                height: 30,
                                padding: EdgeInsets.only(
                                    left: 10, right: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(
                                            0xffEBEBEB)),
                                    borderRadius:
                                    BorderRadius.circular(
                                        6)),
                                child: Align(
                                  alignment:
                                  Alignment.centerLeft,
                                  child: Text(
                                    '${us.otherUserDetailList[0]['blogUrl']}',
                                    style: f12bw400,
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),

                      /// 포트폴리오
                      Row(
                        children: [
                          Text('포트폴리오', style: f15bw500),
                          const SizedBox(width: 20),
                          userWithdraw
                              ? const SizedBox()
                              : Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => PdfView(
                                    docId:
                                    us.otherUserDetailList[
                                    0]['userId'],
                                  ));
                                },
                                child: Container(
                                  width: 200,
                                  height: 30,
                                  alignment:
                                  Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                      left: 10),
                                  // 내부패딩
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color(
                                              0xffEBEBEB)),
                                      borderRadius:
                                      BorderRadius
                                          .circular(15)),
                                  child: Text('둘리 포트폴리오',
                                      style: f13bw500),
                                ),
                              ),
                              Positioned(
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(() => PdfView(
                                      docId:
                                      us.otherUserDetailList[
                                      0]
                                      ['userId'],
                                    ));
                                  },
                                  child: SvgPicture.asset(
                                      'assets/icon/download.svg'),
                                ),
                                top: 5,
                                right: 13,
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                /// 라운지
                userWithdraw
                    ? const SizedBox()
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: postList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => LoungeViewPage(
                                  postInfo: postList[index]));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                Colors.white, // 카드 배경 색상
                                borderRadius:
                                BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(
                                      0xffB0B0B0), // 테두리 색상
                                  width: 1, // 테두리 두께
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              postList[index]
                                              ['title'],
                                              style:
                                              TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                color: Colors
                                                    .black87,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 8),
                                            Text(
                                              postList[index]
                                              ['content'],
                                              style:
                                              TextStyle(
                                                fontSize: 12,
                                                color: Colors
                                                    .black54,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 10),
                                            Row(
                                              children: [
                                                SvgPicture
                                                    .asset(
                                                  'assets/icon/emptyHeart.svg',
                                                  width: 16,
                                                  height: 16,
                                                  color: Colors
                                                      .redAccent,
                                                ),
                                                const SizedBox(
                                                    width: 5),
                                                Text(
                                                  '${postList[index]['likeList'].length}',
                                                  style:
                                                  TextStyle(
                                                    fontSize:
                                                    12,
                                                    color: Colors
                                                        .black87,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width:
                                                    15),
                                                SvgPicture
                                                    .asset(
                                                  'assets/icon/chat.svg',
                                                  width: 16,
                                                  height: 16,
                                                  color: Colors
                                                      .blueAccent,
                                                ),
                                                const SizedBox(
                                                    width: 5),
                                                Text(
                                                  '${postList[index]['commentCount']}',
                                                  style:
                                                  TextStyle(
                                                    fontSize:
                                                    12,
                                                    color: Colors
                                                        .black87,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width:
                                                    15),
                                                Text(
                                                  '${postList[index]['date']}',
                                                  style:
                                                  TextStyle(
                                                    fontSize:
                                                    10,
                                                    color: Colors
                                                        .grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    postList[index]['imagePaths'] !=
                                        null &&
                                        postList[index][
                                        'imagePaths']
                                            .isNotEmpty
                                        ? Container(
                                      width: 70,
                                      height: 70,
                                      decoration:
                                      BoxDecoration(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        border: Border.all(
                                            color: Colors
                                                .black), // 테두리 추가
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            8),
                                        child:
                                        CachedNetworkImage(
                                          imageUrl:
                                          'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/post%2F${postList[index]['imagePaths'][0]}?alt=media',
                                          fit: BoxFit
                                              .cover,
                                          placeholder: (context,
                                              url) =>
                                              Container(
                                                color: Colors
                                                    .grey[
                                                300],
                                                child: Icon(
                                                  Icons
                                                      .image,
                                                  color: Colors
                                                      .grey[
                                                  500],
                                                ),
                                              ),
                                          errorWidget: (context,
                                              url,
                                              error) =>
                                              Container(
                                                color: Colors
                                                    .grey[
                                                300],
                                                child: Icon(
                                                  Icons
                                                      .error,
                                                  color: Colors
                                                      .redAccent,
                                                ),
                                              ),
                                        ),
                                      ),
                                    )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            color: Color(0xffD9D9D9),
                            height: 15,
                            thickness: 1.5,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                /// 스터디그룹
                userWithdraw
                    ? const SizedBox()
                    : SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      for (int i = 0;
                      i < ss.userDetailStudyList.length;
                      i++)
                        Padding(
                          padding: EdgeInsets.only(
                              left: 23, right: 23, top: 10),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context)
                                    .size
                                    .width, // 화면 너비 전체 사용
                                height: 95, // 원하는 높이
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.only(
                                    topLeft:
                                    Radius.circular(20),
                                    // 위쪽 왼쪽 모서리 반경
                                    topRight: Radius.circular(
                                        20), // 위쪽 오른쪽 모서리 반경
                                  ),
                                  border: Border.all(
                                      color: Color(
                                          0xffD7D7D7)), // 테두리 설정 (옵션)
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.only(
                                    topLeft:
                                    Radius.circular(20),
                                    // 위쪽 왼쪽 모서리 반경
                                    topRight: Radius.circular(
                                        20), // 위쪽 오른쪽 모서리 반경
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/studyImage%2F${ss.userDetailStudyList[i]['docId']}?alt=media',
                                    fit: BoxFit.cover,
                                    placeholder: (context,
                                        url) =>
                                    const CircularProgressIndicator(),
                                    errorWidget: (context,
                                        url, error) =>
                                    const Icon(
                                        Icons.error),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context)
                                    .size
                                    .width,
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                      Color(0xffD7D7D7)),
                                  borderRadius:
                                  BorderRadius.only(
                                    bottomLeft:
                                    Radius.circular(10),
                                    bottomRight:
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                          ss.userDetailStudyList[
                                          i]['studyName'],
                                          style: f14bw700),
                                      const SizedBox(
                                          height: 5),
                                      Container(
                                        height: 40,
                                        child: Text(
                                          ss.userDetailStudyList[
                                          i]['studyInfo'],
                                          style: f12bw500,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.person),
                                          const SizedBox(
                                              width: 2),
                                          Text(
                                            '${ss.userDetailStudyList[i]['studyUserList'].length}',
                                            style: f10bw500,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
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

class profilePostItem extends StatelessWidget {
  final Map<String, dynamic> postInfo;

  profilePostItem({required this.postInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Get.to(() => LoungeViewPage(postInfo: postInfo));
          },
          child: Container(
            color: Color(0xFAFAFA),

            /// FAFAFA가 화면이랑 같은 색
            child: Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(postInfo['title'],
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 10),
                          Text(postInfo['content'],
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              SvgPicture.asset('assets/icon/emptyHeart.svg'),
                              const SizedBox(width: 5),
                              Text('${postInfo['likeList'].length}'),
                              const SizedBox(width: 10),
                              SvgPicture.asset('assets/icon/chat.svg'),
                              const SizedBox(width: 5),
                              Text('${postInfo['commentCount']}'),
                              const SizedBox(width: 10),
                              Text('${postInfo['date']}',
                                  style: TextStyle(fontSize: 8)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  postInfo['imagePaths'] != null &&
                      postInfo['imagePaths'].isNotEmpty
                      ? Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl:
                        'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/post%2F${postInfo['imagePaths'][0]}?alt=media',
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      ),
                    ),
                  )
                      : SizedBox()
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Color(0xffD9D9D9),
          height: 13,
          thickness: 2,
        ),
      ],
    );
  }
}
