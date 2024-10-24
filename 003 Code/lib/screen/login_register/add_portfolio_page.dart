import 'dart:io';
import 'package:circlet/dialog/dialog.dart';
import 'package:circlet/util/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../firebase/firebase_user.dart';
import '../../provider/user_state.dart';
import '../../util/font/font.dart';
import '../main/bottom_navigator.dart';

class AddPortFolioPage extends StatefulWidget {
  const AddPortFolioPage({super.key});

  @override
  State<AddPortFolioPage> createState() => _AddPortFolioPageState();
}

class _AddPortFolioPageState extends State<AddPortFolioPage> {
  final us = Get.put(UserState());
  File? selectedFile;
  String? selectedFileName;
  String? fileName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('포트폴리오 등록',
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
        padding: EdgeInsets.only(top: 28, left: 12, right: 12, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
                text: TextSpan(
                    children: [
                      TextSpan(text: '(선택)',style: f20w500HintGray),
                      TextSpan(text: ' 프로필에 등록하고 싶은 포트폴리오',style: f20bw700,spellOut: true),
                    ])
            ),
            Center(child: Text('가 있나요?',style: f20bw700,)),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                width: Get.width,
                child: Text(
                  '올리신 파일은 사용자 프로필에 명시되며 다른 유저도 볼 수 있습니다. 설정에서 변경 가능합니다.',
                  style: f12bw500,
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                print(us.userDocId.value);
                openPdfFile();
                setState(() {

                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  padding: EdgeInsets.only(left: 24, right: 24),
                  width: Get.width,
                  height: 48,
                  decoration: BoxDecoration(
                      color: darkGrayColor,
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icon/file.svg',
                        width: 20,
                        height: 20,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'PDF 파일등록',
                            style: TextStyle(
                                color: Color(0xffFFFFFF)
                                , fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            selectedFileName!=null? Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2,right: 5),
                  child: Container(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            width: 1,
                            color: blackColor
                        )
                    ),
                    child: Text(selectedFileName!, style: f12bw500,),
                  ),
                ),
                Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        selectedFileName = null;
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: redColor,

                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ))

              ],
            ):Container(),
            Spacer(

            ),
            GestureDetector(
              onTap: () async {
                await firebaseAdd();
                await getUserList('${us.userDocId.value}');
                print('유저의 리스트는??${us.userList.value}');
                showConfirmTapDialog(context, '저희 스터디 어플을 이용할 준비가 모두 완료 되었습니다. 지금 바로 이용해보세요.', () {
                  Get.to(BottomNavigator());
                });
                setState(() {

                });
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Color(0xff3648EB),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Center( // 텍스트를 가운데에 위치시키기 위해 Center 위젯 추가
                  child: Text(
                    '다음',
                    style: TextStyle(
                        color: Color(0xffFFFFFF)
                        , fontSize: 18),
                  ),
                ),
              ),
            )


          ],

        ),
      ),
    );
  }
  void openPdfFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf']
    );

    if(result != null){
      selectedFile= File(result.files.single.path.toString());
      selectedFileName = result.files.first.name;
      print(selectedFile);
      print(selectedFileName);
      setState(() {

      });
    }
}
  Future<void> firebaseAdd ()async{
    await storageAdd();
    CollectionReference ref = FirebaseFirestore.instance.collection('userDetail');
    await ref.add({
      'createDate' : '${DateTime.now()}',
      'docId': '',
      'userId' : us.userDocId.value,
      'interest' : us.interest.value,
      'techStack' : us.techStack.value,
      'introduce' : '',
      'gitUrl' : us.gitUrl.value,
      'blogUrl' : us.blogUrl.value,
      'signUpList': [],
      'studyList': [],
    }).then((doc){
      ref.doc(doc.id).update({'docId':doc.id});
    });
  }
  Future<void> storageAdd ()async{
    if (selectedFile != null) {
        fileName = us.userDocId.value;
        print('버튼눌르므ㅡ');
        //String now = '${DateTime.now()}';
        File file = selectedFile!;
        try {
          await FirebaseStorage.instance.ref("portfolio/${fileName}").putFile(file);
          print("파일 업로드 완료");
        } catch (e) {
          print("파일 업로드 에러: $e");
        }
    } else {
      print("선택된 파일 없음");
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, 10) + '...';
    }
  }
}
