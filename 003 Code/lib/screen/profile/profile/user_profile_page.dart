import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/components/components.dart';
import 'package:circlet/screen/profile/setting/profile_setting_page.dart';
import 'package:circlet/util/font/font.dart';
import 'package:circlet/util/loadingScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';
import '../../../util/color.dart';
import '../uri_view/pdfview.dart';
import '../uri_view/webview.dart';

class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with TickerProviderStateMixin {
  late TabController _UserProfilePageTabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  final us = Get.put(UserState());
  XFile? image;
  List<Map<String, dynamic>> postList = [];

  @override
  void initState() {
    super.initState();
    _UserProfilePageTabController = TabController(length: 3, vsync: this);
    Future.delayed(Duration.zero, () async {
      await getUserDetailList(us.userList[0]['docId']);
      await getLoungePostsByAuthor(us.userList[0]['nickname']);
      print('가져온 userDetailList? ${us.userDetailList.value}');
      _isLoading = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getLoungePostsByAuthor(String author) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('loungePostInfo')
          .where('author', isEqualTo: author)
          .get();
      postList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      print('loungePostInfo???????? ${postList}');
    } catch (e) {
      print('Error getting loungePostInfo: $e');
    }
  }

  // int getTotalLikes() {
  //   int totalLikes = 0;
  //   for (var post in postList) {
  //     totalLikes += (post['likeList'] as List).length;
  //   }
  //   return totalLikes;
  // }

  @override
  Widget build(BuildContext context) {
    //int totalLikes = getTotalLikes();

    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(() => ProfileSettingPage());
            },
            child: Padding(
              padding: EdgeInsets.only(right: 9),
              child: SvgPicture.asset('assets/icon/gear.svg'),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(
            color: Color(0xffEBEBEB),
            height: 1,
            thickness: 1,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: LoadingScreen())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
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
                                decoration: BoxDecoration(shape: BoxShape.circle),
                                child: ClipOval(
                                  // 이미지를 원형으로 자르기 위해 ClipOval 사용
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${us.userList[0]['docId']}?alt=media',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 50,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    print('사진 수정 클릭');
                                  },
                                  child: Container(
                                    //margin: EdgeInsets.only(left: 65, top: 63),
                                    width: 14,
                                    height: 14,
                                    child: Icon(Icons.edit),
                                  ),
                                ),
                              )
                            ]),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${us.userList[0]['nickname']}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'NotoSans',
                                        height: 1.2
                                    ),
                                  ),
                                  SizedBox(height: 12,),
                                  /// 개발자 종류, 경력 표시
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '웹 개발자',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xffFF9F2D),
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'NotoSans',
                                          height: 1.2
                                        ),
                                      ),
                                      SizedBox(width: 4), // 중간에 빈칸을 적당한 크기로 설정
                                      Text(
                                        '1년차',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff6E6E6E),
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'NotoSans',
                                            height: 1.2
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 25,),
                      Text(
                        '${us.userDetailList[0]['introduce']}',
                        style: f15bw400,
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.only(left: 20, right: 25, top: 20),
                //   child: Text(
                //     '${us.userDetailList[0]['introduce']}',
                //     style: f13bw500,
                //   ),
                // ),
                const SizedBox(height: 5),
                DecoratedTabBar(
                  tabBar: TabBar(
                    indicatorColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 24),
                    //여백으로 인해 tab사이즈보다 작아짐
                    controller: _UserProfilePageTabController,
                    labelStyle: f15bw500,
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
                Expanded(
                  child: TabBarView(
                    physics: BouncingScrollPhysics(), // 스크롤 physics 아무것도 안 나오게
                    controller: _UserProfilePageTabController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20,top: 22),
                        child: Column(
                          children: [
                            /// 관심분야
                            Row(
                              children: [
                                Text('관심분야', style: f15bw500),
                                const SizedBox(width: 35),
                                /// 관심분야 리스트
                                Obx(() => Wrap(
                                  direction: Axis.horizontal,
                                  alignment: WrapAlignment.start,
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: us.userDetailList[0]['interest'].map<Widget>((item) {
                                    return Container(
                                      height: 20,
                                      padding: EdgeInsets.only(top: 3, left: 10, right: 10, bottom: 3),
                                      decoration: BoxDecoration(
                                        color: interestBackgroundColor[item],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontFamily: 'NotoSans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: interestTextColor[item],
                                            height: 1.2

                                        ),
                                      ),
                                    );
                                  }).toList(
                                  ),
                                ),),
                              ],
                            ),
                            /// 기술스텍
                            const SizedBox(height: 40,),
                            Row(
                              children: [
                                Text('기술스택', style: f15bw500),
                                const SizedBox(width: 35),
                                ...us.userDetailList[0]['techStack']
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
                                                    BorderRadius.circular(30),
                                                color: Color(0xffEBEBEB),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 8, right: 8),
                                                child: Center(
                                                  child: Text(
                                                    '#${stack}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xff4F4F4F),
                                                        fontWeight: FontWeight.w500,
                                                        fontFamily: 'NotoSans',
                                                        height: 1.2
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
                                                  '외 ${us.userDetailList[0]['techStack'].length - 3}개',
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
                            const SizedBox(height: 40,),
                            Row(
                              children: [
                                Text('깃허브', style: f15bw500),
                                const SizedBox(width: 1),
                                SvgPicture.asset('assets/icon/github.svg'),
                                const SizedBox(width: 33),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      Get.to(()=>WebView(uri: '${us.userDetailList[0]['gitUrl']}', title: 'Github'));
                                    },
                                    child: Container(
                                      height: 30,
                                      padding: EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xffEBEBEB)),
                                          borderRadius: BorderRadius.circular(6)),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${us.userDetailList[0]['gitUrl']}',
                                          style: f12bw400,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            /// 블로그
                            const SizedBox(height: 40,),
                            Row(
                              children: [
                                Text('블로그', style: f15bw500),
                                const SizedBox(width: 1),
                                SvgPicture.asset('assets/icon/blog.svg'),
                                const SizedBox(width: 33),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      Get.to(()=>WebView(uri: '${us.userDetailList[0]['blogUrl']}', title: 'Blog'));
                                    },
                                    child: Container(
                                      height: 30,
                                      padding: EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xffEBEBEB)),
                                          borderRadius: BorderRadius.circular(6)),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${us.userDetailList[0]['blogUrl']}',
                                          style: f12bw400,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40,),
                            /// 포트폴리오
                            Row(
                              children: [
                                Text('포트폴리오', style: f15bw500),
                                const SizedBox(width: 20),
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Get.to(()=>PdfView(docId: us.userList[0]['docId'],));
                                      },
                                      child: Container(
                                        width: 200,
                                        height: 30,
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(left: 10),
                                        // 내부패딩
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xffEBEBEB)),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child:
                                            Text('둘리 포트폴리오', style: f13bw500),
                                      ),
                                    ),
                                    Positioned(
                                      child: GestureDetector(
                                        onTap: () {
                                          print('다운로드');
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
                      ), // 라운지
                      SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: postList.length != 0
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: postList.length,
                                  itemBuilder: (context, index) {
                                    return profilePostItem(
                                        postInfo: postList[index]);
                                  },
                                )
                              : const SizedBox()),

                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            StudyGroupItem(
                                imagePath:
                                    'assets/image/example/profile_study_pic.png',
                                title: '[안공모] 안드로이드 스튜디오 공부 모임',
                                description:
                                    '안드로이드 앱 개발할 사람들 모두 모여라~ \n소통, 배려, 존중하는 스터디입니다.',
                                numberOfPeople: 120),
                            StudyGroupItem(
                                imagePath:
                                    'assets/image/example/profile_study_pic.png',
                                title: '[안공모] 안드로이드 스튜디오 공부 모임',
                                description:
                                    '안드로이드 앱 개발할 사람들 모두 모여라~ \n소통, 배려, 존중하는 스터디입니다.',
                                numberOfPeople: 120),
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

class StudyGroupItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final int numberOfPeople;

  StudyGroupItem({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.numberOfPeople,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xffD7D7D7)),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Image.asset(imagePath, fit: BoxFit.fill),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffD7D7D7)),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 5),
                  Container(
                    height: 40,
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person),
                      const SizedBox(width: 2),
                      Text(
                        numberOfPeople.toString(),
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  )
                ],
              ),
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
        Padding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 5),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(postInfo['title'], style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),
                      Text(postInfo['content'], style: TextStyle(fontSize: 12)),
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
                        child: Image.network(
                          postInfo['imagePaths'][0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : SizedBox()
            ],
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
