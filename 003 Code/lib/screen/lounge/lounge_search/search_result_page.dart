import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../util/font/font.dart';
import '../lounge/lounge_view_page.dart';

class SearchResultPage extends StatefulWidget {
  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  final TextEditingController _searchController = TextEditingController();
  RxList<Map<String, dynamic>> _searchResults = <Map<String, dynamic>>[].obs;
  RxBool _isLoading = false.obs;
  RxBool _hasError = false.obs;

  Future<void> _fetchSearchResults(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      _hasError.value = false;
      return;
    }

    _isLoading.value = true;
    _hasError.value = false;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('loungePostInfo')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      _searchResults.value = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      _searchResults.clear();
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  void _onSearch() {
    FocusScope.of(context).unfocus(); // 키보드를 닫습니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSearchResults(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                hintStyle: f15gw500,
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _onSearch,
                ),
              ),
              onSubmitted: (query) => _onSearch(),
            ),
          ),
          Obx(() {
            if (_isLoading.value) {
              return Center(child: CircularProgressIndicator());
            } else if (_hasError.value) {
              return Center(child: Text('검색 결과가 없습니다', style: f17bw500));
            } else if (_searchResults.isEmpty) {
              return Center(child: Text('검색 결과가 없습니다', style: f17bw500));
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final post = _searchResults[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => LoungeViewPage(postInfo: post));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15, top: 26, bottom: 10),
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      child: post['authorImage'] != null && post['authorImage'] != ''
                                          ? Image.network(
                                        post['authorImage'],
                                        fit: BoxFit.cover,
                                        width: 40,
                                        height: 40,
                                      )
                                          : Image.asset('assets/image/default_profile.png'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    post['author'] ?? '알 수 없음',
                                    style: f14bw700,
                                  ),
                                ],
                              ),
                            ),
                            Container(
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
                                    style: f14bw500,
                                  ),
                                  const SizedBox(height: 16),
                                  if (post['imagePaths'] != null && post['imagePaths'].isNotEmpty)
                                    Stack(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width - 28,
                                          height: 220,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.network(
                                              'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/post%2F${post['imagePaths'][0]}?alt=media',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        if (post['imagePaths'].length > 1)
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
                                                  style: f12w700,
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
                            const Divider(color: Color(0xffEBEBEB), height: 1, thickness: 1),
                            Padding(
                              padding: EdgeInsets.only(left: 21, top: 11, bottom: 16),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _onHeartTap(post);
                                    },
                                    child: SvgPicture.asset(
                                      post['likeList'].contains('user_id_placeholder') // Replace with actual user ID
                                          ? 'assets/icon/Heart.svg'
                                          : 'assets/icon/emptyHeart.svg',
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text('${post['likeCount']}',
                                      style: f12bw700),
                                  const SizedBox(width: 6),
                                  SvgPicture.asset('assets/icon/chat.svg'),
                                  const SizedBox(width: 5),
                                  Text('${post['commentCount']}',
                                      style: f12bw700),
                                  Spacer(),
                                  Text(post['category'] ?? '',
                                      style: f10gw500),
                                  const SizedBox(width: 29),
                                ],
                              ),
                            ),
                            const Divider(color: Color(0xffEBEBEB), height: 10, thickness: 10),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  void _onHeartTap(Map<String, dynamic> postInfo) async {
    // Implement like button tap logic here
  }
}
