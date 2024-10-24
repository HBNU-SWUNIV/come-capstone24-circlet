import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/components/components.dart';
import 'package:circlet/firebase/firebase_user.dart';
import 'package:circlet/provider/schedule_state.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/util/color.dart';
import 'package:circlet/util/font/font.dart';
import 'package:circlet/util/loadingScreen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../firebase/firebase_schedule.dart';
import '../../../firebase/firebase_study.dart';
import '../../../provider/study_post_state.dart';
import '../../../provider/user_state.dart';
import '../post/study_post_create.dart';
import '../post/study_post_view_page.dart';

class StudyHomeTapPage extends StatefulWidget {
  final VoidCallback onMoreButtonPressed;
  StudyHomeTapPage({Key? key, required this.onMoreButtonPressed}) : super(key: key);

  @override
  _StudyHomeTapPageState createState() => _StudyHomeTapPageState();
}

class _StudyHomeTapPageState extends State<StudyHomeTapPage> {

  bool signUp = false;
  bool isJoined = false;
  String image = '';
  bool _isLoading = true;
  List<PostInfo> noticePosts = [];
  FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'gs://circlet-9c202.appspot.com');
  final us = Get.put(UserState());
  final ss = Get.put(StudyState());
  final sds = Get.put(ScheduleState());
  final sps = Get.put(StudyPostState());
  final PageController _pageController = PageController();


  @override
  void initState() {
    super.initState();
    if (ss.studyList[0]['studyUserList'].contains(us.userList[0]['nickname'])) {
      isJoined = true; // 스터디의 유저리스트에 현재 로그인된 사용자의 닉네임이 있다면 가입된 상태
    }
    Future.delayed(Duration.zero, () async {
      await getOneStudyList();
      await getClosestSchedule();
      await getNotice3Post();

      print('가져온 공지사항은?? ${sps.studyNoticePost3}');

      print('스케쥴은?${sds.scheduleList}');
      _isLoading = false;
      setState(() {});
    });
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 공지사항 title 글씨 갯수 조정
  String _text(String title) {
    if (title.length > 12) {
      return title.substring(0, 12) + '...';
    } else {
      return title;
    }
  }

  void onMoreButtonPressed() {
  }



  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: LoadingScreen())
        : SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 스터디 사진
                Stack(
                  children: [
                    Container(
                      width: Get.width,
                      height: 200,
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/studyImage%2F${ss.studyList[0]['docId']}?alt=media',
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Center(child: LoadingScreen()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Obx(
                        () => Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.start,
                          spacing: 5,
                          runSpacing: 5,
                          children:
                              ss.studyList[0]['interest'].map<Widget>((item) {
                            return Container(
                              height: 20,
                              padding: EdgeInsets.only(
                                  top: 3, left: 10, right: 10, bottom: 3),
                              decoration: BoxDecoration(
                                color: interestBackgroundColor[item],
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: moreGrayColor.withOpacity(0.2),
                                    spreadRadius: 7,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: interestTextColor[item],
                                    height: 1.2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        /// 시군구, 인원수, 기술스텍
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xffEBEBEB)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                child: Text(
                                    '${ss.studyList[0]['sido']} ${ss.studyList[0]['gungu']}',
                                    style: f12darkGray2w500),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xffEBEBEB)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                child: Row(
                                  children: [
                                    Container(
                                        width: 14,
                                        height: 14,
                                        child: SvgPicture.asset(
                                          'assets/icon/bottom_navi/lounge.svg',
                                          color: darkGrayColor2,
                                        )),
                                    Text(
                                        ' ${ss.studyList[0]['studyUserList'].length}',
                                        style: f12darkGray2w500),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 7,
                          runSpacing: 5,
                          children: [
                            for (int i = 0; i < ss.studyList[0]['techStack'].length; i++)
                              Text('#${ss.studyList[0]['techStack'][i]}', style: f12darkGray2w500),
                          ],
                        )
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.only(left: 11, right: 9, top: 13),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('공지사항', style: f18bw700),
                        GestureDetector(
                            onTap: widget.onMoreButtonPressed,
                            child: Row(
                              children: [
                                Text('더 보기', style: f12hgw500),
                                const SizedBox(
                                  width: 5,
                                ),
                                SvgPicture.asset('assets/icon/left.svg')
                              ],
                            ))
                      ]),
                ),

                /// 공지사항이 존재할 때 공지사항 리스트 출력
                if (sps.studyNoticePost3.length > 0)
                  Container(
                    height: 120,
                    child: ListView.builder(
                      itemCount: sps.studyNoticePost3.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => StudyPostViewPage(
                                postInfo: sps.studyNoticePost3[index]));
                          },
                          child: Column(
                            children: [
                              Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 18, right: 31, top: 10, bottom: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 33,
                                        height: 19,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Color(0xff3648EB)),
                                        child: Center(
                                          child: Text(
                                            '공지',
                                            style: f10w700,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: Text(
                                            (_text(sps.studyNoticePost3[index]['title'])),
                                            overflow: TextOverflow.ellipsis,
                                            style: f12bw700),
                                      ),
                                      Spacer(),
                                      Text(sps.studyNoticePost3[index]['date'],
                                          style: f8gw500),
                                    ],
                                  ),
                                ),
                              ),
                              if (index != 3)
                                Padding(
                                  padding: EdgeInsets.only(left: 22, right: 22),
                                  child: Container(
                                    color: Color(0xffEBEBEB),
                                    width: Get.width,
                                    height: 1,
                                  ),
                                )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else if (ss.studyList[0]['studyHost'] ==
                    us.userList[0]['nickname'])
                // 공지사항이 없고 사용자가 호스트일 때 '공지사항 추가하기' 버튼 표시
                  Padding(
                    padding: EdgeInsets.only(
                        left: 12, right: 12, top: 14, bottom: 17),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => StudyPostCreatePage(
                          studyId: ss.studyList[0]['docId'],
                          selectedTab: '공지사항',
                        ))?.then((value) async{
                          await getNotice3Post();
                          setState(() {
                          });
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0xffD4D4D4),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 77,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('+ 공지사항 추가하기', style: f20w700)],
                        ),
                      ),
                    ),
                  )
                else
                // 공지사항이 없고 사용자가 호스트가 아닐 때 "공지사항이 없습니다" 표시
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xffD4D4D4),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 77,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('공지사항이 없습니다', style: f20w700)],
                      ),
                    ),
                  ),
                Container(
                  height: 2,
                  width: Get.width,
                  color: lightGrayColor2,
                ),
                Padding(
                    padding: EdgeInsets.only(
                        left: 11, right: 9, top: 13, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('소개글', style: f15bw700),
                          ],
                        ),
                        const SizedBox(height: 11),
                        Container(
                          child: Text(ss.studyList[0]['studyInfo'],
                              overflow: TextOverflow.visible, style: f12bw500),
                        )
                      ],
                    )),
                Container(
                  height: 2,
                  width: Get.width,
                  color: lightGrayColor2,
                ),
                /// 인원
                Padding(padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '멤버(${ss.studyList[0]['studyUserList'].length}명)',
                        style: f16bw700,
                      ),
                      const SizedBox(height: 10,),
                      Obx(() => ListView.builder(
                          shrinkWrap: true,
                          itemCount: ss.studyList[0]['studyUserList'].length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    ss.studyList[0]['studyUserList'][index] == ss.studyList[0]['studyHostDocId']?
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
                                    ):
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
                                      /// Cached 네트워크 이미지
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
                                  ],
                                ),
                                const SizedBox(height: 10,)
                              ],
                            );
                          }
                      ))

                    ],
                  ),),


                const SizedBox(
                  height: 200,
                ),
              ],
            ),
          );
  }
}

class noticeItem extends StatelessWidget {
  final PostInfo postInfo;
  final bool studypost; // post가 스터디인지 라운지인지 true스터디 false 라운지

  noticeItem({required this.postInfo, required this.studypost});

  String _text(String title) {
    if (title.length > 10) {
      return title.substring(0, 10) + '...';
    } else {
      return title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Get.to(PostViewPage(postInfo: postInfo, studypost: studypost));
      },
      child: Padding(
          padding: EdgeInsets.only(left: 18, right: 31, top: 10, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 33,
                height: 19,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xff3648EB)),
                child: Center(
                  child: Text(
                    '공지',
                    style: f10w700,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(_text(postInfo.title), style: f12bw700),
              ),
              Spacer(),
              Text(postInfo.date, style: f8gw500),
            ],
          )),
    );
  }
}



