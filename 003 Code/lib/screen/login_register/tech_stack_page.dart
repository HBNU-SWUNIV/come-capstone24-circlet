import 'dart:ffi';

import 'package:circlet/components/components.dart';
import 'package:circlet/screen/login_register/add_github_page.dart';
import 'package:circlet/util/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../provider/user_state.dart';
import '../../util/font/font.dart';



class TechStackPage extends StatefulWidget {
  const TechStackPage({super.key});

  @override
  State<TechStackPage> createState() => _TechStackPageState();
}

class _TechStackPageState extends State<TechStackPage> {
  TextEditingController techStackController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  List techList = ['Flutter', 'Java', 'JavaScript', 'Kotlin', 'React', 'Rust', 'Swift', 'Node.js','Spring', 'React Native', 'Python', 'MATLAB'];
  List filteredlist = [];
  List selectedTechList = [];
  final us = Get.put(UserState());

  @override
  void initState(){
    super.initState();
    techStackController.clear();
    print(techStackController.text);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyledAppBar(text: '기술스텍 등록',),
      body: Padding(
        padding: EdgeInsets.only(top: 28, left: 12, right: 12, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '사용하는 기술스텍이 있으신가요?',
                style: f21bw700,
              ),
            ),
            const SizedBox(
              height: 29,
            ),
            SearchBar(
              controller: techStackController,
              hintText: 'ex) Flutter',
              hintStyle: MaterialStateProperty.all(f14w300HintGray),
              trailing: [
                Icon(Icons.search),
              ],
              backgroundColor: MaterialStatePropertyAll(whiteColor),
              surfaceTintColor: MaterialStatePropertyAll(Colors.transparent),
              shape: MaterialStateProperty.all(
                ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              side: MaterialStateProperty.all(
                  BorderSide(width: 1.5, color: Color(0xffEBEBEB))),
              padding: MaterialStateProperty.all(EdgeInsets.all(10)),
              constraints: BoxConstraints(maxHeight: 100),
              shadowColor: MaterialStatePropertyAll(Colors.transparent),
              onChanged: (v) {
                print(v);
                setState(() {
                  filteredlist = techList
                      .where((element) =>
                  (element.toLowerCase().contains(v.toLowerCase())) &&
                      (v.isNotEmpty))
                      .toList();
                });
              },
            ),
            SizedBox(
              height: 20,
            ),
            techStackController.text.isNotEmpty?
            SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Container(
                  height: 250,
                  child: ListView.builder(
                    itemCount: filteredlist.length>0?filteredlist.length:0,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
                        child: Container(
                          child: GestureDetector(
                            onTap: () {
                              print(filteredlist[index]);
                              selectedTechList.add(filteredlist[index]);
                              techStackController.clear();
                              filteredlist.clear();
                              setState(() {});
                            },
                            child: Text(
                              filteredlist[index],
                              style: f15bw400,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ))
            :Container(),

            selectedTechList.isNotEmpty&&techStackController.text.isEmpty?
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 26,
                  ),
                  Text(
                    '등록한 기술스텍',
                    style: f14bw300,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    spacing: 5,
                    // 좌우 간격
                    runSpacing: 5,
                    // 상하 간격
                    children: selectedTechList.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final String tech = entry.value;
                      return Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: 7, right: 30, top: 10, bottom: 10),
                            decoration: BoxDecoration(
                              color: darkGrayColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              tech,
                              style: f16w300,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 6,
                            child: GestureDetector(
                              onTap: () {
                                // 해당 요소를 리스트에서 삭제
                                setState(() {
                                  selectedTechList.removeAt(index);
                                });
                              },
                              child: Container(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                ],
              ),
            )
            :Container(),
            Spacer(),
            GestureDetector(
              onTap: () {
                //print(selectedTechList);
                us.techStack.value = selectedTechList;
                print('selectedTechList ??');
                print(us.techStack.value);
                Get.to(() => AddGithubPage());
                setState(() {});
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Color(0xff3648EB),
                    borderRadius: BorderRadius.circular(5)),
                child: Center(
                  // 텍스트를 가운데에 위치시키기 위해 Center 위젯 추가
                  child: Text(
                    '다음',
                    style: TextStyle(color: Color(0xffFFFFFF), fontSize: 18),
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
