import 'package:circlet/screen/study/create/study_create.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../components/components.dart';
import '../../../dialog/dialog.dart';
import '../../../provider/study_state.dart';
import '../../../util/font/font.dart';
import '../../login_register/tech_stack_page.dart';

class StudyInterest extends StatefulWidget {
  const StudyInterest({super.key});

  @override
  State<StudyInterest> createState() => _StudyInterestState();
}

class _StudyInterestState extends State<StudyInterest> {
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
    '웹',
    '게임',
    '네트워크/보안',
    '백엔드/서버',
    '프론트엔드',
    '임베디드',
    '인공지능',
  ];
  List clickList = [];
  final ss = Get.put(StudyState());
  @override
  void initState() {
    clickList = List.generate(9, (index) => false);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('스터디 개설',
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
              Text('스터디의 관심분야가 무엇인가요?',style: f21bw700,),
              const SizedBox(
                height: 21,
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
                      return IconText(
                        image: iconList[index],
                        text: iconNameList[index],
                        ontap: (){
                          if(clickList[index]){
                            clickList[index] = false;
                          } else{
                            if(clickList.where((element) => element).length<3){
                              clickList[index] = true;
                            }else{
                              Get.snackbar('알림', '최대 3개까지만 선택할 수 있습니다.');
                            }
                          }
                          //clickList[index] = !clickList[index];
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
                    ss.interest.value = filteredList;
                    print('interest???');
                    print(ss.interest.value);

                    Get.to(StudyCreate());
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

