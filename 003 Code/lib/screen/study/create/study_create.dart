import 'dart:io';

import 'package:circlet/dialog/dialog.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:circlet/screen/study/study_home/study_home_page.dart';
import 'package:circlet/util/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../components/components.dart';
import '../../../firebase/api.dart';
import '../../../firebase/firebase_study.dart';
import '../../../firebase/firebase_user.dart';
import '../../../util/font/font.dart';

class StudyCreate extends StatefulWidget {
  const StudyCreate({super.key});

  @override
  State<StudyCreate> createState() => _StudyCreateState();
}

class _StudyCreateState extends State<StudyCreate> {
  bool nameEnable = false;
  TextEditingController studyNameController = TextEditingController();
  TextEditingController studyInfoController = TextEditingController();
  TextEditingController techStackController = TextEditingController();
  List techList = ['Flutter', 'Java', 'JavaScript', 'Kotlin', 'React', 'Rust', 'Swift', 'Node.js','Spring', 'React Native', 'Python', 'MATLAB'];
  List filteredlist = [];
  List selectedTechList = [];
  final us = Get.put(UserState());
  final ss = Get.put(StudyState());
  String validateStudyNameText = '';
  bool _isLoading = false;
  ///스터디 유효성 검사 Text
  bool isStudyNameValid = false;

  ///스터디 이름 유효성 검사 여부
  final List<String> _items = [
    '서울시',
    '부산시',
    '인천시',
    '대구',
    '대전',
    '광주',
    '울산',
    '경기도',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '강원도',
    '제주시'
  ];
  List<String> _items2 = [];
  String manageValue = '서울시';
  String? manageValue2;

  XFile? image;
  final ImagePicker picker = ImagePicker();
  bool uploading = false;
  bool isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      _items2 = await getDropList('서울시');
      manageValue2 = _items2[0];
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: StyledAppBar(text: '스터디개설'),
        body: isLoading
            ? SizedBox()
            : Padding(
          padding: EdgeInsets.only(top: 10, left: 12, right: 12),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '활동지역',
                  style: f17bw500,
                ),
                SizedBox(
                  height: 8,
                ),
                ///시군구
                Row(
                  children: [
                    Container(
                      width: 160,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(width: 1, color: grayColor)),
                      child: Padding(
                        padding: EdgeInsets.only(right: 7),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            iconStyleData: IconStyleData(
                                icon: SvgPicture.asset(
                                    'assets/icon/dropdown.svg'),
                                iconSize: 20),
                            value: manageValue,
                            hint: Text(
                              '시',
                              style: f14bw400,
                            ),
                            items: _items.map((String item) {
                              return DropdownMenuItem<String>(
                                child: Text(
                                  item,
                                  style: f14bw400,
                                ),
                                value: item,
                              );
                            }).toList(),
                            onChanged: (v) async {
                              manageValue = v as String;
                              _items2 = await getDropList(manageValue);
                              manageValue2 = _items2[0];
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 160,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(width: 1, color: grayColor)),
                      child: Padding(
                        padding: EdgeInsets.only(right: 7),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            iconStyleData: IconStyleData(
                                icon: SvgPicture.asset(
                                    'assets/icon/dropdown.svg'),
                                iconSize: 20),
                            value: manageValue2,
                            items: _items2.map((String item) {
                              return DropdownMenuItem<String>(
                                child: Text(
                                  item,
                                  style: f14bw400,
                                ),
                                value: item,
                              );
                            }).toList(),
                            onChanged: (v) {
                              manageValue2 = v as String;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  '스터디 소개',
                  style: f17bw500,
                ),
                SizedBox(height: 8,),
                /// 사진추가
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        getImage(ImageSource.gallery);
                      },
                      child: Container(
                          width: 63,
                          height: 59,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.5, color: lightGrayColor),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                child: SvgPicture.asset(
                                    'assets/icon/camera.svg'),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                '사진추가',
                                style: f9bw500,
                              ),
                            ],
                          )),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    image == null
                        ? SizedBox()
                        : Stack(
                      children: [
                        Positioned(
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.file(
                                File(image!.path),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                image = null;
                                setState(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ))
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                /// 스터디명
                suffixTextFormBox2(
                  hintText: '스터디명을 입력해주세요',
                  textController: studyNameController,
                  enabled: !nameEnable,
                  onTap: () async {
                    if(nameEnable==false){
                      await studyNameDuplicate(studyNameController.text);
                      ss.studyCheckName.value == '1'?
                      showConfirmTapDialog(context, '이미 사용 중인 스터디이름입니다.', () {
                        Get.back();
                        nameEnable = false;
                      })
                          :showConfirmTapDialog(context, '사용 가능한 스터디이름입니다.', () {
                        Get.back();
                        nameEnable = true;
                        setState(() {
                        });
                      });
                    }else{
                      showConfirmTapDialog(context, '스터디 이름을 수정할 수 있습니다.', () {
                        Get.back();
                        nameEnable = false;
                        setState(() {
                        });
                      });
                    }
                    print(isStudyNameValid);
                  },
                  onChange: (v) {
                    setState(() {
                    });
                  },
                  containerText: nameEnable?'수정하기':'중복체크',

                ),
                Text(
                  validateStudyNameText,
                  style: TextStyle(
                      fontSize: 12,
                      color: isStudyNameValid ? greenColor : hintGrayColor),
                ),
                /// 스터디 소개글
                SizedBox(
                  width: Get.width,
                  height: 100,
                  child: BigTextFormBox(
                    hintText: '스터디를 소개할 수 있는 글을 작성해주세요.',
                    textController: studyInfoController,
                    onTap: () {},
                    onChange: (v) {},
                    multiline: 'true',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                /// 스터디 기술스텍
                Text(
                  '스터디 기술스택',
                  style: f17bw500,
                ),
                SizedBox(height: 8,),
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
                const SizedBox(
                  height: 10,
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
                Column(
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
                )
                    :Container(),
                SizedBox(
                  height: 50,
                ),

              ],
            ),
          ),
        ),
        bottomSheet:  GestureDetector(
          onTap: () async {
            if(nameEnable&&ss.studyCheckName == '0'){
              _showLoadingDialog();
              await createStudy();
              Get.back();
              showOnlyConfirmTapDialog(
                  context, '스터디 개설', '스터디 개설이 완료되었습니다.', () {
                Get.back();
                Get.back();
                Get.back();
                Get.to(() => StudyHomePage());
              });
            }else{
              showOnlyConfirmTapDialog(
                  context, '회원가입 실패', '스터디 이름을 확인해주세요', () {
                Get.back();
              });
            }
            setState(() {});
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
                color: Color(0xff3648EB)),
            child: Center(
              child: Text(
                '개설하기',
                style: f18w700,
              ),
            ),
          ),
        )
    );
  }

  /// 이미지를 갤러리에서 가져오는 함수
  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      image = XFile(pickedFile.path);
      setState(() {});
    }
  }


  Future<void> createStudy() async{
    final us = Get.put(UserState());
    final ss = Get.put(StudyState());

    CollectionReference ref = FirebaseFirestore.instance.collection('study');
    CollectionReference userDetailRef = FirebaseFirestore.instance.collection('userDetail');
    try {
      /// 1. 새로운 스터디 문서 생성
      await ref.add({
        'studyName': studyNameController.text,
        'sido' : manageValue,
        'gungu' : manageValue2,
        'signUpList' : [],
        'likeList' : [],
        'docId': '',
        'studyInfo': studyInfoController.text,
        'interest': ss.interest.value,
        'techStack': selectedTechList,
        'createDate': '${DateTime.now()}',
        'studyUserList' : FieldValue.arrayUnion(['${us.userList[0]['docId']}']),
        'studyHost': '${us.userList[0]['nickname']}',
        'studyHostDocId':'${us.userList[0]['docId']}',
      }).then((doc) async {

        /// 2. 생성된 스터디 문서의 docId 업데이트
        DocumentReference studyDocRef = ref.doc(doc.id);
        await studyDocRef.update({'docId':'${doc.id}'});
        ss.studyDocId.value = doc.id;

        /// 3. 생성된 스터디의 데이터를 studyList에 추가
        QuerySnapshot snapshot2 = await ref.where('docId', isEqualTo: doc.id).get();
        final allData = snapshot2.docs.map((doc) => doc.data()).toList();
        ss.studyList.value = allData;

        await storageAddImage(image, '${ss.studyDocId.value}','studyImage' );

        /// 4. 유저디테일 컬렉션의 사용자 문서 찾기
        DocumentReference userDetailDocRef = userDetailRef.doc(us.userDetailList[0]['docId']);
        QuerySnapshot snapshot3 = await userDetailRef.where('docId', isEqualTo: us.userDetailList[0]['docId']).get();
        final userDetailAllData = snapshot3.docs.map((doc) => doc.data()).toList();
        List b = userDetailAllData;
        print('b???${b}');

        /// 5. 기존 유저디테일의 studyList를 가져와서 업데이트
        List studyList = b[0]['studyList'];
        studyList.add(doc.id);
        await userDetailDocRef.update({'studyList': studyList});
      });
    } catch (e) {
      print('에러 $e');
    }

  }

  void _showLoadingDialog() { /// 등록버튼 클릭 시 로딩
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

}

