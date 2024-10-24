import 'dart:convert';


import 'package:circlet/screen/study/schedule/add_schedule.dart';
import 'package:circlet/util/color.dart';
import 'package:circlet/util/font/font.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../components/components.dart';
import '../../firebase/api.dart';
import '../../util/keys.dart';
import 'location.dart';

class StudyCafeMain extends StatefulWidget {
  const StudyCafeMain({super.key});

  @override
  State<StudyCafeMain> createState() => _StudyCafeMainState();
}

class _StudyCafeMainState extends State<StudyCafeMain> {
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
  String value = ''; ///카페종류 선택

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
                    text: '장소등록',
                    ontap: () {
                      List placeInfo = [
                        '${points[i]['place_name']}',
                        double.parse('${points[i]['y']}'),
                        double.parse('${points[i]['x']}')];
                      Get.back();
                      Get.back(result: placeInfo);
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
    return Scaffold(
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

                      print('스터디 네이버 맵 로딩완료!');
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
              ));
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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_naver_map/flutter_naver_map.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// //import 'package:mosinda/components/dalogs.dart';
// //import 'package:mosinda/components/loading.dart';
// //import 'package:mosinda/provider/map_state.dart';
// //import 'package:mosinda/util/location.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:url_launcher/url_launcher.dart';
// //import '../../../components/dropdown_service.dart';
// //import '../../../components/text_button.dart';
// import '../../../util/font/font.dart';
// import '../../../util/hospitalLink.dart';
// import '../../../util/loading.dart';
// import 'dart:io' show Platform;
// class HospitalMain extends StatefulWidget {
//   const HospitalMain({Key? key}) : super(key: key);
//
//   @override
//   State<HospitalMain> createState() => _HospitalMainState();
// }
//
// class _HospitalMainState extends State<HospitalMain> {
//   /// controller
//   final TextEditingController _searchController = TextEditingController();
//
//   final ms = Get.put(MapState());
//   double nowLatitude = 0;
//   double nowLongitude = 0;
//   bool _isLoading = true;
//   List points = [];
//   late NaverMapController _mapController;
//   bool isSearch = false;
//   final offset = 0.0103; /// 100m 정도
//   double radius = 50000; /// m당
//   String value = '';
//   PersistentBottomSheetController? _bottomController;
//   final GlobalKey<ScaffoldState> _modelScaffoldKey = GlobalKey<ScaffoldState>();
//   FocusNode _searchFocusNode = FocusNode();
//   List<NLatLng> roadList = []; /// 길찾기 리스트
//   ///drop
//   final List<String> _items =  ['서울시', '부산시', '인천시', '대구', '대전', '광주', '울산', '경기도', '충북', '충남', '전북', '전남', '경북', '경남', '강원도', '제주시'];
//   List<String> _items2 =  [];
//   String manageValue = '서울시';
//   String? manageValue2;
//   @override
//   void initState() {
//     Future.delayed(Duration.zero,()async{
//       await getLocation();
//       await getDropList('서울시');
//       _isLoading = false;
//       setState(() {});
//     });
//     super.initState();
//   }
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _bottomController?.close;
//     _mapController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _modelScaffoldKey,
//       resizeToAvoidBottomInset: false,
//       body: _isLoading?LoadingScreen():Stack(
//         children: [
//           NaverMap(
//               onMapTapped: (point, latLng) {
//                 FocusScope.of(context).unfocus();
//                 _bottomController!.close();
//               },
//               options:NaverMapViewOptions(
//                 zoomGesturesEnable: true,
//                 /// 내 위치 알려주는 버튼
//                 locationButtonEnable: true,
//                 // maxZoom: 16,
//                 // minZoom: 13,
//                 // extent: NLatLngBounds(
//                 //   southWest: NLatLng(nowLatitude - offset/2.0, nowLongitude - offset/2.0),
//                 //   northEast: NLatLng(nowLatitude + offset/2.0, nowLongitude + offset/2.0),
//                 // ),
//
//                 initialCameraPosition: NCameraPosition(
//                   target: NLatLng(nowLatitude, nowLongitude),
//                   zoom: 13,
//                   bearing: 0,
//                   tilt: 0,
//                 ),
//               ),
//               onMapReady: (NaverMapController controller) async{
//                 _mapController = controller;
//                 initializeMap();
//               }
//           ),
//           /// 검색설정 클릭
//           Positioned(
//             top: 50,
//             right: 10,
//             left: 10,
//             child: Container(
//               width: Get.width,
//               height: 62,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(60),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     blurRadius: 5,
//                     offset: Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                         onTap: ()async{
//                           await hospitalSearch(_searchController.text);
//                           // String url = 'https://dapi.kakao.com/v2/local/search/keyword.json?query=${_searchController.text}&page=1&size=10';
//                           //     var res = await http.get(Uri.parse(url), headers: {"Authorization": "KakaoAK 714a0764132e3b476b2a07d31cb22416"});
//                           //     var resJson = json.decode(res.body);
//                           //     points = resJson['documents'];
//                           //     isSearch = true;
//                           //     initializeMap();
//                           //     _bottomController!.close();
//                           //     FocusScope.of(context).unfocus();
//                           //     setState(() {});
//                         },
//                         child: SvgPicture.asset('assets/icon/search.svg')),
//                     Expanded(
//                       child: TextFormField(
//                         onFieldSubmitted: (v)async{
//                           await hospitalSearch(_searchController.text);
//                         },
//                         autofocus: false,
//                         focusNode: _searchFocusNode,
//                         controller: _searchController,
//                         textAlignVertical: TextAlignVertical.center,
//                         decoration: InputDecoration(
//                           contentPadding: EdgeInsets.fromLTRB(4, 17.5, 4, 0),
//                           border: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                           ),
//                           hintText: '검색어를 입력하세요',
//                           hintStyle: f14w600,
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: (){
//                         _bottomController = _modelScaffoldKey.currentState!.showBottomSheet(
//                             backgroundColor: Colors.white,
//                                 (context) => StatefulBuilder(
//                               builder: (context,StateSetter setState){
//                                 _searchFocusNode.unfocus();
//                                 return Container(
//                                   color: Colors.white,
//                                   height: 300,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Center(child: Image.asset('assets/icon/underbar.png')),
//                                             const SizedBox(height: 16,),
//                                             Text('병원 종류',style: f14bw700,),
//                                             const SizedBox(height: 10,),
//                                             Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: ButtonStyle2(
//                                                     text: '요양병원',
//                                                     onPressed: () {
//                                                       value = '요양병원';
//                                                       setState((){});
//                                                     },
//                                                     value: value,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 8,),
//                                                 Expanded(
//                                                   child: ButtonStyle2(
//                                                     text: '암요양병원',
//                                                     onPressed: () {
//                                                       value = '암요양병원';
//                                                       setState((){});
//                                                     },
//                                                     value: value,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 8,),
//                                                 Expanded(
//                                                   child: ButtonStyle2(
//                                                     text: '요양원',
//                                                     onPressed: () {
//                                                       value = '요양원';
//                                                       setState((){});
//                                                     },
//                                                     value: value,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 8,),
//                                                 Expanded(
//                                                   child: ButtonStyle2(
//                                                     text: '종합병원',
//                                                     onPressed: () {
//                                                       value = '종합병원';
//                                                       setState((){});
//                                                     },
//                                                     value: value,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 20,),
//                                             Text('지역 선택',style: f14bw700),
//                                             const SizedBox(height: 8,),
//                                             Row(
//                                               children: [
//                                                 DropDownService(
//                                                     widths: 140,
//                                                     title: 'title',
//                                                     items: _items,
//                                                     selectedValue: manageValue,
//                                                     onChanged: (v)async{
//                                                       showLoading(context);
//                                                       manageValue = v as String;
//                                                       await getDropList(manageValue).then((value){
//                                                         Get.back();
//                                                       });
//                                                       setState(() {});
//                                                     }),
//                                                 const SizedBox(width: 8,),
//                                                 DropDownService(
//                                                     widths: 140,
//                                                     title: 'title',
//                                                     items: _items2,
//                                                     selectedValue: manageValue2,
//                                                     onChanged: (v){
//                                                       manageValue2 = v as String;
//                                                       setState(() {});
//                                                     }),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(height: 24,),
//                                       Expanded(child: ButtonStyle3(text: '설정',onPressed: ()async{
//                                         if(value ==''){
//                                           showOnlyConfirmDialog(context, '병원 종류를 선택해주세요');
//                                         }else{
//                                           _searchController.text = '${manageValue} ${manageValue2} ${value}';
//                                           await hospitalSearch(_searchController.text);
//                                         }
//                                       },))
//                                     ],
//                                   ),
//                                 );
//                               },
//                             )
//                         );
//                       },
//                       child: Container(
//                         width: 100,
//                         height: 40,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SvgPicture.asset('assets/icon/sort.svg'),
//                             const SizedBox(width: 4,),
//                             Text('검색설정',style: f14Bluebw600,),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       // floatingActionButton: GestureDetector(
//       //   onTap: ()async{
//       //     String url = 'https://dapi.kakao.com/v2/local/search/keyword.json?query=대전 신성동 치과&page=1&size=10';
//       //     var res = await http.get(Uri.parse(url), headers: {"Authorization": "KakaoAK 714a0764132e3b476b2a07d31cb22416"});
//       //     var resJson = json.decode(res.body);
//       //     points = resJson['documents'];
//       //     isSearch = true;
//       //     radius = 200;
//       //     initializeMap();
//       //     print('이게뭐야?? ${points}');
//       //     setState(() {});
//       //   },
//       //   child: Container(
//       //     width: 50,
//       //     height: 50,
//       //     color: Colors.red,
//       //     child: Icon(Icons.add),
//       //   ),
//       // ),
//     );
//   }
/// 지도 초기화
//   void initializeMap() async {
//     /// 지도 초기화 코드
//     final iconImage = await NOverlayImage.fromAssetImage('assets/icon/pin.png');
//     _mapController.clearOverlays();
//     _mapController.setLocationTrackingMode(NLocationTrackingMode.follow);
//     for (int i = 0; i < points.length; i++) {
//       final marker = NMarker(
//         id: '${points[i]['id']}',
//         position: NLatLng(double.parse('${points[i]['y']}'), double.parse('${points[i]['x']}'),),
//         icon: iconImage,
//         size: Size(50, 50),
//       );
//       _mapController.addOverlay(marker);
//       // /// 내 위치 기준으로 몇 미터 반경 원 그리기
//       // final circleOverlay = NCircleOverlay(
//       //   id: 'testsss',
//       //   radius: radius,
//       //   center: NLatLng(nowLatitude, nowLongitude),
//       //   color: Colors.red.withOpacity(0.2), /// 원의 색상
//       //   outlineColor: Colors.transparent, /// 원의 테두리 색상
//       //   // outlineWidth: 2, /// 테두리 두께
//       // );
//       // _mapController.addOverlay(circleOverlay);
//       /// 마커 클릭 시 이동 코드
//       marker.setOnTapListener((NMarker marker) {
//         final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
//           target: NLatLng(double.parse('${points[i]['y']}'), double.parse('${points[i]['x']}')),
//           zoom: 16,
//         )..setPivot(NPoint(0.5, 0.5));
//         cameraUpdate.setAnimation(animation: NCameraAnimation.easing, duration: Duration(seconds: 3));
//         NLatLng latLng = NLatLng(nowLatitude, nowLongitude);
//         NLatLng selectLatLng = NLatLng(double.parse(points[i]['y']),double.parse('${points[i]['x']}'));
//         double distance = latLng.distanceTo(selectLatLng);
//         _mapController.updateCamera(cameraUpdate);
//         _bottomController = _modelScaffoldKey.currentState!.showBottomSheet(
//                 (context) => Container(
//               width: Get.width,
//               height: 300,
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         SizedBox(
//                             width: Get.width*0.6,
//                             child: Text('${points[i]['place_name']}',style: f16bw700,overflow: TextOverflow.ellipsis,)),
//                         Text('~ ${(distance/1000).toStringAsFixed(1)}Km',style: f16w700Primary,)
//                         // Text('${~ 0.01km}')
//                       ],),
//                     const SizedBox(height: 30,),
//                     Text('주소',style: f14bw700,),
//                     const SizedBox(height: 4,),
//                     Text('${points[i]['address_name']}',style: f14Gw500,),
//                     const SizedBox(height: 10,),
//                     Text('전화번호',style: f14bw700,),
//                     const SizedBox(height: 4,),
//                     GestureDetector(
//                         onTap: ()async{
//                           final String phoneNumber = points[i]['phone'];
//                           final cleanPhoneNumber = phoneNumber.replaceAll('-', '');
//                           if (Platform.isAndroid) {
//                             showComponentDialog(context, '해당 번호를 전화하시겠습니까?', () async{
//                               final url = Uri.parse('tel:$cleanPhoneNumber');
//                               if (await canLaunchUrl(url)) {
//                                 launchUrl(url);
//                               }
//                             });
//                           } else if (Platform.isIOS) {
//                             final url = Uri.parse('tel:$cleanPhoneNumber');
//                             if (await canLaunchUrl(url)) {
//                               launchUrl(url);
//                             }
//                           }
//
//                         },
//                         child: Text('${points[i]['phone']}',style: f14w500Primary,)),
//                     const SizedBox(height: 10,),
//                     Text('홈페이지',style: f14bw700,),
//                     const SizedBox(height: 4,),
//                     GestureDetector(
//                         onTap: (){
//                           showComponentDialog(context, '클릭하신 링크로 이동하시겠습니까?', () {
//                             Get.back();
//                             Get.to(()=>HospitalLink(uri: '${points[i]['place_url']}',));
//                           });
//                         },
//                         child: Text('${points[i]['place_url']}',style: f14GUnderw500,)),
//                     const SizedBox(height: 10,),
//                     Container(
//                       width: Get.width,
//                       height: 50,
//                       child: ButtonStyle2(
//                         text: '길찾기',
//                         onPressed: () async{
//                           await getRoad([nowLatitude,nowLongitude],[double.parse(points[i]['y']),double.parse(points[i]['x'])]).then((value){
//                             var bounds = NLatLngBounds.from([
//                               selectLatLng,
//                               latLng,
//                             ]);
//                             /// 길찾기 오버레이
//                             final arrowheadPathOverlay =  NArrowheadPathOverlay(
//                                 id: "test",
//                                 coords: roadList,
//                                 outlineColor:Colors.red, /// 선색상
//                                 color: Colors.green); /// 오버레이 색상
//                             /// 시작지점
//                             final marker = NMarker(
//                               id: 'startPoint',
//                               position: latLng,
//                               icon: iconImage,
//                               size: Size(50, 50),
//                             );
//                             /// 끝점
//                             final marker2 = NMarker(
//                               id: 'endPoint',
//                               position: selectLatLng,
//                               icon: iconImage,
//                               size: Size(50, 50),
//                             );
//                             _mapController.clearOverlays();
//                             _mapController.addOverlay(arrowheadPathOverlay);
//                             _mapController.addOverlay(marker);
//                             _mapController.addOverlay(marker2);
//                             _mapController.updateCamera(NCameraUpdate.fitBounds(bounds,padding: EdgeInsets.all(100)));
//                             // NCameraUpdate.fitBounds(bounds);
//                             Get.back();
//                             setState(() {});
//                           });
//                         },
//                         value: '길찾기',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//         );
//       });
//     }
//     /// 검색했을 시
//     if(isSearch){
//       final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
//         target: NLatLng(double.parse('${points[0]['y']}'), double.parse('${points[0]['x']}')),
//         zoom: 11,
//       )..setPivot(NPoint(0.5, 0.5));
//       cameraUpdate.setAnimation(animation: NCameraAnimation.easing, duration: Duration(seconds: 1));
//       _mapController.updateCamera(cameraUpdate);
//     }
//
//   }
//
//   Future<void> getLocation() async {
//     var status = await Permission.location.status;
//     if(status.isDenied){
//       PermissionStatus permissionStatus = await Permission.location.request();
//       Location location = Location();
//       await location.getCurrentLocation();
//       nowLatitude = location.latitude;
//       nowLongitude = location.longitude;
//     }else{
//       PermissionStatus permissionStatus = await Permission.location.request();
//       Location location = Location();
//       if (permissionStatus == PermissionStatus.granted) {
//         await location.getCurrentLocation();
//         nowLatitude = location.latitude;
//         nowLongitude = location.longitude;
//         setState(() {});
//       }else if(permissionStatus==PermissionStatus.permanentlyDenied){
//         showOnlyConfirmTapDialog(context, '위치 권한을 설정해주세요', () async{
//           Get.back();
//           await openAppSettings().then((value){
//             setState(() {});
//           });
//         });
//       }
//     }
//   }
//
//   /// 드롭박스 리스트 가져오기
//   Future<void> getDropList(String sido) async {
//     final url = 'http://misnetwork.iptime.org:3344/sigungu';
//     final body = ({
//       'sido': '${sido}',
//     });
//     final response = await http.post(Uri.parse(url), body: body);
//     List<String> responseList = (jsonDecode(response.body) as List<dynamic>).cast<String>();
//     List<String> _itemsd = responseList;
//     _items2 = _itemsd;
//     manageValue2 = _items2[0];
//     if (response.statusCode != 200) {
//       throw Exception('Failed to send email');
//     }
//   }
//   /// 검색 요청하기
//   Future<void> hospitalSearch(String search) async {
//     points.clear();
//     final url = 'http://misnetwork.iptime.org:3344/hospitalSearch?searchText=${search}';
//     final response = await http.get(Uri.parse(url));
//     var resJson = json.decode(response.body);
//
//     List<dynamic> newPoints = resJson['points'];
//
//
//     points.addAll(newPoints);
//     isSearch = true;
//     initializeMap();
//     _bottomController?.close();
//     FocusScope.of(context).unfocus();
//     setState(() {});
//     if (response.statusCode != 200) {
//     }
//   }
//
//
//   /// 길찾기
//   Future<void> getRoad(List start,List end) async {
//     points.clear();
//     final url = 'http://misnetwork.iptime.org:3344/findRoad?start=${start}&end=${end}';
//     final response = await http.get(Uri.parse(url));
//     var resJson = json.decode(response.body);
//     final List<NLatLng> nlatLngList = resJson.map<NLatLng>((coord) => NLatLng(coord[1], coord[0])).toList();
//     roadList = nlatLngList;
//     setState(() {});
//     if (response.statusCode != 200) {}
//   }
// }
