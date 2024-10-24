import 'package:get/get.dart';

class ScheduleState extends GetxController{
  final a1 = ''.obs;
  final a2 = 0.obs;
  final a3 = [].obs;
  final selectedDay = DateTime.now().obs; ///선택된 날짜 DateTime


  final userList = [];
  final scheduleList = [].obs;

  final scheduleDate = ''.obs; /// 다이얼로그에서 날짜 꺼내옴
  final schedule = [].obs; /// 스케줄 담은 데이터

  final selectLocation = [].obs; /// 장소 선택한 리스트
}