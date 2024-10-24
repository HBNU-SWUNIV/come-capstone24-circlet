import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/provider/comment_state.dart';
import 'package:circlet/provider/lounge_post_state.dart';
import 'package:circlet/screen/lounge/edit/lounge_post_edit_page.dart';
import 'package:circlet/screen/post/post_image_page.dart';
import 'package:circlet/screen/profile/profile/other_user_profile_page.dart';
import 'package:circlet/screen/profile/profile/user_profile_page.dart';
import 'package:circlet/util/font/font.dart';
import 'package:circlet/util/loadingScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../../components/markdown/code.dart';
import '../../../provider/study_post_state.dart';
import '../../../provider/user_state.dart';
import 'package:circlet/dialog/dialog.dart';

class LoungeViewPage extends StatefulWidget {
  @override
  State<LoungeViewPage> createState() => _LoungeViewPageState();
  final Map<String, dynamic> postInfo;

  LoungeViewPage({required this.postInfo});
}

class _LoungeViewPageState extends State<LoungeViewPage> {
  final PageController controller = PageController();
  int currentPage = 0;

  TextEditingController textEditingController = TextEditingController();
  UserState us = Get.find<UserState>();
  bool isSubmitting = false;
  bool isLikeButtonDisabled = false;
  bool reload = false; // 댓글을 등록했으면 result true반환
  LoungePostState lps = Get.put(LoungePostState());
  CommentState cs = Get.put(CommentState());
  final sps = Get.put(StudyPostState());
  bool isSubmittingPost = false;
  bool isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _initializeComments();
  }

  Future<void> _initializeComments() async {
    await cs.fetchInitialComments(widget.postInfo['docId']);
    setState(() {});
  }

  /// 댓글갯수 업데이트
  Future<void> _updateCommentCount(int increment) async {
    try {
      await FirebaseFirestore.instance
          .collection('loungePostInfo')
          .doc(widget.postInfo['docId'])
          .update({
        'commentCount': FieldValue.increment(increment),
      });
      // lps 상태 업데이트
      lps.updateCommentCount(
          widget.postInfo['docId'], cs.commentList.length + increment);
      setState(() {});
    } catch (e) {
    }
  }

  /// 댓글 삭제
  Future<void> deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('comment')
          .doc(commentId)
          .delete();

      // 댓글 수 감소
      await _updateCommentCount(-1);
      cs.commentList.removeWhere((comment) => comment['docId'] == commentId);
      reload = true;
    } catch (e) {
    } finally {
      // 댓글 목록을 새로 고침
      _initializeComments();
    }
  }

  /// 댓글등록 함수
  Future<void> sendComment() async {
    if (textEditingController.text.isNotEmpty && !isSubmitting) {
      Future.delayed(Duration(seconds: 2));
      setState(() {
        isSubmitting = true; // 버튼 비활성화
      });

      reload = true;
      String commentText = textEditingController.text;
      textEditingController.clear();
      CollectionReference ref =
      FirebaseFirestore.instance.collection('comment');
      final DateTime now = DateTime.now();
      String formattedDate =
      DateFormat('yyyy년 M월 d일 a h:mm', 'ko_KR').format(now);

      try {
        // 댓글 데이터 데이터베이스에 추가
        DocumentReference docRef = await ref.add({
          'postId': widget.postInfo['docId'], // 포스트 id
          'docId': '', // docId는 나중에 업데이트되므로 현재 빈 문자열
          'userDocId': us.userList[0]['docId'],
          'nickname': us.userList[0]['nickname'],
          'comment': commentText, // 댓글 내용
          'date': formattedDate,
          'createDate': '$now',
        });
        await docRef.update({'docId': docRef.id}); // docId 추가
        await _updateCommentCount(1);
      } catch (e) {
      } finally {
        setState(() {
          isSubmitting = false; // 버튼 활성화
          _initializeComments(); // 댓글 목록 초기화
        });
      }
    }
  }

  void _navigateToEditPage() async {
    final result =
    await Get.to(() => LoungePostEditPage(postInfo: widget.postInfo));
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        widget.postInfo['title'] = result['title'];
        widget.postInfo['content'] = result['content'];
        widget.postInfo['imagePaths'] = result['imagePaths'];
        widget.postInfo['category'] = result['category'];
        widget.postInfo['code'] = result['code'];
        widget.postInfo['language'] = result['language'];
        reload = true;
      });
    }
  }

  /// 게시글 신고 데베에 저장하는 함수
  Future<void> _savePostReport(TextEditingController controller) async {
    if (isSubmittingPost) return;

    setState(() {
      isSubmittingPost = true;
    });

    String reportReason = controller.text.trim();

    if (reportReason.isNotEmpty) {
      String docId = FirebaseFirestore.instance
          .collection('postReport')
          .doc()
          .id; // 문서 ID 생성
      DateTime createdAt = DateTime.now(); // 신고 시간

      try {
        await FirebaseFirestore.instance
            .collection('postReport')
            .doc(docId) // 지정된 docId로 문서 생성
            .set({
          'createdAt': createdAt, // 신고 시간
          'docId': docId, // 문서 ID
          'reportReason': reportReason, // 신고 사유
          'result': '진행 중', // 초기 신고 결과 상태
          'studyId': 'Lounge', // 신고된 스터디 ID
          'userId': us.userList[0]['docId'], // 신고자 ID
          'postId': widget.postInfo['docId'], // 게시글 ID
          'resultDate': ''
        });

        // 신고 제출 후 다이얼로그 닫기
        Get.back();
      } catch (e) {
      } finally {
        setState(() {
          isSubmittingPost = false;
        });
      }
    } else {
      setState(() {
        isSubmittingPost = false;
      });
    }
  }

  /// 게시글 댓글 데베에 저장하는 함수
  Future<void> _saveCommentReport(TextEditingController controller, String id) async {
    if (isSubmittingComment) return;

    setState(() {
      isSubmittingComment = true;
    });

    ///  reportReason 가져오기
    String reportReason = controller.text;

    /// 문서 추가
    if (reportReason.isNotEmpty) {
      String docId = FirebaseFirestore.instance
          .collection('commentReport')
          .doc()
          .id;

      /// 문서 ID 생성
      DateTime createdAt = DateTime.now(); // 신고 시간

      try {
        await FirebaseFirestore.instance
            .collection('commentReport')
            .doc(docId)

        /// 지정된 docId로 문서 생성
            .set({
          'createdAt': createdAt,/// 신고 시간
          'docId': docId,/// 문서 ID
          'reportReason': reportReason,/// 신고 사유
          'result': '진행 중',/// 초기 신고 결과 상태
          'studyId': 'Lounge',/// 신고된 스터디 ID
          'userId': us.userList[0]['docId'],/// 신고자 ID
          'postId': widget.postInfo['docId'],/// 게시글 ID
          'commentId': id,
          'resultDate': ''
        });
      } catch (e) {
      } finally {
        setState(() {
          isSubmittingComment = false;
        });
      }
      Get.back();
    } else {
      setState(() {
        isSubmittingComment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLiked =
    widget.postInfo['likeList'].contains(us.userList[0]['docId']);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Center(
            child: Text('게시글',
                style: f22bw500)),
        leading: GestureDetector(
          child:
          SvgPicture.asset('assets/icon/leftArrow.svg', fit: BoxFit.none),
          onTap: () {
            var res;
            if (reload) res = true;
            Get.back(result: res);
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 6),
            child: PopupMenuButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                icon: SvgPicture.asset('assets/icon/Menu.svg'),
                itemBuilder: (BuildContext context) {
                  bool isPostAuthor =
                      widget.postInfo['userDocId'] == us.userList[0]['docId'];
                  return <PopupMenuEntry>[
                    if (isPostAuthor) ...[
                      PopupMenuItem(
                        value: '게시글 수정하기',
                        onTap: _navigateToEditPage,
                        child: Center(
                          child: Text(
                              '수정하기',
                              style: f12bw500
                          ),
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: '게시글 삭제',
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection('loungePostInfo')
                              .doc(widget.postInfo['docId'])
                              .delete();
                          Get.back(result: true); // 삭제 후 이전 페이지로 이동
                        },
                        child: Center(
                          child: Text('삭제하기', style: f12rw500),
                        ),
                      ),
                    ] else
                      PopupMenuItem(
                        value: '게시글 신고',
                        onTap: ()  async{
                          TextEditingController reportReasonController1 = TextEditingController();
                          showReportDialog(context, reportReasonController1, () async{
                            _savePostReport(reportReasonController1);
                          });
                        },
                        child: Center(
                          child: Text('신고하기', style: f12rw500),
                        ),
                      ),
                  ];
                }),
          )
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            color: Color(0xffEBEBEB),
            height: 1,
            thickness: 1,
          ),
        ),
      ),
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 15),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (widget.postInfo['userDocId'] ==
                                    us.userList[0]['docId']) {
                                  Get.to(UserProfilePage());
                                } else {
                                  sps.post.value = [widget.postInfo];
                                  Get.to(OtherUserProfilePage());
                                }
                              },
                              child: Container(
                                width: 45,
                                height: 45,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${widget.postInfo['userDocId']}?alt=media',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Center(child: LoadingScreen()),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                          'assets/image/default_profile.png',
                                          // 에셋 경로를 지정
                                          fit: BoxFit.cover,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.postInfo['nickname'],
                                  style: f14bw700,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.postInfo['date'],
                                      // formattedDate 사용
                                      style: f8gw500,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                widget.postInfo['category'],
                                style: f10gw500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.postInfo['title'],
                              style: f20bw700,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      widget.postInfo['imagePaths'].isNotEmpty
                          ? Container(
                        height: 240,
                        child: PageView.builder(
                          controller: controller,
                          itemCount: widget.postInfo['imagePaths'].length,
                          itemBuilder: (context, index) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 14, right: 14),
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.to(() => PostImagePage(
                                            postInfo: widget.postInfo));
                                      },
                                      child: Container(
                                        width: Get.width,
                                        height: 220,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                                10)),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                          'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/post%2F${widget.postInfo['imagePaths'][index]}?alt=media',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Center(
                                                  child: LoadingScreen()),
                                          errorWidget:
                                              (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (widget
                                      .postInfo['imagePaths'].length >
                                      1)
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: Get.width /
                                              2.3,
                                          top: 210),
                                      child: SmoothPageIndicator(
                                          controller: controller,
                                          count: widget
                                              .postInfo['imagePaths']
                                              .length,
                                          effect: WormEffect(
                                              activeDotColor:
                                              Colors.white,
                                              dotWidth: 6,
                                              dotHeight: 6)),
                                    )
                                ],
                              )),
                        ),
                      )
                          : const SizedBox(),
                      SingleChildScrollView(
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              widget.postInfo['content'],
                              style: f13bw500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (widget.postInfo['code'] != null &&
                          widget.postInfo['code']!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Container(
                            child: MarkdownBody(
                              key: const Key("defaultmarkdownformatter"),
                              data: widget.postInfo['code'] ?? '',
                              selectable: true,
                              builders: {
                                'code': CodeElementBuilder(
                                    language: widget.postInfo['language']),
                              },
                            ),
                          ),
                        ),
                      const Divider(
                        color: Color(0xffEBEBEB),
                        height: 1,
                        thickness: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 19, top: 21, bottom: 16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (isLikeButtonDisabled) return;
                                isLikeButtonDisabled = true;
                                String id = us.userList[0]['docId'];
                                if (isLiked) {
                                  widget.postInfo['likeList'].remove(id);
                                } else {
                                  widget.postInfo['likeList'].add(id);
                                }
                                isLiked = !isLiked;
                                var newLikeCount = isLiked
                                    ? widget.postInfo['likeCount'] + 1
                                    : widget.postInfo['likeCount'] - 1;
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('loungePostInfo')
                                      .doc('${widget.postInfo['docId']}')
                                      .update({
                                    'likeList': widget.postInfo['likeList'],
                                    'likeCount': newLikeCount,
                                  });
                                  setState(() {
                                    widget.postInfo['likeCount'] = newLikeCount;
                                    isLikeButtonDisabled = false;
                                  });
                                  lps.fetchInitialPosts();
                                } catch (e) {
                                }
                              },
                              child: SvgPicture.asset(isLiked
                                  ? 'assets/icon/Heart.svg'
                                  : 'assets/icon/emptyHeart.svg'),
                            ),
                            const SizedBox(width: 5),
                            Text('${widget.postInfo['likeCount']}',
                                style: f12bw700),
                            const SizedBox(width: 6),
                            SvgPicture.asset('assets/icon/chat.svg'),
                            const SizedBox(width: 5),
                            Text('${cs.commentList.length}',
                                style: f12bw700),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Color(0xffEBEBEB),
                        height: 10,
                        thickness: 10,
                      ),
                      const SizedBox(height: 2),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: cs.commentList.length,
                        itemBuilder: (context, index) {
                          bool isCommentAuthor = cs.commentList[index]
                          ['nickname'] ==
                              us.userList[0]['nickname'];
                          return Padding(
                            padding:
                            EdgeInsets.only(left: 16, top: 10, right: 16),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),

                                        /// 댓글
                                        child: CachedNetworkImage(
                                          imageUrl:
                                          'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${cs.commentList[index]['userDocId']}?alt=media',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Center(child: LoadingScreen()),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                'assets/image/default_profile.png',
                                                // 에셋 경로를 지정
                                                fit: BoxFit.cover,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              cs.commentList[index]['nickname'] ==
                                                  ''
                                                  ? '탈퇴한 사용자'
                                                  : cs.commentList[index]
                                              ['nickname'],
                                              style: f13bw700
                                          ),
                                          Text(
                                              cs.commentList[index]['comment'],
                                              style: f12bw500
                                          ),
                                          Text(
                                              cs.commentList[index]['date'],
                                              style: f8gw500
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero),
                                      icon: SvgPicture.asset(
                                          'assets/icon/Menu.svg'),
                                      itemBuilder: (BuildContext context) =>
                                      isCommentAuthor
                                          ? // 댓글 작성자가 본인인 경우
                                      <PopupMenuEntry>[
                                        PopupMenuItem(
                                          value: '댓글 삭제',
                                          onTap: () async {
                                            await deleteComment(
                                                cs.commentList[index]
                                                ['docId']);
                                          },
                                          child: Center(
                                            child: Text(
                                              '삭제하기',
                                              style: f12rw500,
                                            ),
                                          ),
                                        ),
                                      ]
                                          : <PopupMenuEntry>[
                                        PopupMenuItem(
                                          value: '신고하기',
                                          onTap: () async{
                                            TextEditingController reportReasonController2 = TextEditingController();
                                            showReportDialog(context, reportReasonController2, () async{
                                              _saveCommentReport(reportReasonController2, cs.commentList[index]['docId']);
                                            });
                                          },
                                          child: Center(
                                            child: Text(
                                              '신고하기',
                                              style: f12rw500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Color(0xffEBEBEB),
                                  height: 15,
                                  thickness: 1,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 19.0),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Color(0xffF2F2F2)),
                          child: TextField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                              hintText: '댓글 달기...',
                              hintStyle: f10chw500,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 12.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      GestureDetector(
                        onTap: () async {
                          if (!isSubmitting &&
                              textEditingController.text.isNotEmpty) {
                            await sendComment(); // 댓글 등록 함수 호출
                          }
                        },
                        child: Container(
                          width: 56,
                          height: 37,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black),
                          child: Center(
                            child: Text(
                              '등록',
                              style: f14w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
