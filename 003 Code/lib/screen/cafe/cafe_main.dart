import 'dart:convert';


import 'package:circlet/screen/study/schedule/add_schedule.dart';
import 'package:circlet/util/color.dart';
import 'package:circlet/util/font/font.dart';
import 'package:circlet/util/keys.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../components/components.dart';
import '../../firebase/api.dart';
import 'location.dart';

class CafeMain extends StatefulWidget {
  const CafeMain({super.key});

  @override
  State<CafeMain> createState() => _CafeMainState();
}

class _CafeMainState extends State<CafeMain> {

  double latitude = 0.0;
  double longitude = 0.0;


 bool _isLoading = true;



  late NaverMapController _mapController;
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _modelScaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? _bottomController;
  late String data;
  List points = [];

  final List<String> _items =  ['서울시', '부산시', '인천시', '대구', '대전', '광주', '울산', '경기도', '충북', '충남', '전북', '전남', '경북', '경남', '강원도', '제주시'];
  List<String> _items2 =  [];
  String manageValue = '서울시';
  String? manageValue2;
  String value = ''; /// 카페종류 선택

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getLocationData();
      await initialize();
      _items2 = await getDropList('서울시');
      manageValue2 = _items2[0];
      _isLoading = false;
      setState(() {});
    });
    super.initState();
  }

///지도 준비
  Future<void> initialize() async {
    print("initializeMap!!");
    await NaverMapSdk.instance.initialize(
        clientId: '${ApiKeys.naverMapClientId}',
        onAuthFailed: (ex) {
          print("********* 네이버맵 인증오류 : $ex *********");
        });
  }

  ///맵에 카페 데이터를 마커로 표시하는 함수
  Future<void> initializeMap() async {
    _mapController.clearOverlays();
    /// 카페 정보를 마커로 표시
    for (int i = 0; i < points.length; i++) {
      final marker = NMarker(
        id: '${points[i]['id']}',
        position: NLatLng(double.parse('${points[i]['y']}'),
            double.parse('${points[i]['x']}')),
      );

      _mapController.addOverlay(marker);
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(double.parse('${points[i]['y']}'),
              double.parse('${points[i]['x']}')))
        ..setPivot(NPoint(0.5, 0.5));
      _mapController.updateCamera(cameraUpdate);
      marker.setOnTapListener((NMarker marker) {

        ///마커 위치로 카메라 이동
        final markerClickCameraUpdate = NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(double.parse('${points[i]['y']}'),
                double.parse('${points[i]['x']}')))
          ..setPivot(NPoint(0.5, 0.5));
        _mapController.updateCamera(markerClickCameraUpdate);

        ///마커 클릭시 카페 정보 바텀 시트
        _bottomController = _modelScaffoldKey.currentState!.showBottomSheet(
          (context) => Container(
            width: Get.width,
            height: 300,
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: grayColor2,
                  spreadRadius: 3,
                  blurRadius: 20,
                  offset: Offset(0, -1),
                )
              ]
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 12),
                    child: Row(
                      children: [
                        Text(
                          '${points[i]['place_name']}', style: f16gray800w700,),
                        Spacer(),
                        Text(
                            '현위치에서 ' +
                                getDistance(double.parse('${points[i]['y']}'),
                                    double.parse('${points[i]['x']}')),
                            style: f12mw500),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Divider(
                    color: Color(0xffEBEBEB),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '주소',
                          style: f16gray800w700,
                        ),
                        const SizedBox(height: 7,),
                        Text(
                          '${points[i]['road_address_name']}',
                          style: f12gray800w500,
                        ),
                        const SizedBox(height: 30,),
                        Text(
                          '전화번호',
                          style: f16gray800w700,
                        ),
                        const SizedBox(height: 7,),
                        Text('${points[i]['phone']}', style: f12gray800w500,),
                      ],
                    ),
                  ),
                  Spacer(),
                  ButtonStyle1(
                    text: '확인',
                    ontap: () {
                      var point = points[i];
                      print("?????");
                      print(point);

                      print(NLatLng(latitude, longitude).distanceTo(NLatLng(
                          double.parse('${points[i]['y']}'),
                          double.parse('${points[i]['x']}'))));
                      //Get.to(AddSchedule(),arguments: point);
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
          ),
        );
      });
    }
  }

  String getDistance(double y, double x) {
    // double distance =
    //     (NLatLng(latitude, longitude).distanceTo(NLatLng(y, x)));
    int distance =
        (NLatLng(latitude, longitude).distanceTo(NLatLng(y, x))).toInt();
    print('distance???${distance}');
    String result = distance >= 1000 ? '${(distance * 0.001).toStringAsFixed(1)}Km' : '${distance}M';

    return result;
  }

  Future<void> getLocationData() async {
    Location location = Location();
    await location.getCurrentLocation();
    print("latitude? : ${location.latitude}");
    print("longitude? : ${location.longitude}");
    latitude = location.latitude;
    longitude = location.longitude;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          key: _modelScaffoldKey,
          resizeToAvoidBottomInset: false,
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(
                  children: [
                    NaverMap(
                      onMapTapped: (point, latLng) {
                        FocusScope.of(context).unfocus();
                        _bottomController!.close();
                        },
                      options: NaverMapViewOptions(
                          locationButtonEnable: true,
                          //zoomGesturesEnable: false, /// 줌제한
                          extent: NLatLngBounds(
                            /// 지도 영역 한반도 인근으로 제한
                            southWest: NLatLng(31.43, 122.37),
                            northEast: NLatLng(44.35, 132.0),
                          ),
                          initialCameraPosition: NCameraPosition(
                              target: NLatLng(latitude, longitude),
                              zoom: 13,
                              bearing: 0,
                              tilt: 0)),
                      onMapReady: (controller) async {
                        _mapController = controller;

                        initializeMap();

                        print('네이버 맵 로딩완료!');
                        final locationOverlay =
                            await _mapController.getLocationOverlay();
                        locationOverlay.setPosition(NLatLng(latitude, longitude));
                        locationOverlay.setIsVisible(true);

                        ///마커 하나만 추가
                        //var marker1 = NMarker(id: '1', position:  NLatLng(latitude, longitude));
                        // _mapController.addOverlay(marker1);
                        // marker1.setOnTapListener(
                        //         (overlay) => print('마커 선ㅌ'));
                        //_mapController.addOverlayAll({marker1,marker2,marker3});
                      },
                    ),

                    ///지도 상단 검색버튼
                    Positioned(
                        top: 50,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 64,
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
                            padding: const EdgeInsets.only(
                                left: 12, right: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: ()async{
                                    print('1111');
                                    await getCafeList(searchController.text);
                                    setState(() {


                                    });
                                  },
                                  child: SizedBox(
                                      height: 15,
                                      child: SvgPicture.asset('assets/icon/search.svg')),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                        EdgeInsets.only(left: 4),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                        hintText: '카페 검색  예)구암동 카페',
                                        hintStyle: f12w300HintGray),
                                  ),
                                ),
                                SizedBox(width: 20,),
                                ///검색설정
                                GestureDetector(
                                  onTap: () async {
                                    _bottomController = _modelScaffoldKey.currentState!.showBottomSheet(
                                            (context) => StatefulBuilder(
                                            builder: (context,StateSetter setState) {
                                              return Container(
                                                width: Get.width,
                                                height: 340,
                                                decoration: BoxDecoration(
                                                    color: whiteColor,
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: grayColor2,
                                                        spreadRadius: 3,
                                                        blurRadius: 20,
                                                        offset: Offset(0, -1),
                                                      )
                                                    ]
                                                ),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 28, left: 24, right: 24),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('지역선택',style: f17bw500,),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          Row(
                                                            children: [
                                                              DropDownService(
                                                                  width: 140,
                                                                  item: _items,
                                                                  onChange: (v) async{
                                                                    manageValue = v as String;
                                                                    _items2 = await getDropList(manageValue);
                                                                    manageValue2 = _items2[0];
                                                                    setState(()  {

                                                                    });},
                                                                  selectedValue: manageValue),
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                              DropDownService(
                                                                  width: 160,
                                                                  item: _items2,
                                                                  onChange: (v) {
                                                                    manageValue2 = v as String;
                                                                    setState(() {

                                                                    });},
                                                                  selectedValue: manageValue2),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 40,
                                                          ),
                                                          Text('카페종류',style: f17bw500,),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          Row(
                                                            children: [
                                                              ButtonStyle2(
                                                                  text: '프렌차이즈',
                                                                  ontap: (){
                                                                    setState(() {
                                                                      value = '프렌차이즈';
                                                                    });
                                                                  },
                                                                  value: value
                                                              ),
                                                              Spacer(),
                                                              ButtonStyle2(
                                                                  text: '일반 카페',
                                                                  ontap: (){
                                                                    setState(() {
                                                                      value = '일반 카페';
                                                                    });
                                                                  },
                                                                  value: value
                                                              ),
                                                              Spacer(),
                                                              ButtonStyle2(
                                                                  text: '스터디 카페',
                                                                  ontap: (){
                                                                    setState(() {
                                                                      value = '스터디 카페';
                                                                    });
                                                                  },
                                                                  value: value
                                                              ),

                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    ButtonStyle1(
                                                      text: '검색설정',
                                                      ontap: () async {
                                                        String cafeValue = '';
                                                        value == '프렌차이즈'?cafeValue = '스타벅스':cafeValue = value;
                                                        searchController.text = '${manageValue} ${manageValue2} ${cafeValue}';
                                                        print(searchController.text);
                                                        await getCafeList(searchController.text);
                                                        Get.back();


                                                        setState(() {});
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                        )
                                    );



                                    setState(() {

                                    });
                                  },
                                  child: SizedBox(
                                      child: SvgPicture.asset('assets/icon/equalizer.svg')),
                                ),


                              ],
                            ),
                          ),
                        )
                    )
                  ],
                )),
    );
  }
/// 카페 정보를 가져오는 함수
  Future<void> getCafeList(String location)async{
    points.clear();
    print('클릭중 ${location}');
    final url = 'http://localhost:1234/cafeSearch?searchText=${location} 카페';

    final response = await http.get(Uri.parse(url),);
    var resJson = json.decode(response.body);
    print('받은 값들은 ???????${resJson['documents']}');
    ///seacrhList = resJson['documents'];
    List<dynamic> newSearchList = resJson['documents'];
    points.addAll(newSearchList);
    initializeMap();

    //print('받은 값들은 ???????${resJson['documents'][0]['address_name']}');

    // _items2 = responseList;
    // manageValue2 = _items2[0];
  }
}
