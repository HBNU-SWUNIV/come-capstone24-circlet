import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class StudyPostState extends GetxController {
  final studyPostList = [].obs;
  final studyNoticePost3 = [].obs;
  final studyNoticePostList = [].obs;  /// 공지사항 포스트 리스트
  final studyWelcomePostList = [].obs; /// 가입인사 포스트 리스트
  final studyFreePostList = [].obs; /// 자유 포스트 리스트
  final studyQuestionPostList = [].obs; /// 질문
  final studyMeetingPostList = [].obs; /// 모임후기
  final studyResourcePostList = [].obs; /// 자료실
  var categoryPostList = [].obs;
  final docId = ''.obs;
  final author = ''.obs;
  final category = ''.obs;
  final title = ''.obs;
  final content = ''.obs;
  final date = ''.obs;
  final createDate = ''.obs;
  final imagePaths = <String>[].obs;
  final likeList = <String>[].obs;
  final likeCount = 0.obs;
  final commentCount = 0.obs;
  final authorImage = ''.obs;
  final post = [].obs; /// 스터디 포스트 1개만 넣는 곳

  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  final int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
  }
  void updateStudyCommentCount(String postId, int commentCount) {
    int index = studyPostList.indexWhere((post) => post['docId'] == postId);
    if (index != -1) {
      studyPostList[index]['commentCount'] = commentCount;
    }
  }


  void updateStudyPostInfo(Map<String, dynamic> updatedPostInfo) {
    final index = studyPostList.indexWhere((post) => post['docId'] == updatedPostInfo['docId']);
    if (index != -1) {
      studyPostList[index] = _parsePostData(updatedPostInfo);
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
    };
  }
}
