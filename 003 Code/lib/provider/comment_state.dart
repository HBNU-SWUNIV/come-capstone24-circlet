import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CommentState extends GetxController {
  final commentList = [].obs;
  final postId = ''.obs; // 댓글이 달린 게시글 아이디
  final docId = ''.obs; // 댓글 docId
  final nickname = ''.obs; // 댓글 작성자
  final comment = ''.obs; // 댓글 내용
  final date = ''.obs; // 댓글 생성일자 한글
  final createDate = ''.obs; // 댓글 생성일자
  final userDocId = ''.obs;

  DocumentSnapshot? lastDocument;
  bool isLoading = true;


  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchInitialComments(String id) async {
    try {
      // 'postId'로 필터링
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('comment')
          .where('postId', isEqualTo: id)
          .get();

      final List<DocumentSnapshot> documents = querySnapshot.docs;
      if (documents.isNotEmpty) {
        lastDocument = documents.last;

        // 클라이언트 측에서 'createDate'로 내림차순 정렬
        var fetchedComments = documents
            .map((doc) => _parseCommentData(doc.data() as Map<String, dynamic>))
            .toList();
        fetchedComments.sort((a, b) => a['createDate'].compareTo(b['createDate'])); // 내림차순 정렬

        commentList.value = fetchedComments;
      } else {
      }
      isLoading = false;
    } catch (e) {
      print('Error fetching initial comments: $e');
    }
  }


  // Comment 데이터 가져오기
  Map<String, dynamic> _parseCommentData(Map<String, dynamic> data) {
    return {
      'postId': data['postId'] ?? '',
      'docId': data['docId'] ?? '',
      'nickname': data['nickname'] ?? '',
      'comment': data['comment'] ?? '',
      'date': data['date'] ?? '',
      'createDate': data['createDate'] ?? '',
      'userDocId' : data['userDocId'] ?? ''
    };
  }
}
