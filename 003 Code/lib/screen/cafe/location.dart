import 'package:geolocator/geolocator.dart';

class Location{
  double latitude = 0;
  double longitude = 0;

  Future<void> getCurrentLocation() async{
    LocationPermission permission = await Geolocator.checkPermission();
    print('permission???${permission}');

    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한이 여전히 거부됨
        print('Location permissions are denied');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부됨
      print('Location permissions are permanently denied');
      return;
    }

    try{
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );
        latitude = position.latitude;
        longitude = position.longitude;
        print('Current position: ${position.latitude}, ${position.longitude}');
      }catch(e){
        print('위치 정보 수집 실패!!!!');
        print(e);
      }
  }



}