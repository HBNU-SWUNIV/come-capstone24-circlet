import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/screen/home/user_schedule_detail.dart';
import 'package:circlet/util/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../app/notification/local_notification_setting.dart';
import '../../components/components.dart';
import '../../components/loading.dart';
import '../../firebase/firebase_user.dart';
import '../../provider/study_state.dart';
import '../../provider/user_state.dart';
import '../../util/font/font.dart';
import '../../util/loadingScreen.dart';
import '../class_search/study_search_result_page.dart';
import '../study/create/study_interest.dart';
import '../study/study_home/study_home_page.dart';

class MyClass extends StatefulWidget {
  const MyClass({super.key});

  @override
  State<MyClass> createState() => _MyClassState();
}

class _MyClassState extends State<MyClass> {
  bool _isLoading = true;
  final us = Get.put(UserState());
  final ss = Get.put(StudyState());
  ///달력사용에 필요한 변수들
  DateFormat dayFormatter = DateFormat('M월 dd일 EEEE', 'ko_KR');
  DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  DateFormat formatter = DateFormat('yyyy.MM.dd(E) HH:mm', 'ko_KR');
  DateTime now = DateTime.now();
  DateFormat dayFormatter2 = DateFormat('yyyy.MM.dd EEEE', 'ko_KR');

  @override
  void initState() {
    print('initState------${us.userList[0]['nickname']}');
    Future.delayed(Duration.zero, () async {
      us.userSelectedDay.value = DateTime.now();
      await getUserDetailList(us.userList[0]['docId']);
      await getStudyList(us.userDetailList[0]['studyList']);
      await myClassScheduleGet(dayFormatter2.format(us.userSelectedDay.value));
      _isLoading = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "STEADY",
            style: f24mainColor700,
          ),
          actions: [
            GestureDetector(
              onTap: () {
                LocalNotifyCation localNotifyCation = LocalNotifyCation();
                localNotifyCation.sendNotification();
              },
              child: SvgPicture.asset('assets/icon/alarm.svg', width: 18, color: Colors.black,),
            ),
            SizedBox(width: 16,),
            GestureDetector(
              onTap: () {
                Get.to(() => StudyInterest());
              },
              child: SvgPicture.asset('assets/icon/x-circle-fill.svg', width: 26,),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => StudySearchResultPage());
                },
                child: SvgPicture.asset('assets/icon/search.svg', width: 20,),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              color: Color(0xffEBEBEB),
              height: 1,
              thickness: 1,
            ),
          )),
      body: _isLoading
        ? LoadingScreen():
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ss.userStudyrList.value.isNotEmpty
                ?Padding(
                  padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('참여 중인 스터디', style: f16gray800w700,),
                      const SizedBox(height: 12,),
                      Container(
                        height: 90,
                        child: ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: ss.userStudyrList.length,
                            itemBuilder: (context, index){
                              return Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: GestureDetector(
                                  onTap: (){
                                    ss.studyList.value = [ss.userStudyrList[index]];
                                    print('studyList????${ss.studyList}');
                                    Get.to(() => StudyHomePage());
                                    },
                                  child: Container(
                                    width: 65,
                                    height: 80,
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: grayColor2,
                                          ),
                                          width: 65,
                                          height: 60,
        
                                          ///Cached 네트워크 이미지
                                          child: CachedNetworkImage(
                                            imageUrl: 'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/studyImage%2F${ss.userStudyrList[index]['docId']}?alt=media',
                                            fit: BoxFit.cover,
                                            imageBuilder: (context, imageProvider) => Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) => const CircularProgressIndicator(),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Text(
                                          '${ss.userStudyrList[index]['studyName']}',
                                          style: f12gray800w500,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ):Container(),
            SizedBox(height: 15,),
            Padding(padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('나의 일정', style: f16gray800w700,),
                /// 캘린더
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TableCalendar(
                      focusedDay: now,
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2025, 01, 01),
                      locale: 'ko_KR',
                      weekendDays: [DateTime.sunday, 7],
                      daysOfWeekHeight: 30,
                      rowHeight: 30,
                      /// 선택된 날짜를 달력에 반영
                      selectedDayPredicate: (day) {
                        return isSameDay(us.userSelectedDay.value, day);
                      },
                      /// 선택된 날짜의 상태 갱신
                      onDaySelected: (_selectedDay, _focusedDay) async{
                        if (!isSameDay(us.userSelectedDay.value, _selectedDay)) {
                          showLoading(context);
                          us.userSelectedDay.value = _selectedDay;
                          print('선택된 날짜?${us.userSelectedDay.value}');
                         await myClassScheduleGet(dayFormatter2.format(us.userSelectedDay.value));
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
                         cellMargin: EdgeInsets.only(bottom: 4),
                        todayDecoration: BoxDecoration(
                          // color: Colors.transparent,
                        ),
                        todayTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSameDay(DateTime.now(), us.userSelectedDay.value)
                              ? whiteColor : mainColor,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: isSameDay(DateTime.now(), us.userSelectedDay.value)
                              ? mainColor : Color(0xff81ACEC),
                          shape: BoxShape.circle,
                        ),
                      )),
                ),
                SizedBox(height: 10,)
              ],
            ),),
            /// 상세 일정'
            SingleChildScrollView(
              child: Container(
                width: Get.width,
                height: 400,
                decoration: BoxDecoration(
                    color: lightGrayColor
                ),
                child: Padding(
                  padding: EdgeInsets.only(top:13, left: 23, right: 23),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${dayFormatter.format(us.userSelectedDay.value)}', style: f16gray800w700,),
                      SizedBox(height: 20,),
                      Obx(() =>  Expanded(
                          child: ListView.builder(
                              itemCount: us.userScheduleList.length,
                              itemBuilder: (context, index){
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Get.to(()=>UserScheduleDetail(),arguments: us.userScheduleList[index]);
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
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: scheduleStatusBackColor[us.userScheduleList[index]['scheduleState']],
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 10,right: 10,top: 4,bottom: 4),
                                                  child: Text(us.userScheduleList[index]['scheduleState'],
                                                    style: TextStyle(
                                                      color: scheduleStatusTextColor[us.userScheduleList[index]['scheduleState']],
                                                      fontFamily: 'NotoSans',
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 10,
                                                    ),),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 9,
                                              ),
                                              Text(
                                                us.userScheduleList[index]['title'],
                                                style: f15bw500,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                children: [
                                                  Text(us.userScheduleList[index]['scheduleDay'], style: f10bw400,),
                                                  SizedBox(width: 25,),
                                                  SizedBox(width: 14,child: SvgPicture.asset('assets/icon/bottom_navi/lounge.svg',)),
                                                  SizedBox(width: 6,),
                                                  Text('${us.userScheduleList[index]['personList'].length}'+'/'+us.userScheduleList[index]['maxPerson'],style: f10bw400,),
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
              ),
            )
          ],
        ),
      ),

    );
  }
}
