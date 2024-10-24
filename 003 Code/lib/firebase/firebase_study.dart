import 'package:circlet/provider/study_state.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../components/components.dart';
import '../dialog/dialog.dart';
import '../provider/study_post_state.dart';
import 'firebase_user.dart';

final us = Get.put(UserState());
final ss = Get.put(StudyState());

///닉네임 중복 체크
Future<void> studyNameDuplicate(String studyName) async {
  final ss = Get.put(StudyState());
  CollectionReference ref = FirebaseFirestore.instance.collection('study');
  QuerySnapshot snapshot = await ref.where('studyName', isEqualTo: studyName).get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  ss.studyCheckName.value = allData.isEmpty?'0':'1';
}

/// 모든 스터디 정보 가져오기
Future<void> getStudyInfo() async {
  final ss = Get.put(StudyState());
  CollectionReference ref = FirebaseFirestore.instance.collection('study');
  QuerySnapshot snapshot = await ref.get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  ss.allStudyList.value = allData;
  getPopularStudy();
  getRecentStudy();
  getOtherStudy();
  getMorePopularStudy();
  getMoreRecentStudy();
  print('getStudyInfo 실행완료');
}

/// studyList의 docId값과 studyId값이 일치하는 문서 가져오기
Future<void> getStudyPost() async {
  final ss = Get.put(StudyState());
  final sps = Get.put(StudyPostState());

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot querySnapshot = await firestore
      .collection('studyPostInfo')
      .where('studyId', isEqualTo: ss.studyList[0]['docId'])
      .get();
  sps.studyPostList.clear();

  var postList = querySnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();
  postList.sort((a, b) => (b['createDate']).compareTo(a['createDate']));
  sps.studyPostList.value = postList;



}


/// 가지고온 스터디 포스트에서 카테고리
Future<void> getFilterStudyPost(String category) async {
  final sps = Get.put(StudyPostState());

  if(category == '전체') return;
  List studyPostList = sps.studyPostList.toList();
  List categoryPostList = studyPostList.where((post) => post['category'] == category).toList();
  sps.categoryPostList.value = categoryPostList;

}

/// 3개의 인기 스터디 정보를 가져오는 함수
void getPopularStudy() {
  final ss = Get.put(StudyState());
  var sortedList = List.from(ss.allStudyList);

  sortedList.sort((a, b) {
    var likeListA = a['likeList'] as List?;
    var likeListB = b['likeList'] as List?;

    if (likeListA == null && likeListB == null) return 0;
    if (likeListA == null) return 1;
    if (likeListB == null) return -1;

    return likeListB.length.compareTo(likeListA.length);
  });

  ss.popularStudyList.value = sortedList.take(3).toList();
  print('getPopularStudy 실행완료');
}


/// 3개의 신규 스터디 정보를 가져오는 함수
void getRecentStudy() {
  final ss = Get.put(StudyState());
  var sortedList = List.from(ss.allStudyList);

  // 인기 스터디의 studyName을 제외하고 정렬
  sortedList = sortedList.where((study) {
    return !ss.popularStudyList
        .any((popStudy) => popStudy['studyName'] == study['studyName']);
  }).toList();

  // createDate로 내림차순 정렬
  sortedList.sort((a, b) => (b['createDate']).compareTo(a['createDate']));

  // 신규 스터디 3개 선택
  ss.newStudyList.value = sortedList.take(3).toList();
  print('getRecentStudy 실행완료');
}

/// 나머지 스터디 정보를 가져오는 함수
void getOtherStudy() {
  final ss = Get.put(StudyState());

  var allStudy = List.from(ss.allStudyList);
  var popularStudy = ss.popularStudyList;
  var newStudy = ss.newStudyList;

  var otherStudies = allStudy.where((study) {
    bool isPopular = popularStudy.any((popStudy) => popStudy['studyName'] == study['studyName']);
    bool isNew = newStudy.any((newStudy) => newStudy['studyName'] == study['studyName']);
    return !isPopular && !isNew;
  }).toList();

  ss.otherStudyList.value = otherStudies;

  print('getOtherStudy 실행완료');
}



/// study 컬렉션의 가입된 유저 리스트, 가입 신청중인 리스트의 값들을 user 컬렉션의 nickname -> docId로 변경하기 위해서 사용
Future<void> updateStudyUserLists() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 1. study 컬렉션의 모든 문서 가져오기
  QuerySnapshot studySnapshot = await firestore.collection('study').get();

  // 2. 각 문서를 순회하며 업데이트
  for (DocumentSnapshot studyDoc in studySnapshot.docs) {
    List<dynamic> studyUserList = studyDoc.get('studyUserList');
    List<dynamic> signUpList = studyDoc.get('signUpList');

    // 3. 닉네임을 docId로 변환
    List<String> updatedStudyUserList = await _convertNicknamesToDocIds(studyUserList);
    List<String> updatedSignUpList = await _convertNicknamesToDocIds(signUpList);

    print('${studyDoc.get('studyName')}---------');
    print(updatedStudyUserList);
    print(updatedSignUpList);
    //4. 문서 업데이트
    await firestore.collection('study').doc(studyDoc.id).update({
      'studyUserList': updatedStudyUserList,
      'signUpList': updatedSignUpList,
    });
  }
}
Future<List<String>> _convertNicknamesToDocIds(List nicknameList) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> docIdList = [];

  for (String nickname in nicknameList) {
    // 3. user 컬렉션에서 해당 닉네임을 가진 사용자 문서 가져오기
    QuerySnapshot userSnapshot = await firestore
        .collection('user')
        .where('nickname', isEqualTo: nickname)
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // 닉네임에 해당하는 docId 가져오기
      String docId = userSnapshot.docs.first.id;
      docIdList.add(docId);
    } else {
      // 닉네임에 해당하는 사용자가 없을 경우, 예외 처리 필요
      print('닉네임 없음: $nickname');
    }
  }

  return docIdList;
}
/// 10개의 인기 스터디 정보를 가져오는 함수, 인기스터디 더보기
void getMorePopularStudy() {
  final ss = Get.put(StudyState());
  var sortedList = List.from(ss.allStudyList);

  sortedList.sort((a, b) {
    var likeListA = a['likeList'] as List?;
    var likeListB = b['likeList'] as List?;

    if (likeListA == null && likeListB == null) return 0;
    if (likeListA == null) return 1;
    if (likeListB == null) return -1;

    return likeListB.length.compareTo(likeListA.length);
  });

  ss.popularMoreStudyList.value = sortedList.take(10).toList();
  print('getMorePopularStudy 실행완료');
}

/// 10개의 신규 스터디 정보를 가져오는 함수, 신규스터디 더보기
void getMoreRecentStudy() {
  final ss = Get.put(StudyState());
  var sortedList = List.from(ss.allStudyList);

  sortedList.sort((a, b) => (b['createDate']).compareTo(a['createDate']));

  ss.newMoreStudyList.value = sortedList.take(10).toList();
  print('getMoreRecentStudy 실행완료');
}

/// 현재 사용중인 하나의 스터디리스트 초기화하는 함수
Future<void> getOneStudyList() async {
  final ss = Get.put(StudyState());
  CollectionReference ref = FirebaseFirestore.instance.collection('study');
  try{
    QuerySnapshot snapshot2 = await ref.where('docId', isEqualTo: ss.studyList[0]['docId']).get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List a = allData;
    ss.studyList.value = a;
    print('초기화 된 studyList?${ss.studyList.value}');
    await getStudyUserListMap(ss.studyList[0]['studyUserList']);
  } catch(e) {}
}
/// 공지사항 3개 가져오기
Future<void> getNotice3Post() async {
  final ss = Get.put(StudyState());
  final sps = Get.put(StudyPostState());

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot querySnapshot = await firestore
      .collection('studyPostInfo')
      .where('studyId', isEqualTo: ss.studyList[0]['docId'])
      .where('category', isEqualTo: '공지사항')  // category가 '공지사항'인 조건 추가
      .limit(3).get();

  sps.studyNoticePost3.clear();

  var postList = querySnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();
  postList.sort((a, b) => (b['createDate']).compareTo(a['createDate']));
  sps.studyNoticePost3.value = postList;

  print('공지사항 가져오기 완료');

}

/// 공지사항 가져오기
Future<void> getStudyNoticePost() async {
  final ss = Get.put(StudyState());
  final sps = Get.put(StudyPostState());

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot querySnapshot = await firestore
      .collection('studyPostInfo')
      .where('studyId', isEqualTo: ss.studyList[0]['docId'])
      .get();
  sps.studyPostList.clear();

  var postList = querySnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();
  postList.sort((a, b) => (b['createDate']).compareTo(a['createDate']));
  sps.studyPostList.value = postList;

}

/// 스터디장 양도 함수
Future<void> transferStudyHost(String newHostDocId)async{
  final ss = Get.put(StudyState());
  DocumentReference ref = FirebaseFirestore.instance.collection('study').doc(ss.studyList[0]['docId']);
  String newHostNickname = await getUserNickname(newHostDocId);
  print('새로운 호스트 닉네임 : ${newHostNickname}');
  await ref.update({
    'studyHostDocId':newHostDocId,
    'studyHost':newHostNickname,
  });
  print('업데이트 완료');
}

/// 스터티원 추방하기
Future<void> banStudyUser(String banUserDocId)async{
  final ss = Get.put(StudyState());
  final us = Get.put(UserState());
  await getOtherUserDetailList(banUserDocId);
  var studyRef = FirebaseFirestore.instance.collection('study').doc(ss.studyList[0]['docId']);
  var userDetailRef = FirebaseFirestore.instance.collection('userDetail').doc(us.otherUserDetailList[0]['docId']);
  await studyRef.update({
    'studyUserList': FieldValue.arrayRemove([banUserDocId]),
  });
  await userDetailRef.update({
    'studyList': FieldValue.arrayRemove([ss.studyList[0]['docId']]),
  });
  print('업데이트 완료');
}

/// 유저디테일에 있는 studyList(스터디아이디 리스트)를 이용하여 해당 스터디 정보 가져오기
Future<void> getUserDetailStudy(List<String> userDocIdList) async {
  final ss = Get.put(StudyState());
  ss.userDetailStudyList.clear();

  /// userDocIdList가 비어 있는지 확인
  if (userDocIdList.isEmpty) {
    print('비어 있습니다.');
    return;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  for (String userDocId in userDocIdList) {
    QuerySnapshot querySnapshot = await firestore
        .collection('study')
        .where('docId', isEqualTo: userDocId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      ss.userDetailStudyList.addAll(querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList());
    }
  }
}

/// 스터디 폐쇄하기
Future<void> closeStudy(String studyId) async {
  final ss = Get.put(StudyState());
  DocumentReference studyRef = FirebaseFirestore.instance.collection('study').doc(studyId);
  try{
    DocumentSnapshot studySnapshot = await studyRef.get();
    print('studySnapshot?${studySnapshot.data()}');
    /// Study 삭제
    await studyRef.delete();

    /// 관련된 schedule 문서 삭제
    QuerySnapshot scheduleSnapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .where('studyDocId', isEqualTo: studyId)
        .get();

    for (var doc in scheduleSnapshot.docs) {
      print("Schedule Document Data: ${doc.data()}");

       await doc.reference.delete();
    }

    /// 관련된 studyPost 문서 삭제
    QuerySnapshot studyPostInfoSnapshot = await FirebaseFirestore.instance
            .collection('studyPostInfo')
            .where('studyId', isEqualTo: studyId)
            .get();

    for (var doc in studyPostInfoSnapshot.docs) {
      print("studyPostInfo Document Data: ${doc.data()}");

      await doc.reference.delete();
    }
    ///  유저 디테일 컬렉션의 signUpList에 studyId가 포함된 문서들 쿼리
    QuerySnapshot studyListSnapshot = await FirebaseFirestore.instance
        .collection('userDetail')
        .where('signUpList', arrayContains: studyId)
        .get();

    for (var doc in studyListSnapshot.docs) {
        await doc.reference.update({
          'signUpList': FieldValue.arrayRemove([studyId]),
        });
        print("Removed $studyId from signUpList for user: ${doc.id}");
    }

    /// 유저 디테일 컬렉션의 studyList에 studyId가 포함된 문서들 쿼리
    QuerySnapshot studyUserListSnapshot = await FirebaseFirestore.instance
        .collection('userDetail')
        .where('studyList', arrayContains: studyId)
        .get();

    for (var doc in studyUserListSnapshot.docs) {
        await doc.reference.update({
          'studyList': FieldValue.arrayRemove([studyId]),
        });
        print("Removed $studyId from studyUserList for user: ${doc.id}");
    }

    ss.studyList.clear();
  }catch(e){
    
  }
}

/// 스터디원이 스터디 탈퇴하기
Future<void> leaveStudy(String studyId) async{
  try{
    /// 스터디 컬렉션에서 유저 삭제
    DocumentReference studyRef = FirebaseFirestore.instance.collection('study').doc(studyId);
    await studyRef.update({
      'studyUserList': FieldValue.arrayRemove([us.userList[0]['docId']])
    });

    /// 스케줄 컬렉션에서 studyDocId가 studyId와 같고, personList에 userId가 포함된 문서 가져오기
    QuerySnapshot scheduleSnapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .where('studyDocId', isEqualTo: studyId)
        .where('personList', arrayContains: us.userList[0]['docId'])
        .get();
    for (var doc in scheduleSnapshot.docs) {
      print("Schedule Document Data: ${doc.data()}");
      await doc.reference.update({
        'personList': FieldValue.arrayRemove([us.userList[0]['docId']])
      });
    }
    /// 유저 디테일에서 스터디 삭제
    DocumentReference userDetailRef = FirebaseFirestore.instance.collection('userDetail').doc(us.userDetailList[0]['docId']);
    await userDetailRef.update({
      'studyList': FieldValue.arrayRemove([studyId])
    });

  }catch(e){
    print('error : $e');
  }



}


