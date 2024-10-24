import 'dart:ffi';
import 'dart:io';

import 'package:circlet/dialog/dialog.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:circlet/screen/main/bottom_navigator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../provider/schedule_state.dart';
import '../screen/login_register/login/login_page.dart';

///이메일 중복 체크
Future<void> registerEmailDuplicate(String email) async {
  final us = Get.put(UserState());
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  QuerySnapshot snapshot = await ref.where('email', isEqualTo: email).get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  us.memberCheckEmail.value = allData.isEmpty?'0':'1';
  us.memberCheckEmail.value == '0'? us.registerEmail.value = email: '';
}

///핸드폰 번호 중복 체크
Future<void> registerPhoneDuplicate(String phone) async {
  final us = Get.put(UserState());
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  QuerySnapshot snapshot = await ref.where('phone', isEqualTo: phone).get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  us.memberCheckPhone.value = allData.isEmpty?'0':'1';
}

///닉네임 중복 체크
Future<void> registerNicknameDuplicate(String nickname) async {
  final us = Get.put(UserState());
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  QuerySnapshot snapshot = await ref.where('nickname', isEqualTo: nickname).get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  us.memberCheckNickname.value = allData.isEmpty?'0':'1';
  us.memberCheckNickname.value == '0'? us.registerNickname.value = nickname: '';
}

/// docId로 유저리스트 불러오기
Future<void> getUserList(String docId) async {
  final us = Get.put(UserState());
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  try{
    QuerySnapshot snapshot2 = await ref.where('docId', isEqualTo: docId).get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List a = allData;
    us.userList.value = a;
  } catch(e) {}
}

/// docId로 유저 닉네임 반환
Future<String> getUserNickname(String docId) async {
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  try{
    QuerySnapshot snapshot2 = await ref.where('docId', isEqualTo: docId).get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List a = allData;
    String nickname = a[0]['nickname'] as String;
    return nickname;
  } catch(e) {
    return '';
  }
}
Future<void> getSignUpListMap(List docIds) async{
  final ss = Get.put(StudyState());
  List result = [];
  for(String docId in docIds){
    CollectionReference ref = FirebaseFirestore.instance.collection('user');
   try{
     QuerySnapshot snapshot2 = await ref.where('docId', isEqualTo: docId).get();
     final allData = snapshot2.docs.map((doc) => doc.data()).toList();
     List a = allData;
     String nickname = a[0]['nickname'];
     result.add({'docId':docId, 'nickname':nickname});
   } catch(e){
   }
  }
  ss.signUpList.value = result;

}

Future<void> getStudyUserListMap(List docIds) async{
  final ss = Get.put(StudyState());
  List result = [];
  for(String docId in docIds){
    CollectionReference ref = FirebaseFirestore.instance.collection('user');
    try{
      QuerySnapshot snapshot2 = await ref.where('docId', isEqualTo: docId).get();
      final allData = snapshot2.docs.map((doc) => doc.data()).toList();
      List a = allData;
      String nickname = a[0]['nickname'];
      result.add({'docId':docId, 'nickname':nickname});
    } catch(e){
    }
  }
  ss.studyUserList.value = result;

}


/// docId로 유저디테일 리스트 불러오기
Future<void> getUserDetailList(String docId) async {
  final us = Get.put(UserState());
  CollectionReference ref = FirebaseFirestore.instance.collection('userDetail');
  try{
    QuerySnapshot snapshot2 = await ref.where('userId', isEqualTo: docId).get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List a = allData;
    us.userDetailList.value = a;
  } catch(e) {}
}

/// docId로 유저디테일 리스트 불러오기
Future<void> getOtherUserDetailList(String docId) async {
  final us = Get.put(UserState());
  CollectionReference ref = FirebaseFirestore.instance.collection('userDetail');
  try{
    QuerySnapshot snapshot2 = await ref.where('userId', isEqualTo: docId).get();

    // 문서가 없으면 "탈퇴한 사용자" 메시지를 설정
    if (snapshot2.docs.isEmpty) {
      us.otherUserDetailList.value = ['탈퇴한 사용자']; // 적절한 반환값으로 수정 가능
      return; // 함수 종료
    }

    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List a = allData;
    us.otherUserDetailList.value = a;

  } catch(e) {
  }
}
/// phoneNumber 회원가입된 아이디 반환하기
Future<String> searchUserEmail(String phoneNumber) async {
  print('핸드폰 번호${phoneNumber}');
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  try{
    QuerySnapshot snapshot2 = await ref.where('phone', isEqualTo: phoneNumber).get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List a = allData;
    print('아이디 찾기 가능한가?${a}');
    return a[0]['email'];
  } catch(e) {
    return '';
  }
}
/// phoneNumber 비밀번호 찾기
Future<String> searchUserPw(String phoneNumber, String email) async {
  print('핸드폰 번호${phoneNumber}');
  print('이메일${email}');
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  try{
    QuerySnapshot snapshot2 = await ref
        .where('phone', isEqualTo: phoneNumber)
        .where('email', isEqualTo: email)
        .get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List a = allData;
    print('비밀번호 변경 가능?${a}');
    return a[0]['docId'];
  } catch(e) {
    return '';
  }
}
/// 비밀번호 업데이트 함수
Future<void> updateUserPassword(String docId, String newPassword) async {
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  try {
    await ref.doc(docId).update({'password': newPassword});
    print('비밀번호가 성공적으로 업데이트되었습니다.');
  } catch (e) {
    print('비밀번호 업데이트 실패: $e');
  }
}
/// 이전비밀번호를 입력하고 비밀번호를 업데이트 함수
Future<void> updateUserPassword2(BuildContext context,String docId, String oldPassword, String newPassword) async {
  final storage = new FlutterSecureStorage();
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  try {
    DocumentSnapshot doc = await ref.doc(docId).get();
    if(doc.exists){
      String currentPassword = doc.get('password');
      if(currentPassword==oldPassword) {
        await ref.doc(docId).update({'password': newPassword});
        showConfirmTapDialog(context,'비밀번호가 성공적으로 변경되었습니다.', () async {
          await storage.deleteAll();
          Get.offAll(() => LoginPage());
        });
        print('비밀번호 업데이트');
      }else{
        showConfirmTapDialog(context,'비밀번호가 일치하지 않습니다.', (){Get.back();});
        print('비밀번호 업데이트 실패');
      }
    }
  } catch (e) {
    print('비밀번호 업데이트 실패: $e');
  }
}

/// docId로 가입된 스터디의 정보 가져오기
Future<void> getStudyList(List docIds) async {
  print('--------test1');
  final ss = Get.put(StudyState());
  CollectionReference ref = FirebaseFirestore.instance.collection('study');
  try{
    QuerySnapshot snapshot2 = await ref.where(FieldPath.documentId, whereIn: docIds).get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List a = allData;
    ss.userStudyrList.value = a;
    print('--------test');
    print(ss.userStudyrList.value);
  } catch(e) {}
}


///로그인
Future<void> FirstLogin(String email, String pw) async {
  final us = Get.put(UserState());
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  try{
    QuerySnapshot snapshot2 = await ref.where('email', isEqualTo: email).get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List a = allData;
    if(a[0]['password']==pw){
      us.userList.value = a;
    }else{
      us.userList.clear();
    }
  } catch(e) {}
}

///로그인
Future<void> Login(String email, String pw) async {
  final us = Get.put(UserState());
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  try{
    QuerySnapshot snapshot2 = await ref.where('email', isEqualTo: email).get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List a = allData;
    if(a[0]['password']==pw){
      us.userList.value = a;
      /// 로그인시 토큰 값 update
      await ref.doc(us.userList[0]['docId']).update({'token': us.token.value});
      Get.to(()=>BottomNavigator());
    }else{
      us.userList.clear();
    }
  } catch(e) {}
  }

/// 스토리지에 이미지 저장
Future<void> storageAddImage (XFile? image, String fileName, String storageName)async{
  FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'gs://circlet-9c202.appspot.com');
  if (image != null) {
    print('이미지 저장중-------');
    File file = File(image!.path);
    try {
      await storage.ref("${storageName}/${fileName}").putFile(file);
      print("storage 파일 업로드 완료");
    } catch (e) {
      print("storage 파일 업로드 에러: $e");
    }
  } else {
    print("선택된 파일 없음");
  }
}


/// userDetail컬렉션에 가입중인 스터디, 가입신청중인 스터디의 docId값을 넣기 위해 단 한번 사용
Future<void> updateUserDetailLists() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 1. userDetail 컬렉션의 모든 문서 가져오기
  QuerySnapshot userDetailSnapshot = await firestore.collection('userDetail').get();

  // 2. study 컬렉션의 모든 문서 가져오기 (한번만 가져옴)
  QuerySnapshot studySnapshot = await firestore.collection('study').get();

  // 3. userDetail 컬렉션의 각 문서를 순회
  for (DocumentSnapshot userDetailDoc in userDetailSnapshot.docs) {
    String userId = userDetailDoc.get('userId');

    // 기존 값을 가져오거나, 없으면 빈 리스트로 초기화
    List<String> studyList = [];
    List<String> signUpList = [];

    // 4. study 컬렉션의 모든 문서를 순회
    for (DocumentSnapshot studyDoc in studySnapshot.docs) {
      Map<String, dynamic> studyData = studyDoc.data() as Map<String, dynamic>;

      List<String> studyUserList = studyData.containsKey('studyUserList')
          ? List<String>.from(studyDoc.get('studyUserList'))
          : [];
      List<String> signUpListInStudy = studyData.containsKey('signUpList')
          ? List<String>.from(studyDoc.get('signUpList'))
          : [];

      // 5. studyUserList에 내 userId가 있는지 확인
      if (studyUserList.contains(userId)) {
        if (!studyList.contains(studyDoc.id)) {
          studyList.add(studyDoc.id); // studyList에 study의 docId 추가
        }
      }

      // 6. signUpList에 내 userId가 있는지 확인
      if (signUpListInStudy.contains(userId)) {
        if (!signUpList.contains(studyDoc.id)) {
          signUpList.add(studyDoc.id); // signUpList에 study의 docId 추가
        }
      }
    }
    print('${userDetailDoc.get('docId')}---${userId}----');
    print(studyList);
    print(signUpList);

    //7. userDetail 컬렉션의 해당 문서 업데이트
    await firestore.collection('userDetail').doc(userDetailDoc.id).update({
      'studyList': studyList,
      'signUpList': signUpList,
    });
  }
}

/// myClass에서 스케줄 가져오기
Future<void> myClassScheduleGet(String selectDate) async {
  final us = Get.put(UserState());
  print('선택된 날짜 ${selectDate}');
  CollectionReference ref = FirebaseFirestore.instance.collection('schedule');
  QuerySnapshot snapshot = await ref
      .where('scheduleDay', isEqualTo: selectDate)
      .where('personList', arrayContains: '${us.userList[0]['docId']}').get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List a = allData;

  us.userScheduleList.value = a;
  print('해당유저의 스케줄은?');
  print(us.userScheduleList.value);
}

Future<void> userApplySchedule(String scheduleDocId) async {
  final us = Get.put(UserState());
  final scs = Get.put(ScheduleState());
  var ref = FirebaseFirestore.instance.collection('schedule').doc(scheduleDocId);

  print(us.userScheduleList[0]['docId']);
  await ref.update({
    'personList': FieldValue.arrayUnion([us.userList[0]['docId']]),
  });
}

Future<void> userCancelApplySchedule(String scheduleDocId) async {
  final us = Get.put(UserState());
  final scs = Get.put(ScheduleState());
  var ref = FirebaseFirestore.instance.collection('schedule').doc(scheduleDocId);

  print(us.userScheduleList[0]['docId']);
  await ref.update({
    'personList': FieldValue.arrayRemove([us.userList[0]['docId']]),
  });
}

/// 회원탈퇴
Future<void> deleteUser(String userId)async{
  final us = Get.put(UserState());
  DocumentReference userRef = FirebaseFirestore.instance.collection('user').doc(userId);
  try{
    DocumentSnapshot userSnapshot = await userRef.get();
    print('userSnapshot?${userSnapshot.data()}');
    /// user 삭제
    await userRef.delete();

    /// userDetail 삭제
    QuerySnapshot userDetailSnapshot = await FirebaseFirestore.instance
        .collection('userDetail')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in userDetailSnapshot.docs) {
      print("userDetail Document Data: ${doc.data()}");
      await doc.reference.delete();
    }

    /// 가입신청중인 스터디 삭제
    QuerySnapshot signUpListSnapshot = await FirebaseFirestore.instance
        .collection('study')
        .where('signUpList', arrayContains: userId)
        .get();

    for (var doc in signUpListSnapshot.docs) {
      await doc.reference.update({
        'signUpList': FieldValue.arrayRemove([userId]),
      });
      print("Removed $userId from signUpList for user: ${doc.id}");
    }
    print('회원탈퇴 완료');

  }catch(e){

  }




}

