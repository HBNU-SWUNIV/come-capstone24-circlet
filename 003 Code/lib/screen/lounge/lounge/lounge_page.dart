import 'package:circlet/provider/study_post_state.dart';
import 'package:circlet/screen/lounge/lounge_search/search_result_page.dart';
import 'package:circlet/util/font/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/provider/lounge_post_state.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:circlet/screen/lounge/create/lounge_post_create_page.dart';
import 'package:circlet/screen/lounge/lounge/lounge_view_page.dart';
import '../../../util/loadingScreen.dart';
import '../../profile/profile/other_user_profile_page.dart';
import '../../profile/profile/user_profile_page.dart';

class LoungePage extends StatefulWidget {
  @override
  State<LoungePage> createState() => _LoungePageState();
}

class _LoungePageState extends State<LoungePage> with TickerProviderStateMixin {
  late TabController _LoungePageTabController;
  late ScrollController _scrollController1;
  UserState us = Get.find<UserState>();
  LoungePostState lps = Get.put(LoungePostState());
  bool isLikeButtonDisabled = false;
  String _searchQuery = "";
  String _sortBy = 'latest'; // 정렬순
  final sps = Get.put(StudyPostState());
  DocumentSnapshot? lastDocuments;
  late bool hasMore = false;
  int pageSize = 3;
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _LoungePageTabController = TabController(length: 6, vsync: this);
    _scrollController1 = ScrollController();
    _scrollController1.addListener(_scrollListener);
    _scrollController1.addListener(() {
      _scrollPosition = _scrollController1.position.pixels;  /// 스크롤 위치 저장
    });
    Future.delayed(Duration.zero, () async {
      await fetchInitialPosts();
      if (_scrollPosition != 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController1.jumpTo(_scrollPosition);
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollPosition = _scrollController1.position.pixels;
    _LoungePageTabController.dispose();
    _scrollController1.dispose();
    super.dispose();
  }

  void _scrollListener() async{
    if (_scrollController1.position.pixels >= _scrollController1.position.maxScrollExtent) {
      if (hasMore) {
        await fetchMorePosts();
      }
    }
  }
  Future<void> fetchInitialPosts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('loungePostInfo')
          .orderBy('createDate', descending: true)
          .limit(pageSize)
          .get();

      final List<DocumentSnapshot> documents = querySnapshot.docs;
      if (documents.isNotEmpty) {
        lastDocuments = documents.last;
        lps.loungePostList.value = documents
            .map((doc) => _parsePostData(doc.data() as Map<String, dynamic>))
            .toList();
        setState(() {
          hasMore = documents.length == pageSize; // 페이지 수에 따라 hasMore 설정
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController1.jumpTo(_scrollPosition);
          });
        });
      } else {
        setState(() {
          lastDocuments = null; // 문서가 없는 경우 lastDocument를 null로 설정
          hasMore = false; // 더 이상 가져올 포스트가 없는 경우
        });
      }

    } catch (e) {
    }
  }


  Future<void> fetchMorePosts() async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('loungePostInfo')
          .orderBy('createDate', descending: true)
          .startAfterDocument(lastDocuments!)
          .limit(pageSize);

      QuerySnapshot querySnapshot = await query.get();
      final List<DocumentSnapshot> documents = querySnapshot.docs;

      if (documents.isNotEmpty) {
        lastDocuments = documents.last;
        lps.loungePostList.addAll(documents
            .map((doc) => _parsePostData(doc.data() as Map<String, dynamic>))
            .toList());
        setState(() {
          hasMore = documents.length == pageSize;
        });
      } else {
        setState(() {
          hasMore = false;
        });
      }
    } catch (e) {
    }
  }

  Map<String, dynamic> _parsePostData(Map<String, dynamic> data) {
    return {
      'docId': data['docId'] ?? '',
      'userDocId': data['userDocId'] ?? '',
      'nickname': data['nickname'] ?? '탈퇴한 사용자',
      'category': data['category'] ?? '',
      'title': data['title'] ?? '',
      'content': data['content'] ?? '',
      'date': data['date'] ?? '',
      'imagePaths': List<String>.from(data['imagePaths'] ?? []),
      'likeList': List<String>.from(data['likeList'] ?? []),
      'likeCount': (data['likeCount'] ?? 0) is int ? data['likeCount'] : 0,
      'commentCount': (data['commentCount'] ?? 0) is int ? data['commentCount'] : 0,
      'authorImage': data['authorImage'] ?? '',
      'code' : data['code'] ?? '',
      'language' : data['language'] ?? ''
    };
  }


  Future<void> _onRefresh() async {
    // 데이터 새로고침 로직
    await fetchInitialPosts();
  }

  void _onHeartTap(Map<String, dynamic> postInfo) async {
    bool isLiked = postInfo['likeList'].contains(us.userList[0]['docId']);
    if (isLikeButtonDisabled) return;
    isLikeButtonDisabled = true;
    String id = us.userList[0]['docId'];
    if (isLiked) {
      postInfo['likeList'].remove(id);
    } else {
      postInfo['likeList'].add(id);
    }
    isLiked = !isLiked;
    var newLikeCount =
    isLiked ? postInfo['likeCount'] + 1 : postInfo['likeCount'] - 1;
    try {
      await FirebaseFirestore.instance
          .collection('loungePostInfo')
          .doc('${postInfo['docId']}')
          .update({
        'likeList': postInfo['likeList'],
        'likeCount': newLikeCount,
      });
      setState(() {
        postInfo['likeCount'] = newLikeCount;
        isLikeButtonDisabled = false;
      });
    } catch (e) {
    }
  }

  void _showFilterMenu() async {
    final selectedSort = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('최신순'),
              onTap: () => Get.back(result: 'latest'),
            ),
            ListTile(
              title: Text('좋아요순'),
              onTap: () => Get.back(result: 'likes'),
            ),
            ListTile(
              title: Text('댓글순'),
              onTap: () => Get.back(result: 'comments'),
            ),
          ],
        );
      },
    );

    if (selectedSort != null) {
      setState(() {
        _sortBy = selectedSort;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, /// 뒤로가기 실패
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('개발자 라운지', style: f20bw500),

          backgroundColor: Colors.white,
          actions: [
            GestureDetector(
              onTap: _showFilterMenu,
              child: SvgPicture.asset(
                'assets/icon/filter.svg',
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => SearchResultPage());
              },
              child: SvgPicture.asset('assets/icon/search.svg'),
            ),
            const SizedBox(width: 14),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Column(
              children: [
                Divider(
                  color: Color(0xffEBEBEB),
                  height: 1,
                  thickness: 1,
                ),
                TabBar(
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: Colors.black),
                    insets: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  labelPadding: EdgeInsets.symmetric(horizontal: 13),
                  indicatorColor: Colors.black,
                  indicatorWeight: 2,
                  dividerColor: Color(0xffEBEBEB),
                  labelStyle: f9bw700,
                  unselectedLabelColor: Color(0xff6E6E6E),
                  indicatorSize: TabBarIndicatorSize.values.first,
                  controller: _LoungePageTabController,
                  tabs: [
                    Tab(text: '전체'),
                    Tab(text: '취업'),
                    Tab(text: 'Q&A'),
                    Tab(text: '개발'),
                    Tab(text: '홍보'),
                    Tab(text: '사는얘기'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _LoungePageTabController,
          children: [
            _buildPostList(category: '전체'), // 전체
            _buildPostList(category: '취업'), // 취업
            _buildPostList(category: 'Q&A'), // Q&A
            _buildPostList(category: '개발'), // 개발
            _buildPostList(category: '홍보'), // 홍보
            _buildPostList(category: '사는얘기'), // 사는얘기
          ],
        ),
        floatingActionButton: Container(
          width: 66,
          height: 66,
          child: FloatingActionButton(
            onPressed: () async {
              await Get.to(() => LoungePostCreatePage(
                  selectedTab: _LoungePageTabController.index))?.then((value){
                if(value){
                  setState(() async{
                    _scrollPosition = 0;
                    await fetchInitialPosts();
                  });
                }
              });

            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                Container(child: SvgPicture.asset('assets/icon/plus.svg')),
                Text('작성', style: f16w500),
              ],
            ),
            shape: CircleBorder(),
            backgroundColor: Color(0xff3648EB),
          ),
        ),
      ),
    );
  }

  Widget _buildPostList({required String category}) {

    return Obx(() {
      var filteredPosts = lps.loungePostList.where((post) {
        return category == '전체' || post['category'] == category;
      }).toList();

      if (_searchQuery.isNotEmpty) {
        filteredPosts = filteredPosts
            .where((post) => (post['title'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
            .toList();
      }

      // 정렬
      if (_sortBy == 'likes') {
        filteredPosts.sort(
                (a, b) => (b['likeCount'] ?? 0).compareTo(a['likeCount'] ?? 0));
      } else if (_sortBy == 'comments') {
        filteredPosts.sort((a, b) =>
            (b['commentCount'] ?? 0).compareTo(a['commentCount'] ?? 0));
      } else {
        filteredPosts
            .sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
      }

      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _scrollController1,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: filteredPosts.isEmpty ? 1 : filteredPosts.length,
          itemBuilder: (context, index) {
            if (filteredPosts.isEmpty) {
              return _buildEmptyState();
            }

            final post = filteredPosts[index];
            return GestureDetector(
              onTap: () async {
                await Get.to(() => LoungeViewPage(postInfo: post))?.then((value) {
                  if (value) {
                    setState(() async {
                      _scrollPosition = 0;
                      await fetchInitialPosts();
                    });
                  }
                });

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
                                            Image.asset(
                                              'assets/image/default_profile.png', /// 사용자 이미지가 없으면 기본 이미지
                                              fit: BoxFit.cover,
                                            ),
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
                                if (post['userDocId'] ==
                                    us.userList[0]['docId']) {
                                  Get.to(() => UserProfilePage());
                                } else {
                                  sps.post.value = [post];
                                  Get.to(() => OtherUserProfilePage());
                                }
                              },
                            ),),
                          Spacer(),
                          Text(
                            post['date'] ?? '',
                            style: TextStyle(
                              color: Color(0xff9B9B9B),
                              fontSize: 9,
                            ),
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
                                        borderRadius: BorderRadius.circular(30),
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
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Text(
            '게시물이 없습니다.',
            style: f16bw700,
          ),
        )
      ],
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
}
