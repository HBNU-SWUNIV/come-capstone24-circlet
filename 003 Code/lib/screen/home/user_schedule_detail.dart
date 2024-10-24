import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/dialog/dialog.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:circlet/util/color.dart';
import 'package:circlet/util/full_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../../components/components.dart';
import '../../../firebase/firebase_schedule.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/schedule_state.dart';
import '../../../util/font/font.dart';
import '../../util/keys.dart';


class UserScheduleDetail extends StatefulWidget {
  const UserScheduleDetail({super.key});

  @override
  State<UserScheduleDetail> createState() => _UserScheduleDetailState();
}

class _UserScheduleDetailState extends State<UserScheduleDetail> {

  DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  DateFormat formatter = DateFormat('yyyy.MM.dd(E) HH:mm', 'ko_KR');
  late NaverMapController _mapController;
  late Map<String, dynamic> schedule;
  bool _isLoading = true;
  bool check = false;
  final us = Get.put(UserState());

  @override
  void initState() {
    schedule = Get.arguments;
    Future.delayed(Duration.zero, () async {
      await initialize();
      check = schedule['personList'].contains('${us.userList[0]['docId']}');
      print(check);
      _isLoading = false;


      setState(() {});
    });
    super.initState();
  }

  Future<void> initialize() async {
    print("initializeMap!!");
    await NaverMapSdk.instance.initialize(
        clientId: '${ApiKeys.naverMapClientId}',
        onAuthFailed: (ex) {
          print("********* 네이버맵 인증오류 : $ex *********");
        });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: ()async{
              await myClassScheduleGet(formatter.format(us.userSelectedDay.value));
              Get.back();
            },
            child: Icon(Icons.arrow_back_ios_new)),
        title: Text(
          '${schedule['title']}',
          style: f20bw500,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1), // Divider의 높이 설정
          child: Divider(
            color: Color(0xffEBEBEB), // Divider의 색상 설정
            height: 1, // Divider의 높이 설정
            thickness: 1, // Divider의 두께 설정
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: EdgeInsets.only(top: 16, left: 12, right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 14, right: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '일정명',
                    style: f15bw500,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    schedule['title'],
                    style: f12bw500,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '일시',
                    style: f15bw500,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                        schedule['scheduleDay'],
                        style: f12bw500,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        schedule['scheduleTime'],
                        style: f12bw500,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '일정형태',
                        style: f15bw500,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color:
                          scheduleStatusBackColor[schedule['scheduleState']],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4,horizontal: 10,),
                          child: Text(
                            schedule['scheduleState'],
                            style: TextStyle(
                              color: scheduleStatusTextColor[
                              schedule['scheduleState']],
                              fontFamily: 'NotoSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  schedule['scheduleState']=='오프라인'?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('장소', style: f15bw500,),
                      const SizedBox(height: 8,),
                      Text(schedule['place'], style: f12bw500),
                      const SizedBox(height: 20,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: (){
                            Get.to(()=>FullMapScreen());
                          },
                          child: Container(
                            width: Get.width,
                            height: 255,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 1, color: grayColor2),),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: NaverMap(
                                onMapTapped: (point, latLng){
                                  print('지도클릭');
                                  Get.to(()=>FullMapScreen(), arguments: schedule);},
                                options: NaverMapViewOptions(
                                  tiltGesturesEnable: true,
                                  scrollGesturesEnable: false,
                                  locationButtonEnable: false,
                                  /// 내위치 버튼
                                  zoomGesturesEnable: false,
                                  /// 줌제한
                                  extent: NLatLngBounds(
                                    /// 지도 영역 한반도 인근으로 제한
                                    southWest: NLatLng(31.43, 122.37),
                                    northEast: NLatLng(44.35, 132.0),
                                  ),
                                  initialCameraPosition: NCameraPosition(
                                      target: NLatLng(
                                          double.parse('${schedule['y']}'),
                                          double.parse('${schedule['x']}')),
                                      zoom: 13,
                                      bearing: 0,
                                      tilt: 0),),
                                onMapReady: (controller) async {
                                  _mapController = controller;
                                  var locationMarker = NMarker(
                                      id: '1',
                                      position: NLatLng(
                                          double.parse('${schedule['y']}'),
                                          double.parse('${schedule['x']}')));
                                  _mapController.addOverlay(locationMarker);},),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30,),
                    ],
                  ):schedule['url']!=''?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('URL', style: f15bw500,),
                      const SizedBox(height: 8,),
                      Text(schedule['url'], style: f12bw500),
                      const SizedBox(height: 20,),
                    ],
                  ):Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('참여인원', style: f15bw500,
                      ),
                      SizedBox(
                        width: 13,
                      ),
                      Text(
                        '${schedule['personList'].length}',
                        style: f14rw500,
                      ),
                      Text(
                        '/' + '${schedule['maxPerson']}',
                        style: f14bw500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: schedule['personList'].length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 50,
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 18, right: 18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, // 원형으로 설정
                                    color: grayColor2,
                                    border: Border.all(
                                      color: hintGrayColor,
                                      width: 1,
                                    ),
                                  ),
                                  width: 40,
                                  height: 40,
                                  /// Cached 네트워크 이미지
                                  child: ClipOval( // 이미지를 원형으로 자르기 위해 ClipOval 사용
                                    child: CachedNetworkImage(
                                      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${schedule['personList'][index]}?alt=media',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                FutureBuilder<String>(
                                  future: getUserNickname(schedule['personList'][index]),
                                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Text('로딩...');
                                    } else if (snapshot.hasError) {
                                      return Text('에러');
                                    } else {
                                      return Text(snapshot.data ?? '',style: f14bw400,);
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
      bottomSheet:
      GestureDetector(
        onTap: () async {
          print(schedule['maxPerson']);
          print(schedule['personList'].length);
          if(check == false&&schedule['personList'].length<int.parse(schedule['maxPerson'])){
            await userApplySchedule(schedule['docId']);
            schedule['personList'].add('${us.userList[0]['docId']}');
            print('${ schedule['personList']}');
          }else if(check == false&&schedule['personList'].length>=int.parse(schedule['maxPerson'])){
            showOnlyConfirmDialog(context, '인원수 제한', '최대 인원수 입니다.');
          }
          else{
            await userCancelApplySchedule(schedule['docId']);
            schedule['personList'].remove('${us.userList[0]['docId']}');
          }
          setState(() {
            check = schedule['personList'].contains('${us.userList[0]['docId']}');
          });
        },
        child: Container(
          height: 70,
          decoration: BoxDecoration(
              color: mainColor
            //borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              check==false?'신청하기':'취소하기',
              style: f18w500,
            ),
          ),
        ),
      ),
    );
  }
}
