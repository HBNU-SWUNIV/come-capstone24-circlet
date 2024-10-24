import 'package:circlet/components/components.dart';
import 'package:circlet/dialog/dialog.dart';
import 'package:circlet/screen/login_register/tech_stack_page.dart';
import 'package:circlet/util/font/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../provider/user_state.dart';

class InterestPage extends StatefulWidget {
  const InterestPage({super.key});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  final us = Get.put(UserState());

  List iconList = [
    'assets/icon/apple.svg',
    'assets/icon/android.svg',
    'assets/icon/web.svg',
    'assets/icon/game.svg',
    'assets/icon/security.svg',
    'assets/icon/server.svg',
    'assets/icon/frontEnd.svg',
    'assets/icon/embedded.svg',
    'assets/icon/ai.svg',
  ];
  List iconNameList = [
    'IOS',
    '안드로이드',
    '',
    '게임',
    '네트워크/보안',
    '백엔드/서버',
    '프론트엔드',
    '임베디드',
    '인공지능',
  ];
  List clickList = [];
  @override
  void initState() {
    clickList = List.generate(9, (index) => false);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관심분야',
          style: f22bw500,),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1), // Divider의 높이 설정
          child: Divider(
            color: Color(0xffEBEBEB), // Divider의 색상 설정
            height: 1, // Divider의 높이 설정
            thickness: 1, // Divider의 두께 설정
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 12, right: 12,bottom: 100),
        child: Center(
          child: Column(
            children: [
              Text('어떤분야갸 관심있으신가요?',style: f21bw700,),
              const SizedBox(
                height: 9,
              ),
              Text('관심분야는 프로필에 명시되며 설정에서 변경가능합니다.',style: f12bw500,),
              const SizedBox(
                height: 26,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  child: GridView.builder(
                      itemCount: 9,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                        childAspectRatio: 1 / 1, //item 의 가로 1, 세로 1 의 비율
                        mainAxisSpacing: 10, //수직 Padding
                        crossAxisSpacing: 10, //수평 Padding
                      ),
                      itemBuilder:  (BuildContext context,int index){
                        // return Text(index.toString());
                        return IconText(image: iconList[index], text: iconNameList[index], ontap: (){
                          clickList[index] = !clickList[index];
                          setState(() {});
                        },isLarge: true,check: clickList[index],);
                      },
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              GestureDetector(
                onTap: (){
                  if(clickList.any((element) => element == true)){
                    List<String> filteredList = [];
                    for (int i = 0; i < clickList.length; i++) {
                      if (clickList[i]) {
                        filteredList.add(iconNameList[i]);
                      }
                    }
                    us.interest.value = filteredList;
                    print('doc???');
                    print(us.userDocId.value);
                    print('interest???');
                    print(us.interest.value);
                    Get.to(TechStackPage());
                  }else{
                    showConfirmTapDialog(context, '반드시 하나 이상의 관심분야를 선택해주세요', () {
                      Get.back();
                    });

                  }

                  setState(() {

                  });

                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: clickList.any((element) => element == true) ? Color(0xff3648EB) : Color(0xffEBEBEB),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center( // 텍스트를 가운데에 위치시키기 위해 Center 위젯 추가
                    child: Text(
                      '다음',
                      style: TextStyle(
                          color: clickList.isEmpty? Color(0xffABABAB):Color(0xffFFFFFF)
                          ,fontSize: 18),
                    ),
                  ),
                ),
              )
            ],

          ),
        ),
      ),


    );
  }
}
