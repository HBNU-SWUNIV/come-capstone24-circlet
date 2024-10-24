import 'package:circlet/components/loading.dart';
import 'package:circlet/firebase/firebase_schedule.dart';
import 'package:circlet/provider/schedule_state.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:circlet/screen/study/schedule/add_schedule.dart';
import 'package:circlet/screen/study/schedule/schedule_detail.dart';
import 'package:circlet/util/loadingScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../components/components.dart';
import '../../../util/color.dart';
import '../../../util/font/font.dart';

class ShowSchedule extends StatefulWidget {
  const ShowSchedule({super.key});

  @override
  State<ShowSchedule> createState() => _ShowScheduleState();
}
class CircularFloatingActionButton extends StatelessWidget {
  final us = Get.put(UserState());
  final ss = Get.put(StudyState());
  @override
  Widget build(BuildContext context) {
    return us.userList[0]['docId']==ss.studyList[0]['studyHostDocId']?
    FloatingActionButton(
      onPressed: () {
        Get.to(()=>AddSchedule());
      },
      backgroundColor: mainColor,
      elevation: 0.0,
      shape: CircleBorder(),
      child: Icon(Icons.add,color: Colors.white,size: 50,),
    )
        :Container();
  }
}

class _ShowScheduleState extends State<ShowSchedule> {
  final scs = Get.put(ScheduleState());
  DateFormat dayFormatter = DateFormat('M월 dd일 EEEE', 'ko_KR');
  DateFormat formatter = DateFormat('yyyy.MM.dd(E) HH:mm', 'ko_KR');
  DateTime now = DateTime.now();
  DateFormat dayFormatter2 = DateFormat('yyyy.MM.dd EEEE', 'ko_KR');
  bool isLoading = true;
  @override
  void initState() {
    Future.delayed(Duration.zero,()async{
      scs.selectedDay.value = DateTime.now();
      print(scs.selectedDay.value);
      await scheduleGet(dayFormatter2.format(scs.selectedDay.value));
      isLoading=false;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CircularFloatingActionButton(),
      body: isLoading?LoadingScreen():Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: TableCalendar(
                focusedDay: now,
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 01, 01),
                locale: 'ko_KR',
                weekendDays: [DateTime.sunday, 7],
                daysOfWeekHeight: 30,
                rowHeight: 35,

                /// 선택된 날짜를 달력에 반영
                selectedDayPredicate: (day) {
                  return isSameDay(scs.selectedDay.value, day);
                },

                /// 선택된 날짜의 상태 갱신
                onDaySelected: (_selectedDay, _focusedDay) async{
                  if (!isSameDay(scs.selectedDay.value, _selectedDay)) {
                    showLoading(context);
                    scs.selectedDay.value = _selectedDay;
                    print('선택된 날짜?${scs.selectedDay.value}');
                    await scheduleGet(dayFormatter2.format(scs.selectedDay.value));
                    Get.back();
                    setState(() {});
                  }
                },
                headerStyle: HeaderStyle(
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: mainColor,
                      size: 28,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: mainColor,
                      size: 28,
                    ),
                    formatButtonVisible: false,
                    titleCentered: true),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                  ),
                  todayTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSameDay(DateTime.now(), scs.selectedDay.value)
                        ? whiteColor : mainColor,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: isSameDay(DateTime.now(), scs.selectedDay.value)
                        ? mainColor : Color(0xff81ACEC),
                    shape: BoxShape.circle,
                  ),
                )),
          ),
          SizedBox(height: 30,),
          Expanded(
              child: Container(
                width: Get.width,
                decoration: BoxDecoration(
                  color: lightGrayColor
                ),
              child: Padding(
                padding: EdgeInsets.only(top:13, left: 23, right: 23),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${dayFormatter.format(scs.selectedDay.value)}', style: f16bw500,),
                    SizedBox(height: 20,),
                    Obx(() => Expanded(
                        child: ListView.builder(
                            itemCount: scs.schedule.length,
                            itemBuilder: (context, index){
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      scs.a1.value = scs.schedule[index]['scheduleDay'];
                                      Get.to(()=>ScheduleDetail(),arguments: scs.schedule[index]);
                                      setState(() {

                                      });
                                    },
                                    /// 일정별 컨테이너
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xffF1F1F1),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                          BoxShadow(
                                            color: Color(0xffF5F5F5),
                                            blurRadius: 10,
                                            offset: Offset(0, 2),
                                          ),
                                          BoxShadow(
                                            color: Color(0xffDDDDDD),
                                            blurRadius: 10,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 23,right: 15, top: 11, bottom: 14),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            /// 오프라인, 온라인 여부
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: scheduleStatusBackColor[scs.schedule[index]['scheduleState']],
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: 10,right: 10,top: 4,bottom: 4),
                                                    child: Text(scs.schedule[index]['scheduleState'],
                                                      style: TextStyle(
                                                        color: scheduleStatusTextColor[scs.schedule[index]['scheduleState']],
                                                        fontFamily: 'NotoSans',
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 10,
                                                      ),),
                                                  ),
                                                ),
                                                Spacer(),
                                                GestureDetector(
                                                    onTap: (){
                                                      Get.to(()=>ScheduleDetail(),arguments: scs.schedule[index]);
                                                    },
                                                    child: Text('자세히', style: f10hgw400,)),
                                                Icon(Icons.chevron_right,
                                                  color: hintGrayColor,
                                                  size: 20,)
                                              ],
                                            ),
                                            SizedBox(
                                              height: 9,
                                            ),
                                            Text(
                                              scs.schedule[index]['title'],
                                              style: f15bw500,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: [
                                                Text(scs.schedule[index]['scheduleDay'], style: f10bw400,),
                                                SizedBox(width: 25,),
                                                SizedBox(width: 14,child: SvgPicture.asset('assets/icon/bottom_navi/lounge.svg',)),
                                                SizedBox(width: 6,),
                                                Text('${scs.schedule[index]['personList'].length}'+'/'+scs.schedule[index]['maxPerson'],style: f10bw400,),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  )
                                ],
                              );

                            })))
                  ],

                ),
              ),
              ))


        ],
      ),
    );
  }
}
