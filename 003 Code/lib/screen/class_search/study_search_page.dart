import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/screen/class_search/study_more/new_study_page.dart';
import 'package:circlet/screen/class_search/study_more/popular_study_page.dart';
import 'package:circlet/screen/class_search/study_more/recommend_study_page.dart';
import 'package:circlet/screen/class_search/study_search_result_page.dart';
import 'package:circlet/screen/study/create/study_interest.dart';
import 'package:circlet/screen/class_search/search_category_page.dart';
import 'package:circlet/screen/study/study_home/study_home_page.dart';
import 'package:circlet/util/font/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../components/components.dart';
import '../../firebase/firebase_study.dart';
import '../../provider/study_state.dart';
import '../../provider/user_state.dart';
import '../../util/color.dart';
import '../../util/loadingScreen.dart';

class StudySearchPage extends StatefulWidget {
  const StudySearchPage({Key? key}) : super(key: key);

  @override
  State<StudySearchPage> createState() => _StudySearchPageState();
}

class _StudySearchPageState extends State<StudySearchPage> {
  final us = Get.put(UserState());
  final ss = Get.put(StudyState());

  /// 가입한 스터디의 이미지
  List<String> myStudyImageUrlList = [];

  /// 신청중인 스터디 이미지
  List<String> mySignUpStudyImageUrlList = [];
  List<StudyInfoDB> studyInfobyDB = [];
  List<StudyInfoDB> studyInfoMyStudy = [];
  List<StudyInfoDB> studyInfoSignUp = [];
  List<String> imageUrlList = [];

  Color myStudyText = Colors.black;
  Color studySearchText = Colors.grey;
  bool isMyStudyMode = true;
  List<String> postTitle = ['Study 1', 'Study 2', 'Study 3'];
  List<String> categoryList = [
    'IOS 개발',
    '안드로이드 개발',
    '웹 개발',
    '게임 개발',
    '네트워크/보안',
    '백엔드/서버',
    '프론트엔드',
    '임베디드',
    '인공지능',
    '전체보기'
  ];
  FirebaseStorage storage =
  FirebaseStorage.instanceFor(bucket: 'gs://circlet-9c202.appspot.com');
  bool isLoading = true;
  bool _isLoading = true;

  /// 스터디 가져올 때 로딩
  bool isLikeButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        await getStudyInfo();

        /// 스터디 정보 가져오는 함수
      } catch (error) {
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  /// 좋아요 함수
  Future<void> toggleLike(String docId, bool like) async {
    if (isLikeButtonDisabled) return;
    isLikeButtonDisabled = true;
    try {
      DocumentReference docRef =
      FirebaseFirestore.instance.collection('study').doc(docId);

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
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingScreen();
    }
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                "Steady",
                style: f30bw700,
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => StudyInterest());
                  },
                  child: SvgPicture.asset('assets/icon/x-circle-fill.svg'),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => StudySearchResultPage());
                    },
                    child: SvgPicture.asset('assets/icon/search.svg'),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(14),
                child: Divider(
                  color: Color(0xffEBEBEB),
                  height: 1,
                  thickness: 1,
                ),
              )),
          body: SingleChildScrollView(
            // 스크롤 가능하도록 변경
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 스터디 찾기
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 5, top: 21, bottom: 12),
                        child: Row(
                          children: [Text('카테고리', style: f22bw700)],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconText(
                                  image: 'assets/icon/grid.svg',
                                  text: '전체보기',
                                  ontap: () {
                                    Get.to(SearchCategoryPage(
                                      categoryName: '전체보기',
                                      initialIndex: 0,
                                    ))?.then((value) {
                                      setState(() {});
                                    });
                                  },
                                  isLarge: false,
                                ),
                                Spacer(),
                                IconText(
                                  image: 'assets/icon/apple.svg',
                                  text: 'IOS 개발',
                                  ontap: () {
                                    Get.to(SearchCategoryPage(
                                      categoryName: 'iOS',
                                      initialIndex: 1,
                                    ))?.then((value) {
                                      setState(() {});
                                    });
                                  },
                                  isLarge: false,
                                ),
                                Spacer(),
                                IconText(
                                  image: 'assets/icon/android.svg',
                                  text: '안드로이드 개발',
                                  ontap: () {
                                    Get.to(SearchCategoryPage(
                                      categoryName: '안드로이드',
                                      initialIndex: 1,
                                    ))?.then((value) {
                                      setState(() {});
                                    });
                                  },
                                  isLarge: false,
                                ),
                                Spacer(),
                                IconText(
                                  image: 'assets/icon/web.svg',
                                  text: '웹개발',
                                  ontap: () {
                                    Get.to(SearchCategoryPage(
                                      categoryName: '웹',
                                      initialIndex: 3,
                                    ))?.then((value) {
                                      setState(() {});
                                    });
                                  },
                                  isLarge: false,
                                ),
                                Spacer(),
                                IconText(
                                  image: 'assets/icon/game.svg',
                                  text: '게임 개발',
                                  ontap: () {
                                    Get.to(SearchCategoryPage(
                                      categoryName: '게임',
                                      initialIndex: 4,
                                    ))?.then((value) {
                                      setState(() {});
                                    });
                                  },
                                  isLarge: false,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                IconText(
                                  image: 'assets/icon/security.svg',
                                  text: '네트워크/보안',
                                  ontap: () {
                                    Get.to(SearchCategoryPage(
                                      categoryName: '네트워크/보안',
                                      initialIndex: 5,
                                    ))?.then((value) {
                                      setState(() {});
                                    });
                                  },
                                  isLarge: false,
                                ),
                                Spacer(),
                                IconText(
                                  image: 'assets/icon/server.svg',
                                  text: '백엔드/서버',
                                  ontap: () {
                                    Get.to(SearchCategoryPage(
                                      categoryName: '백엔드/서버',
                                      initialIndex: 6,
                                    ))?.then((value) {
                                      setState(() {});
                                    });
                                  },
                                  isLarge: false,
                                ),
                                Spacer(),
                                IconText(
                                  image: 'assets/icon/frontEnd.svg',
                                  text: '프론트엔드',
                                  ontap: () {
                                    Get.to(SearchCategoryPage(
                                      categoryName: '프론트엔드',
                                      initialIndex: 7,
                                    ))?.then((value) {
                                      setState(() {});
                                    });
                                  },
                                  isLarge: false,
                                ),
                                Spacer(),
                                IconText(
                                  image: 'assets/icon/embedded.svg',
                                  text: '임베디드',
                                  ontap: () {
                                    Get.to(SearchCategoryPage(
                                      categoryName: '임베디드',
                                      initialIndex: 8,
                                    ))?.then((value) {
                                      setState(() {});
                                    });
                                  },
                                  isLarge: false,
                                ),
                                Spacer(),
                                IconText(
                                  image: 'assets/icon/ai.svg',
                                  text: '인공지능',
                                  ontap: () {
                                    Get.to(SearchCategoryPage(
                                      categoryName: '인공지능',
                                      initialIndex: 9,
                                    ))?.then((value) {
                                      setState(() {});
                                    });
                                  },
                                  isLarge: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// 인기 스터디
                      Padding(
                        padding: EdgeInsets.only(left: 2, right: 10, top: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "인기 스터디",
                              style: f18bw700,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(PopularStudyPage())?.then((value) {
                                  setState(() {});
                                });
                              },
                              child: Text("더보기", style: f16w100MoreGray),
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: ss.popularStudyList.length,
                          itemBuilder: (context, index) {
                            var isPopularLiked = ss.popularStudyList[index]
                            ['likeList']
                                .contains(us.userList[0]['docId']);
                            return Padding(
                              padding: EdgeInsets.only(top: 17),
                              child: GestureDetector(
                                onTap: () {
                                  List list = ss.popularStudyList.value;
                                  ss.studyList.value = [list[index]];
                                  Get.to(() => StudyHomePage())
                                      ?.then((value) async {
                                    setState(() async {
                                      await getStudyInfo();
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
                                              borderRadius:
                                              BorderRadius.circular(6),
                                              child: Stack(
                                                fit: StackFit.expand,

                                                /// 이미지가 짤리는걸 막아줌
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl:
                                                    'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/studyImage%2F${ss.popularStudyList[index]['docId']}?alt=media',
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                        url) =>
                                                        Center(
                                                            child:
                                                            LoadingScreen()),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                        Icon(Icons.error),
                                                  ),
                                                  Positioned(
                                                      left: 4,

                                                      /// 왼쪽에서의 위치 조정 값이 커질수록 오른쪽으로 이동
                                                      bottom: 4,

                                                      /// 아래에서의 위치 조정 값이 커질수록 위로 이동
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          await toggleLike(
                                                              ss.popularStudyList[
                                                              index]
                                                              ['docId'],
                                                              isPopularLiked);
                                                          setState(() {
                                                            if (isPopularLiked) {
                                                              ss.popularStudyList[
                                                              index][
                                                              'likeList']
                                                                  .remove(us
                                                                  .userList[0]
                                                              [
                                                              'docId']);
                                                            } else {
                                                              ss.popularStudyList[
                                                              index][
                                                              'likeList']
                                                                  .add(us.userList[
                                                              0][
                                                              'docId']);
                                                            }
                                                          });
                                                        },
                                                        child: SvgPicture.asset(
                                                            isPopularLiked
                                                                ? 'assets/icon/Heart.svg'
                                                                : 'assets/icon/whiteEmptyHeart.svg',
                                                            width: 25,
                                                            height: 25),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          )),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Wrap(
                                                children: ss
                                                    .popularStudyList[index]
                                                ['interest']
                                                    .map<Widget>((interests) {
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
                                              ss.popularStudyList[index]
                                              ['studyName'], // 스터디 이름
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'NotoSans',
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10, right: 29),
                                              child: Row(
                                                children: [
                                                  Text(
                                                      '${ss.popularStudyList[index]['sido']} ${ss.popularStudyList[index]['gungu']}',
                                                      style: f10w400DeppGray),
                                                  Spacer(),
                                                  Text(
                                                      '멤버 ${ss.popularStudyList[index]['studyUserList'].length}',
                                                      style: f10w400DeppGray),
                                                  Spacer(),
                                                  Text(
                                                      '좋아요 ${(ss.popularStudyList[index]['likeList'] as List).length}',
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
                        );
                      }),
                      /// 신규 스터디
                      Padding(
                        padding: EdgeInsets.only(left: 2, right: 10, top: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "신규 스터디",
                              style: f18bw700,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(NewStudyPage())?.then((value) {
                                  setState(() {});
                                });
                              },
                              child: Text("더보기", style: f16w100MoreGray),
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: ss.newStudyList.length,
                          itemBuilder: (context, index) {
                            /// likeList가 null인 경우를 처리하기 위해 ?? []를 사용
                            var likeList = ss.newStudyList[index]['likeList']
                            as List<dynamic>? ??
                                [];
                            var isNewLiked =
                            likeList.contains(us.userList[0]['docId']);

                            return Padding(
                              padding: EdgeInsets.only(top: 17),
                              child: GestureDetector(
                                onTap: () {
                                  List list = ss.newStudyList.value;
                                  ss.studyList.value = [list[index]];
                                  Get.to(() => StudyHomePage())
                                      ?.then((value) async {
                                    await getStudyInfo();
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
                                            borderRadius:
                                            BorderRadius.circular(6),
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl:
                                                  'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/studyImage%2F${ss.newStudyList[index]['docId']}?alt=media',
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Center(
                                                          child:
                                                          LoadingScreen()),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                      Icon(Icons.error),
                                                ),
                                                Positioned(
                                                  left: 4,
                                                  bottom: 4,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      await toggleLike(
                                                          ss.newStudyList[index]
                                                          ['docId'],
                                                          isNewLiked);
                                                      setState(() {
                                                        if (isNewLiked) {
                                                          ss.newStudyList[index]
                                                          ['likeList']
                                                              .remove(us
                                                              .userList[
                                                          0]['docId']);
                                                        } else {
                                                          ss.newStudyList[index]
                                                          ['likeList']
                                                              .add(us.userList[
                                                          0]['docId']);
                                                        }
                                                      });
                                                    },
                                                    child: SvgPicture.asset(
                                                      isNewLiked
                                                          ? 'assets/icon/Heart.svg'
                                                          : 'assets/icon/whiteEmptyHeart.svg',
                                                      width: 25,
                                                      height: 25,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Wrap(
                                              children: ss.newStudyList[index]
                                              ['interest']
                                                  .map<Widget>((interests) {
                                                Color? backgroundColors =
                                                interestBackgroundColor[
                                                interests];
                                                Color? interestTextColors =
                                                interestTextColor[
                                                interests];
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
                                                    child: Text(
                                                      interests,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                          interestTextColors,
                                                          fontFamily:
                                                          'NotoSans',
                                                          fontWeight:
                                                          FontWeight.w700),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              ss.newStudyList[index]
                                              ['studyName'],
                                              style: f14bw700,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10, right: 29),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${ss.newStudyList[index]['sido']} ${ss.newStudyList[index]['gungu']}',
                                                    style: f10w400DeppGray,
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    '멤버 ${ss.newStudyList[index]['studyUserList'].length}',
                                                    style: f10w400DeppGray,
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    '좋아요 ${likeList.length}',
                                                    style: f10w400DeppGray,
                                                  ),
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
                        );
                      }),
                      /// 이런 스터디도 있어요
                      Padding(
                        padding: EdgeInsets.only(left: 2, right: 10, top: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "이런 스터디도 있어요",
                              style: f18bw700,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(RecommendStudyPage())?.then((value) {
                                  setState(() {});
                                });
                              },
                              child: Text("더보기", style: f16w100MoreGray),
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: ss.otherStudyList.isNotEmpty
                              ? ss.otherStudyList.length
                              : 0,
                          itemBuilder: (context, index) {
                            if (index >= ss.otherStudyList.length) {
                              return SizedBox();
                            }

                            var likeList = ss.otherStudyList[index]['likeList']
                            as List<dynamic>? ??
                                [];
                            var isOtherLiked =
                            likeList.contains(us.userList[0]['docId']);

                            return Padding(
                              padding: EdgeInsets.only(top: 17),
                              child: GestureDetector(
                                onTap: () {
                                  List list = ss.otherStudyList;
                                  ss.studyList.value = [list[index]];
                                  Get.to(() => StudyHomePage())
                                      ?.then((value) async {
                                    await getStudyInfo();
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
                                            borderRadius:
                                            BorderRadius.circular(6),
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl:
                                                  'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/studyImage%2F${ss.otherStudyList[index]['docId']}?alt=media',
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Center(
                                                          child:
                                                          LoadingScreen()),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                      Icon(Icons.error),
                                                ),
                                                Positioned(
                                                  left: 4,
                                                  bottom: 4,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      await toggleLike(
                                                          ss.otherStudyList[
                                                          index]['docId'],
                                                          isOtherLiked);
                                                      setState(() {
                                                        if (isOtherLiked) {
                                                          ss.otherStudyList[
                                                          index]
                                                          ['likeList']
                                                              .remove(us
                                                              .userList[
                                                          0]['docId']);
                                                        } else {
                                                          ss.otherStudyList[
                                                          index]
                                                          ['likeList']
                                                              .add(us.userList[
                                                          0]['docId']);
                                                        }
                                                      });
                                                    },
                                                    child: SvgPicture.asset(
                                                      isOtherLiked
                                                          ? 'assets/icon/Heart.svg'
                                                          : 'assets/icon/whiteEmptyHeart.svg',
                                                      width: 25,
                                                      height: 25,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Wrap(
                                              children: ss.otherStudyList[index]
                                              ['interest']
                                                  .map<Widget>((interests) {
                                                Color? backgroundColors =
                                                interestBackgroundColor[
                                                interests];
                                                Color? interestTextColors =
                                                interestTextColor[
                                                interests];
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
                                                    child: Text(
                                                      interests,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                        interestTextColors,
                                                        fontFamily: 'NotoSans',
                                                        fontWeight:
                                                        FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              ss.otherStudyList[index]
                                              ['studyName'],
                                              style: f14bw700,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10, right: 29),
                                              child: Row(
                                                children: [
                                                  Text(
                                                      '${ss.otherStudyList[index]['sido']} ${ss.otherStudyList[index]['gungu']}',
                                                      style: f10w400DeppGray),
                                                  Spacer(),
                                                  Text(
                                                      '멤버 ${ss.otherStudyList[index]['studyUserList'].length}',
                                                      style: f10w400DeppGray),
                                                  Spacer(),
                                                  Text(
                                                      '좋아요 ${(ss.otherStudyList[index]['likeList'] as List).length}',
                                                      style: f10w400DeppGray),
                                                ],
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
                        );
                      })
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
