import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


class StudyState extends GetxController{
  final studyList = [].obs; /// 선택된 스터디 리스트 1개
  final studyDocId = ''.obs; /// 스터디 생성 직후 해당 docId의 스터디 정보를 가져오기 위해 잠시 사용
  final allStudyList = [].obs; /// 모든 스터디 리스트
  final newStudyList = [].obs; /// 신규 스터디 리스트 3개
  final popularStudyList = [].obs; /// 인기 스터디 리스트 3개
  final otherStudyList = [].obs; /// 인기,신규 제외한 나머지 스터디
  final popularMoreStudyList = [].obs; /// 인기 스터디 리스트 더보기
  final newMoreStudyList = [].obs; ///신규 스터디 리스트 더보기
  final userDetailStudyList = [].obs; /// 유저 프로필에서 나오는 스터디 리스트



  ///study create
  final studyCheckName = ''.obs;
  final interest = [].obs;


  final studyUserList = [].obs; ///스터디에 가입된 사람
  final signUpList = [].obs; ///스터디에 가입 신청을 한 사람
  final userStudyrList = [].obs; ///스터디에 가입된 사람

}

