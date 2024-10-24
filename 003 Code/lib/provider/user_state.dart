import 'package:get/get.dart';

class UserState extends GetxController{

  final firstLogin = false.obs; /// 처음 로그인시 한번만 실행
  final userList = [].obs; /// user 컬렉션의 정보를 담는 리스트
  final userDetailList = [].obs; /// userDetail 컬렉션의 정보를 담는 리스트
  final otherUserDetailList = [].obs; /// 다른 한명의 userDetail 컬렉션의 정보를 담는 리스트
  final userScheduleList = [].obs; /// myClass에서 해당 유저가 참여한 스케줄 일정을 담는 리스트
  final userSelectedDay = DateTime.now().obs; ///선택된 날짜 DateTime

  final userDocId = ''.obs;

  final token = ''.obs; /// fcm 토큰


  /// register
  final memberCheckPhone = ''.obs;
  final memberCheckEmail = ''.obs;
  final memberCheckNickname = ''.obs;
  final registerPhone = ''.obs;
  final registerEmail = ''.obs;
  final registerPassword = ''.obs;
  final registerNickname = ''.obs;

  /// user detail

  final interest = [].obs;
  final techStack = [].obs;
  final introduce = ''.obs;
  final gitUrl = ''.obs;
  final blogUrl = ''.obs;

  RxInt a = 1.obs;


  ///
  @override
  void onInit() {
    print('111');
    super.onInit();
  }
  void test() {
    a.value = 2;
  }
}