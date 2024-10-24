import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../components/components.dart';
import '../screen/cafe/location.dart';
import 'keys.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  double latitude = 0.0;
  double longitude = 0.0;
  late Map<String, dynamic> schedule;
  late NaverMapController _mapController;
  bool _isLoading = true;

  @override
  void initState() {
    schedule = Get.arguments;
    Future.delayed(Duration.zero, () async {
      await getLocationData();
      await initialize();
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
      appBar: StyledAppBar(
        text: '지도 위치',
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : NaverMap(
              options: NaverMapViewOptions(
                locationButtonEnable: true,
                zoomGesturesEnable: true,
                extent: NLatLngBounds(
                  /// 지도 영역 한반도 인근으로 제한
                  southWest: NLatLng(31.43, 122.37),
                  northEast: NLatLng(44.35, 132.0),
                ),
                initialCameraPosition: NCameraPosition(
                    target: NLatLng(double.parse('${schedule['y']}'),
                        double.parse('${schedule['x']}')),
                    zoom: 13,
                    bearing: 0,
                    tilt: 0),
              ),
              onMapReady: (controller) async {
                _mapController = controller;

                var locationMarker = NMarker(
                    id: '1',
                    position: NLatLng(double.parse('${schedule['y']}'),
                        double.parse('${schedule['x']}')));
                _mapController.addOverlay(locationMarker);
                final locationOverlay =
                await _mapController.getLocationOverlay();
                locationOverlay.setPosition(NLatLng(latitude, longitude));
                locationOverlay.setIsVisible(true);
              },
            ),
    );
  }
}
