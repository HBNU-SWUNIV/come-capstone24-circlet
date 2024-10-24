import 'dart:convert';

import 'package:http/http.dart' as http;

///시,도로 군구 가져오는 함수
Future<List<String>> getDropList(String sido)async{
  final url = 'http://localhost:1234/sigungu';
  final body = ({
    'sido' : '${sido}',
  });
  final response = await http.post(Uri.parse(url),body: body);
  print('response??${response.body}');
  List<String> responseList = (jsonDecode(response.body) as List<dynamic>).cast<String>();
  return responseList;
  // _items2 = responseList;
  // manageValue2 = _items2[0];
}