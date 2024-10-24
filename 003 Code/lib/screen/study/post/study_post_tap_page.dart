import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/screen/study/post/study_post_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../provider/study_post_state.dart';
import '../../../provider/user_state.dart';
import '../../../util/font/font.dart';
import '../../../util/loadingScreen.dart';
import '../../profile/profile/other_user_profile_page.dart';
import '../../profile/profile/user_profile_page.dart';
import 'study_post_create.dart';

class StudyPostTapPage extends StatefulWidget {
  int selectedCategoryIndex ;

  StudyPostTapPage({
    required this.selectedCategoryIndex,
  });

  @override
  _StudyPostTapPageState createState() => _StudyPostTapPageState();
}

class _StudyPostTapPageState extends State<StudyPostTapPage> {
  List<String> boardName = [
    '공지사항',
    '가입인사',
    '자유',
    '질문',
    '모임후기',
    '자료실'
  ]; // 카테고리 이름
  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot? lastDocument;
  final int pageSize = 20;
  late ScrollController _scrollController = ScrollController();
  FirebaseStorage storage =
  FirebaseStorage.instanceFor(bucket: 'gs://circlet-9c202.appspot.com');
  StudyPostState sps = Get.put(StudyPostState());
  UserState us = Get.put(UserState());
  StudyState ss = Get.put(StudyState());
  bool isLikeButtonDisabled = false;
  bool isHost = false;
  Map<String, DocumentSnapshot?> lastDocuments = {
    '공지사항': null,
    '가입인사': null,
    '자유': null,
    '질문': null,
    '모임후기': null,
    '자료실': null,
  };

  /// 카테고리마다 hasMore
  Map<String, bool> hasMoreMap = {
    '공지사항': true,
    '가입인사': true,
    '자유': true,
    '질문': true,
    '모임후기': true,
    '자료실': true,
  };

  bool isJoin = false;
  late int categoryIndex;
  @override
  void initState() {
    super.initState();
    if (ss.studyList[0]['studyUserList'].contains(us.userList[0]['docId']) ||
        isHost)
      setState(() {
        isJoin = true;
      });
    _scrollController = ScrollController(); // 초기화
    _scrollController.addListener(_scrollListener); // 리스너 등록
    Future.delayed(Duration.zero, () async {
      await fetchAllPosts();
      Future.wait(boardName.map((category) => fetchInitialPosts(category)));
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener); // 리스너 제거
    _scrollController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  /// 게시글 추가로 가져오는 함수(전체 제외)
  Future<void> fetchPostsByCategory(String category,
      {DocumentSnapshot? startAfter}) async {
    if (!hasMoreMap[category]!) return; /// 카테고리별로 hasMore 확인
    setState(() {
      isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('studyPostInfo').where('studyId', isEqualTo: ss.studyList[0]['docId'])
        .where('category', isEqualTo: category)
        .limit(pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    QuerySnapshot snapshot = await query.get();

    List<Map<String, dynamic>> postList =
    snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    // 'createDate'를 기준으로 내림차순 정렬
    postList.sort((a, b) => (b['createDate']).compareTo(a['createDate']));

    switch (category) {
      case '공지사항':
        sps.studyNoticePostList.value.addAll(postList);
        break;
      case '가입인사':
        sps.studyWelcomePostList.value.addAll(postList);
        break;
      case '자유':
        sps.studyFreePostList.value.addAll(postList);
        break;
      case '질문':
        sps.studyQuestionPostList.value.addAll(postList);
        break;
      case '모임후기':
        sps.studyMeetingPostList.value.addAll(postList);
        break;
      case '자료실':
        sps.studyResourcePostList.value.addAll(postList);
        break;
      default:
        break;
    }

    lastDocuments[category] =
    snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    hasMoreMap[category] = snapshot.docs.length == pageSize;

    setState(() {
      isLoading = false;
    });
  }

  /// 처음 게시글 가져오는 함수(전체 제외)
  Future<void> fetchInitialPosts(String category) async {
    setState(() {
      isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('studyPostInfo').where('studyId', isEqualTo: ss.studyList[0]['docId'])
        .where('category', isEqualTo: category)
        .limit(pageSize);

    QuerySnapshot snapshot = await query.get();

    List<Map<String, dynamic>> postList =
    snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    postList.sort((a, b) => (b['createDate']).compareTo(a['createDate']));

    switch (category) {
      case '공지사항':
        sps.studyNoticePostList.value = postList;
        break;
      case '가입인사':
        sps.studyWelcomePostList.value = postList;
        break;
      case '자유':
        sps.studyFreePostList.value = postList;
        break;
      case '질문':
        sps.studyQuestionPostList.value = postList;
        break;
      case '모임후기':
        sps.studyMeetingPostList.value = postList;
        break;
      case '자료실':
        sps.studyResourcePostList.value = postList;
        break;
      default:
        break;
    }

    lastDocuments[category] =
    snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    hasMoreMap[category] = snapshot.docs.length == pageSize;

    setState(() {
      isLoading = false;
    });
  }

  /// 전체 게시글 불러오기
  Future<void> fetchAllPosts() async {
    List<Map<String, dynamic>> allPosts = [];
    lastDocument = null; // lastDocument를 null로 초기화
    bool hasMore = true;

    setState(() {
      isLoading = true;
    });

    while (hasMore) {
      Query query = FirebaseFirestore.instance
          .collection('studyPostInfo')
          .where('studyId', isEqualTo: ss.studyList[0]['docId'])
          .orderBy('createDate', descending: true)
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      try {
        QuerySnapshot snapshot = await query.get();
        List<Map<String, dynamic>> postList =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        allPosts.addAll(postList);

        lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        hasMore = snapshot.docs.length == pageSize;
      } catch (e) {
        break; // 오류 발생 시 루프 중단
      }
    }

    sps.studyPostList.value = allPosts;

    setState(() {
      isLoading = false;
    });
  }



  Future<void> fetchMorePost() async {
    if (!hasMore) return; // 더 이상 로드할 게시글이 없는 경우 조기 반환

    setState(() {
      isLoading = true;
    });

    // 전체 게시글 컬렉션 쿼리
    Query query = FirebaseFirestore.instance
        .collection('studyPostInfo')
        .where('studyId', isEqualTo: ss.studyList[0]['docId'])
        .orderBy('createDate', descending: true)
        .limit(pageSize);

    // 마지막 문서로부터 이어서 로드
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    try {
      QuerySnapshot snapshot = await query.get();
      List<Map<String, dynamic>> newPosts = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      if (newPosts.isNotEmpty) {
        sps.studyPostList.value.addAll(newPosts);
        lastDocument = snapshot.docs.last; // 마지막 문서 업데이트
        hasMore = snapshot.docs.length == pageSize; // 더 로드할 수 있는 게시글이 있는지 확인
      } else {
        hasMore = false; // 더 이상 로드할 게시글이 없는 경우
      }
    } catch (e) {
      // 오류 처리
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      if (widget.selectedCategoryIndex != 0) {
        String selectedCategory = boardName[widget.selectedCategoryIndex - 1];
        fetchPostsByCategory(selectedCategory,
            startAfter: lastDocuments[selectedCategory]);
      }
      else
        fetchMorePost();
    }
  }

  void _onHeartTap(Map<String, dynamic> postInfo) async {
    if (isLikeButtonDisabled) return;
    isLikeButtonDisabled = true;
    String id = us.userList[0]['docId'];
    bool like = false;
    if (postInfo['likeList'].contains(id)) {
      postInfo['likeList'].remove(id);
    } else {
      postInfo['likeList'].add(id);
      like = true;
    }
    await FirebaseFirestore.instance
        .collection('studyPostInfo')
        .doc('${postInfo['docId']}')
        .update({'likeList': postInfo['likeList'].map((e) => e).toList()});

    var newLikeCount =
    like ? postInfo['likeCount'] + 1 : postInfo['likeCount'] - 1;

    try {
      await FirebaseFirestore.instance
          .collection('studyPostInfo')
          .doc('${postInfo['docId']}')
          .update({
        'like': true,
        'likeCount': newLikeCount,
      });
      setState(() {
        postInfo['likeCount'] = newLikeCount;
        isLikeButtonDisabled = false;
      });
    } catch (e) {
    }
  }

  void _onCategoryTap(int index) {
    setState(() {
      widget.selectedCategoryIndex = index;
      if (index == 0) {
        // '전체' 탭 클릭 시 모든 게시물 가져오기
        fetchAllPosts();
      } else {
        // 나머지 카테고리 클릭 시 해당 카테고리의 게시물 가져오기
        String selectedCategory = boardName[index - 1];
        fetchInitialPosts(selectedCategory);
      }
    });
  }

  Future<void> _onRefresh() async {
    if (widget.selectedCategoryIndex == 0)
      await fetchAllPosts();
    else {
      String selectedCategory = boardName[widget.selectedCategoryIndex - 1];
      await fetchInitialPosts(selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading ? Scaffold(
      floatingActionButton:
      isJoin || isHost ? _buildFloatingActionButton() : null,
      body: isJoin || isHost
          ? Obx(() {
        return RefreshIndicator(
          onRefresh: () => _onRefresh(),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCategoryTabs(),
                _buildPostList(),
              ],
            ),
          ),
        );
      })
          : Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            const Center(
              child: Text('가입되지 않았습니다.', style: f20bw700),
            ),
            const SizedBox(height: 20),
            const Text('스터디에 가입 후 게시판을 이용해보세요.', style: f14gw500),
          ],
        ),
      ),
    ) : LoadingScreen();
  }

  Widget _buildCategoryTabs() {
    var board = ['전체', '공지사항', '가입인사', '자유', '질문', '모임후기', '자료실'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(board.length, (index) {
          return GestureDetector(
            onTap: () {
              _onCategoryTap(index);
            },
            child: Container(
              width: board[index].length == 2
                  ? 38
                  : board[index].length == 3
                  ? 44
                  : board[index].length == 4
                  ? 50
                  : 56,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.selectedCategoryIndex == index
                    ? Colors.blue
                    : Colors.grey.shade300,
              ),
              child: Center(
                child: Text(
                  board[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'NotoSans',
                    color: widget.selectedCategoryIndex == index
                        ? Colors.white
                        : Color(0xff6E6E6E),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPostList() {
    var board = ['전체', '공지사항', '가입인사', '자유', '질문', '모임후기', '자료실'];
    // 선택된 카테고리 이름 가져오기
    List<Map<String, dynamic>> posts = [];
    String selectedCategory = board[widget.selectedCategoryIndex];
    switch (selectedCategory) {
      case '전체':
        posts = List<Map<String, dynamic>>.from(sps.studyPostList);
        break;
      case '공지사항':
        posts = List<Map<String, dynamic>>.from(sps.studyNoticePostList);
        break;
      case '가입인사':
        posts = List<Map<String, dynamic>>.from(sps.studyWelcomePostList);
        break;
      case '자유':
        posts = List<Map<String, dynamic>>.from(sps.studyFreePostList);
        break;
      case '질문':
        posts = List<Map<String, dynamic>>.from(sps.studyQuestionPostList);
        break;
      case '모임후기':
        posts = List<Map<String, dynamic>>.from(sps.studyMeetingPostList);
        break;
      case '자료실':
        posts = List<Map<String, dynamic>>.from(sps.studyResourcePostList);
        break;
      default:
        posts = [];
        break;
    }

    return (posts.isEmpty)
        ? Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            '최근 게시글이 없어요',
            style: f20bw700,
          ),
          const SizedBox(height: 20),
          Text(
            '게시글을 작성해보는 건 어떠신가요?',
            style: f14gw500,
          ),
        ],
      ),
    )
        : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () async {
            sps.post.value = [post];
          },
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        child: GestureDetector(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${post['userDocId']}?alt=media',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Center(child: LoadingScreen()),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  post['nickname'] ?? '탈퇴한 사용자',
                                  style: f14bw700
                              ),
                            ],
                          ),
                          onTap: () {
                            sps.post.value = [post];
                            if (post['userDocId'] ==
                                us.userList[0]['docId']) {
                              Get.to(() => UserProfilePage());
                            } else {
                              Get.to(() => OtherUserProfilePage());
                            }
                          },
                        ),
                      ),
                      Spacer(),
                      Text(
                        post['date'] ?? '',
                        style: f9dw500,
                      ),
                      const SizedBox(width: 10)
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(left: 21, right: 21),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'] ?? '',
                        style: f16bw700,
                      ),
                      const SizedBox(height: 5),
                      Text(
                          post['content'] ?? '',
                          style: f14bw500
                      ),
                      const SizedBox(height: 16),
                      if (post['imagePaths'] != null &&
                          post['imagePaths'].isNotEmpty)
                        Stack(
                          children: [
                            Container(
                              width: Get.width - 28,
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl:
                                  'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/post%2F${post['imagePaths'][0]}?alt=media',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Center(child: LoadingScreen()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            if (post['imagePaths'] != null &&
                                post['imagePaths'].length > 1)
                              Positioned(
                                top: 7,
                                right: 7,
                                child: Container(
                                  width: 29,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(30),
                                    color: Color(0xff7E889C),
                                  ),
                                  child: Center(
                                    child: Text(
                                        '${post['imagePaths'].length}',
                                        style: f12w700
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 23),
                _ThinBottomLine(),
                Padding(
                  padding: EdgeInsets.only(left: 21, top: 11, bottom: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _onHeartTap(post);
                        },
                        child: SvgPicture.asset(
                          post['likeList'] != null &&
                              post['likeList']
                                  .contains(us.userList[0]['docId'])
                              ? 'assets/icon/Heart.svg'
                              : 'assets/icon/emptyHeart.svg',
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text('${post['likeCount'] ?? 0}',
                          style: f12bw700),
                      const SizedBox(width: 6),
                      SvgPicture.asset('assets/icon/chat.svg'),
                      const SizedBox(width: 5),
                      Text('${post['commentCount'] ?? 0}',
                          style: f12bw700),
                      Spacer(),
                      Text(post['category'] ?? '',
                          style: f10gw500),
                      const SizedBox(width: 29),
                    ],
                  ),
                ),
                _ThickBottomLine(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ThinBottomLine() {
    return Container(
      color: Color(0xffEBEBEB),
      height: 1,
      width: double.infinity,
    );
  }

  Widget _ThickBottomLine() {
    return Container(
      color: Color(0xffEBEBEB),
      height: 10,
      width: double.infinity,
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 66,
      height: 66,
      child: ClipOval(
        child: FloatingActionButton(
          onPressed: () async {
            String? selectedTab1 = widget.selectedCategoryIndex == 0
                ? '게시판을 선택하세요'
                : boardName[widget.selectedCategoryIndex - 1];
            String? selectedTab2 = (widget.selectedCategoryIndex == 0 ||
                widget.selectedCategoryIndex == 1)
                ? '게시판을 선택하세요'
                : boardName[widget.selectedCategoryIndex - 1];

            bool? shouldReload = await Get.to(() => StudyPostCreatePage(
                studyId: ss.studyList[0]['docId'],
                selectedTab: isHost ? selectedTab1 : selectedTab2))
                ?.then((value) {
              setState(() {
                if (widget.selectedCategoryIndex == 0) {
                  fetchAllPosts();
                } else {
                  String selectedCategory =
                  boardName[widget.selectedCategoryIndex - 1];
                  fetchInitialPosts(selectedCategory);
                }
              });
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icon/plus.svg'),
              Text('작성', style: f16w500),
            ],
          ),
          backgroundColor: Color(0xff3648EB),
        ),
      ),
    );
  }
}
