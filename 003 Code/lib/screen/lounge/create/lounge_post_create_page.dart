import 'dart:io';
import 'package:circlet/dialog/dialog.dart';
import 'package:circlet/provider/lounge_post_state.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:circlet/util/font/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../components/markdown/code.dart';

class LoungePostCreatePage extends StatefulWidget {
  int selectedTab;

  LoungePostCreatePage({this.selectedTab = 0});

  @override
  State<LoungePostCreatePage> createState() => _LoungePostCreatePageState();
}

class _LoungePostCreatePageState extends State<LoungePostCreatePage> {
  String postCategory = '게시판을 선택하세요';
  int imageCount = 0;
  List<String> boardName = ['취업', 'Q&A', '개발', '홍보', '사는얘기'];
  final TextEditingController titleEditingController = TextEditingController();
  final TextEditingController contentEditingController =
  TextEditingController();
  final TextEditingController codeEditingController = TextEditingController();
  ImagePicker picker = ImagePicker();
  FirebaseStorage storage =
  FirebaseStorage.instanceFor(bucket: 'gs://circlet-9c202.appspot.com');
  List<XFile> images = [];
  UserState us = Get.find<UserState>();
  LoungePostState lps = Get.put(LoungePostState());
  bool isSubmitting = false;
  bool isCodeSectionVisible = false;
  String language = '';
  String code = '';
  List<String> languages = [
    'C',
    'C++',
    'Kotlin',
    'Swift',
    'JavaScript',
    'Python',
    'Java',
    'C#',
  ];

  // 선택된 언어를 저장할 변수
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    if (widget.selectedTab != 0) {
      postCategory = boardName[widget.selectedTab - 1];
    }
  }

  @override
  void dispose() {
    titleEditingController.dispose();
    contentEditingController.dispose();
    codeEditingController.dispose();
    super.dispose();
  }

  void _showLoadingDialog() {
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


  void _dismissLoadingDialog() {
    Get.back();
  }

  Future<void> getImage(ImageSource imageSource) async {
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (imageCount + pickedFiles!.length > 3) {
      OkDialog(context, '이미지는 최대 3개까지 추가할 수 있습니다.', f15bw500);
      return;
    }

    setState(() {
      images.addAll(pickedFiles);
      imageCount = images.length;
    });
  }

  void _removeImage(int index) {
    if (index < 0 || index >= images.length) {
      return;
    }

    setState(() {
      images.removeAt(index);
      imageCount = images.length;
    });
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> imagePaths = [];
    try {
      for (var image in images) {
        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        String fileName = '$timestamp';
        File file = File(image.path);
        Reference storageRef = storage.ref().child('post/$fileName');

        UploadTask uploadTask = storageRef.putFile(
            file,
            SettableMetadata(customMetadata: {
              'created_at': DateTime.now().toString(),
            }));
        await uploadTask;

        String filePath = '$fileName';
        imagePaths.add(filePath);
      }
    } catch (e) {}
    return imagePaths;
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: ListView.builder(
            itemCount: boardName.length,
            itemBuilder: (context, index) {
              return ListTile(
                trailing: widget.selectedTab == index + 1
                    ? Icon(Icons.radio_button_checked)
                    : Icon(Icons.radio_button_unchecked),
                title: Text(boardName[index]),
                onTap: () {
                  setState(() {
                    widget.selectedTab = index + 1;
                    postCategory = boardName[index];
                  });
                  Get.back();
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showCodeInsertDialog() {
    TextEditingController codeController1 = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 320,
            padding:
            const EdgeInsets.only(top: 30, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              // Scrollable to avoid overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$language 코드 입력',
                    style: f18bw700,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: codeController1,
                    decoration: InputDecoration(
                      hintText: 'ex) print("Hello, World!")',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xffEFEFEF),
                      contentPadding: const EdgeInsets.all(10),
                      hintStyle: f14gw500,
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                            onTap: (){Get.back();},
                            child: Container(
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0xffEEEEEE),
                              ),
                              child: Center(child: Text('취소', style: f16dcw400),),
                            ),
                          )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                code = '```$language\n' +
                                    codeController1.text +
                                    '\n```';
                              });
                              Get.back();
                            },
                            child: Container(
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0xff212121),
                              ),
                              child: Center(child: Text('등록', style: f16w400),),
                            ),

                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelectionBottomSheet() {
    String? selectedLanguage = language.toLowerCase();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Container(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 24, top: 30, bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        '언어 선택',
                        style: f18bw700,
                      ),
                    ),
                    ...[
                      'C',
                      'CPP',
                      'Kotlin',
                      'Python',
                      'Java',
                      'JavaScript',
                      'Dart',
                      'ObjectiveC',
                      'PHP',
                      'Ruby',
                      'Go',
                      'HTML',
                      'CSS',
                      '기타'
                    ].map((languageOption) {
                      return Container(
                        color: Colors.white,
                        child: InkWell(
                          onTap: () {
                            if (languageOption == '기타') {
                              _showCustomLanguageInputDialog();
                            } else {
                              setState(() {
                                selectedLanguage = languageOption.toLowerCase();
                                language = selectedLanguage!;
                              });
                              Get.back();
                              _showCodeInsertDialog();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  languageOption,
                                  style: f16bw500,
                                ),
                                Radio<String>(
                                  value: languageOption.toLowerCase(),
                                  groupValue: selectedLanguage,
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedLanguage = value;
                                      language = value!;
                                    });
                                    Get.back();
                                    _showCodeInsertDialog();
                                  },
                                  activeColor: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  void _showCustomLanguageInputDialog() {
    final TextEditingController _customLanguageController =
    TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 320,
            padding:
            const EdgeInsets.only(top: 30, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              // Scrollable to avoid overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '원하시는 언어를 입력해주세요',
                    style: f20bw700,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _customLanguageController,
                    decoration: InputDecoration(
                      hintText: 'ex) php',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xffEFEFEF),
                      contentPadding: const EdgeInsets.all(10),
                      hintStyle: f14gw500,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 130,
                        height: 58,
                        child: TextButton(
                          child: Text('취소', style: f16dcw400),
                          onPressed: () {
                            Get.back();
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            backgroundColor: const Color(0xffEEEEEE),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 130,
                        height: 58,
                        child: TextButton(
                          child: Text(
                            '확인',
                            style: f16w400,
                          ),
                          onPressed: () {
                            final customLanguage =
                            _customLanguageController.text.trim();
                            if (customLanguage.isNotEmpty) {
                              setState(() {
                                language = customLanguage;
                              });
                              Get.back();
                              _showCodeInsertDialog();
                            }
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            backgroundColor: const Color(0xff212121),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> uploadPost() async {
    if (!isSubmitting) {
      setState(() {
        isSubmitting = true;
      });
      _showLoadingDialog();
      try {
        CollectionReference ref =
        FirebaseFirestore.instance.collection('loungePostInfo');

        final DateTime now = DateTime.now();
        final DateFormat formatter = DateFormat('yyyy년 M월 d일 a h:mm', 'ko_KR');
        final String formattedDate = formatter.format(now);

        List<String> imagePaths = await _uploadImages(images);

        DocumentReference docRef = await ref.add({
          'studyId': '',
          'docId': '',
          'createDate': '$now',
          'date': formattedDate,
          'userDocId': us.userList[0]['docId'],
          'nickname': us.userList[0]['nickname'],
          'category': boardName[widget.selectedTab - 1],
          'title': titleEditingController.text,
          'content': contentEditingController.text,
          'code': code,
          'commentCount': 0,
          'like': false,
          'likeList': [],
          'likeCount': 0,
          'imagePaths': imagePaths,
          'language': language
        });
        await docRef.update({'docId': docRef.id});
        _dismissLoadingDialog();
        Get.back(result: true);
      } catch (e) {}
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '게시글 등록',
          style: f22bw500,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            color: Color(0xffEBEBEB),
            height: 1,
            thickness: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _showBottomSheet(context);
              },
              child: Container(
                child: Row(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 12),
                      child: Text(
                        widget.selectedTab == 0
                            ? postCategory
                            : boardName[widget.selectedTab - 1],
                        style: f16bw500,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(top: 15, right: 16),
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: Get.width,
              height: 1,
              color: const Color(0xffEBEBEB),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 11, bottom: 6),
              child: TextField(
                controller: titleEditingController,
                decoration: InputDecoration(
                  hintText: '제목',
                  hintStyle:
                  f18gw700,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffEBEBEB)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      // 카메라 권한 요청
                      var status = await Permission.camera.request();

                      // 권한이 허용된 경우에만 이미지를 선택
                      if (status.isGranted) {
                        if (imageCount < 3) {
                          getImage(ImageSource.gallery);
                        } else {
                          OkDialog(context, '이미지는 최대 3개까지 추가할 수 있습니다.', f15bw500);
                        }
                      } else {}
                    },
                    child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1.5, color: Colors.black),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icon/camera.svg'),
                            const SizedBox(height: 5),
                            Text(
                              '${images.length}/3',
                              style: f9bw500,
                            ),
                          ],
                        )),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(images.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.file(
                                  File(images[index].path),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -2,
                              right: -4,
                              child: GestureDetector(
                                onTap: () {
                                  _removeImage(index);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  child: Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Container(
                height: Get.height * 0.4,
                child: TextField(
                  controller: contentEditingController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '내용을 입력해주세요.',
                    hintStyle: f15gw500,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Divider(
              color: Color(0xffD9D9D9),
              height: 1,
              thickness: 2,
            ),
            Container(
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 33, bottom: 33),
                    child: GestureDetector(
                      onTap: () {
                        _showLanguageSelectionBottomSheet();
                      },
                      child: Container(
                        width: 63,
                        height: 59,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xff282828)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            SvgPicture.asset('assets/icon/file-dark.svg'),
                            const SizedBox(height: 3),
                            Text('코드추가',
                                style: f9bw500),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none, // Stack의 clipping을 해제
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: MarkdownBody(
                            key: const Key("defaultmarkdownformatter"),
                            data: code,
                            selectable: true,
                            builders: {
                              'code': CodeElementBuilder(language: language),
                            },
                          ),
                        ),
                        code == ''
                            ? const SizedBox()
                            : Positioned(
                          right: -5, // 오른쪽 여백을 추가하여 아이콘을 위치 조정
                          top: -15, // 위쪽 여백을 추가하여 아이콘을 위치 조정
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                code = '';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          if (widget.selectedTab == 0) {
            OkDialog(context, '게시판을 선택하세요.', f15bw500);
            return;
          }
          if (titleEditingController.text.trim().isEmpty) {
            OkDialog(context, '제목을 입력하세요.', f15bw500);
            return;
          }
          if (contentEditingController.text.trim().isEmpty) {
            OkDialog(context, '내용을 입력하세요.', f15bw500);
            return;
          }
          await uploadPost();
        },
        child: Container(
          height: 50,
          color: Color(0xff3648EB),
          child: Center(
            child: isSubmitting
                ? CircularProgressIndicator(
              color: Colors.white,
            )
                : Text(
              '등록하기',
              style: f22w500,
            ),
          ),
        ),
      ),
    );
  }
}
