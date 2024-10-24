import 'package:circlet/provider/study_state.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../provider/schedule_state.dart';


/// 스케줄 add
Future<void> scheduleAdd(
    String title,
    String scheduleDay,
    String scheduleTime,
    String maxPerson,
    String scheduleState,
    String url,
    String place,
    double x,
    double y
    )async {
    final us = Get.put(UserState());
    final ss = Get.put(StudyState());
    CollectionReference ref = FirebaseFirestore.instance.collection('schedule');
    await ref.add({
      'title': '${title}',
      'docId': '',
      'createDate':'${DateTime.now()}',
      'scheduleDay': '${scheduleDay}',
      'scheduleTime':'${scheduleTime}',
      'maxPerson':'${maxPerson}',
      'scheduleState':'${scheduleState}',
      'studyDocId':'${ss.studyList[0]['docId']}',
      'scheduleWriteDocId':'${us.userList[0]['docId']}',
      'personList':[],
      'url':'${url}',
      'place':'${place}',
      'x':x,
      'y':y,
    }).then((doc) {
      ref.doc(doc.id).update({'docId': doc.id});
    });
  }

  /// 스케줄 가져오기
  Future<void> scheduleGet(String selectDate) async {
    final us = Get.put(UserState());
    final ss = Get.put(StudyState());
    final scs = Get.put(ScheduleState());
    print('스터디 아이디는? ${ss.studyList[0]['docId']}');
    print('선택된 날짜 ${selectDate}');
    CollectionReference ref = FirebaseFirestore.instance.collection('schedule');
    QuerySnapshot snapshot = await ref
        .where('scheduleDay', isEqualTo: selectDate)
        .where('studyDocId', isEqualTo: '${ss.studyList[0]['docId']}').get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    List a = allData;

    scs.schedule.value = a;
  }



  ///가장 가까운 스케쥴 1개 가져오기
Future<void> getClosestSchedule() async {
  DateTime now = DateTime.now();
  final ss = Get.put(StudyState());
  final sds = Get.put(ScheduleState());
  CollectionReference ref = FirebaseFirestore.instance.collection('schedule');
  QuerySnapshot querySnapshot = await ref
      .where('studyDocId', isEqualTo: '${ss.studyList[0]['docId']}').get();
  final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
  List a = allData;
  // 스케줄 중 가장 가까운 스케줄 찾기
  DateTime parseScheduleDate(String day) {
    return DateFormat('yyyy.MM.dd EEEE', 'ko_KR').parse(day);
  }

  Map<String, dynamic>? closestSchedule;
  Duration? closestDuration;

  for (var schedule in a) {
    String scheduleDay = schedule['scheduleDay'] ?? '';
    DateTime scheduleDate = parseScheduleDate(scheduleDay);
    /// 일 단위로 시간차 구하기
    Duration difference = scheduleDate.difference(now);
    /// 과거 스케줄은 건너뜀, 오늘 날짜 포함
    if (scheduleDate.isBefore(now) && difference.inDays > 0) continue;
    if (closestDuration == null || difference < closestDuration) {
      closestDuration = difference;
      closestSchedule = schedule;
    }
  }
  print('dfsdfdfdf${closestSchedule}');
  if(closestSchedule!=null) sds.scheduleList.value = [closestSchedule];
}


Future<void> applySchedule(String scheduleDocId) async {
  final us = Get.put(UserState());
  final scs = Get.put(ScheduleState());
  var ref = FirebaseFirestore.instance.collection('schedule').doc(scheduleDocId);

  print(scs.schedule[0]['docId']);
  await ref.update({
    'personList': FieldValue.arrayUnion([us.userList[0]['docId']]),
  });
}

Future<void> cancelApplySchedule(String scheduleDocId) async {
  final us = Get.put(UserState());
  final scs = Get.put(ScheduleState());
  var ref = FirebaseFirestore.instance.collection('schedule').doc(scheduleDocId);

  print(scs.schedule[0]['docId']);
  await ref.update({
    'personList': FieldValue.arrayRemove([us.userList[0]['docId']]),
  });
}

/// 스케줄 삭제하기
Future<void> deleteSchedule(String docId) async {
  final scs = Get.put(ScheduleState());
  try{
    await FirebaseFirestore.instance
        .collection('schedule')
        .doc(docId)
        .delete();

  }catch(e){
    print('스케쥴 삭제 실패 ${e}');
  }
  print('삭제전 스케쥴 리스트 ${ scs.schedule.value}');
  scs.schedule.value.removeWhere((schedule) => schedule['docId'] == docId);
  scs.schedule.refresh();
  print('삭제반영한 스케쥴 리스트 ${ scs.schedule.value}');
}