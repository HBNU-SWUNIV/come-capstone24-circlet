import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LoungePostState extends GetxController {
  final loungePostList = [].obs;
  final docId = ''.obs;
  final author = ''.obs;
  final category = ''.obs;
  final title = ''.obs;
  final content = ''.obs;
  final date = ''.obs;
  final code = ''.obs;
  final language = ''.obs;
  final createDate = ''.obs;
  final imagePaths = <String>[].obs;
  final likeList = <String>[].obs;
  final likeCount = 0.obs;
  final commentCount = 0.obs;
  final authorImage = ''.obs;

  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  final int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
  }

  void updateCommentCount(String postId, int commentCount) {
    int index = loungePostList.indexWhere((post) => post['docId'] == postId);
    if (index != -1) {
      loungePostList[index]['commentCount'] = commentCount;
    }
  }

  Future<bool> fetchInitialPosts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('loungePostInfo')
          .orderBy('createDate', descending: true)
          .limit(pageSize)
          .get();

      final List<DocumentSnapshot> documents = querySnapshot.docs;
      if (documents.isNotEmpty) {
        lastDocument = documents.last;
        loungePostList.value = documents
            .map((doc) => _parsePostData(doc.data() as Map<String, dynamic>))
            .toList();
        hasMore = documents.length == pageSize; // 페이지 수에 따라 hasMore 설정
      } else {
        lastDocument = null; // 문서가 없는 경우 lastDocument를 null로 설정
        hasMore = false; // 더 이상 가져올 포스트가 없는 경우
      }

      return hasMore; // hasMore 값 반환
    } catch (e) {
      print('Error fetching initial posts: $e');
      return false; // 에러 발생 시 false 반환
    }
  }



  Future<FetchMoreResult> fetchMorePosts(DocumentSnapshot? lastDoc) async {
    // lastDoc이 null인 경우를 체크
    if (lastDoc == null || !hasMore) return FetchMoreResult(null, false);

    try {
      Query query = FirebaseFirestore.instance
          .collection('loungePostInfo')
          .orderBy('createDate', descending: true)
          .startAfterDocument(lastDoc)
          .limit(pageSize);

      QuerySnapshot querySnapshot = await query.get();
      final List<DocumentSnapshot> documents = querySnapshot.docs;

      if (documents.isNotEmpty) {
        lastDocument = documents.last;
        loungePostList.addAll(documents
            .map((doc) => _parsePostData(doc.data() as Map<String, dynamic>))
            .toList());
        hasMore = documents.length == pageSize;

        return FetchMoreResult(lastDocument, hasMore);
      } else {
        hasMore = false;
        return FetchMoreResult(null, false);
      }
    } catch (e) {
      print('Error fetching more posts: $e');
    }
    return FetchMoreResult(null, false);
  }


  void updatePostInfo(Map<String, dynamic> updatedPostInfo) {
    final index = loungePostList.indexWhere((post) => post['docId'] == updatedPostInfo['docId']);
    if (index != -1) {
      loungePostList[index] = _parsePostData(updatedPostInfo);
    }
  }

  Map<String, dynamic> _parsePostData(Map<String, dynamic> data) {
    return {
      'docId': data['docId'] ?? '',
      'userDocId': data['userDocId'] ?? '',
      'nickname': data['nickname'] ?? '',
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
}

class FetchMoreResult {
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  FetchMoreResult(this.lastDocument, this.hasMore);
}

