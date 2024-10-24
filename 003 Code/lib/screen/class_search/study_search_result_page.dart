import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../util/color.dart';
import '../../util/font/font.dart';
import '../../util/loadingScreen.dart';
import '../study/study_home/study_home_page.dart';

class StudySearchResultPage extends StatefulWidget {
  @override
  _StudySearchResultPageState createState() => _StudySearchResultPageState();
}

class _StudySearchResultPageState extends State<StudySearchResultPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> studies = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  StudyState ss = Get.put(StudyState());
  UserState us = Get.put(UserState());
  bool isLikeButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    _fetchStudies();
  }

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
          'likeList': FieldValue.arrayRemove([us.userList[0]['nickname']]),
        });
      } else {
        await docRef.update({
          'likeList': FieldValue.arrayUnion([us.userList[0]['nickname']]),
        });
      }
      setState(() {
        isLikeButtonDisabled = false;
      });
    }
    catch (error) {
      print('Failed to toggle like: $error');
    }
  }

  Future<void> _fetchStudies() async { /// 스터디 정보 불러오기
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('study').get();

      setState(() {
        studies = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        searchResults = [];
      });
    } catch (error) {
      print('Failed to fetch studies: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchStudies(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = [];
      } else {
        searchResults = studies.where((study) {
          final nameLower = study['studyName'].toString().toLowerCase(); /// 스터디 이름을 소문자로
          final queryLower = query.toLowerCase(); /// 검색어도 소문자로
          return nameLower.contains(queryLower); /// 스터디이름이 포함되어있다면 리턴
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(searchResults);
    return Scaffold(
      appBar: AppBar(
        title: Text("스터디 검색", style: f20bw700),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '검색어 입력',
                hintStyle: TextStyle(fontSize: 14),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchStudies(_searchController.text);
                  },
                ),
              ),
              onChanged: (query) {
                _searchStudies(query);
              },
            ),
          ),
          // Display Search Results
          Expanded(
            child: searchResults.isEmpty
                ? Center(child: Text('검색 결과가 없습니다'))
                : ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final study = searchResults[index];
                var isLiked = study['likeList']
                    .contains(us.userList[0]['nickname']);
                return Padding(
                  padding: EdgeInsets.only(top: 17),
                  child: GestureDetector(
                    onTap: () {
                      ss.studyList.clear();
                      ss.studyList.value = [study];
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
                                        'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/studyImage%2F${study['docId']}?alt=media',
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
                                              await toggleLike(study['docId'],
                                                  isLiked);
                                              setState(() {
                                                if (isLiked) {
                                                  study['likeList']
                                                      .remove(us.userList[0]['nickname']);
                                                } else {
                                                  study['likeList']
                                                      .add(us.userList[0]['nickname']);
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
                                    study['interest']
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
                                  study[
                                  'studyName'], // 스터디 이름
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
                                          '${study['sido']} ${study['gungu']}',
                                          style: f10w400DeppGray),
                                      Spacer(),
                                      Text(
                                          '멤버 ${study['studyUserList']
                                              .length}',
                                          style: f10w400DeppGray),
                                      Spacer(),
                                      Text(
                                          '좋아요 ${(study['likeList'] as List)
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
          ),
        ],
      ),
    );
  }
}
