import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../components/markdown/code.dart';
import '../../../dialog/dialog.dart';
import '../../../provider/study_state.dart';
import '../../../util/font/font.dart';
import '../../../util/loadingScreen.dart';

class StudyPostEditPage extends StatefulWidget {
  final Map<String, dynamic> postInfo;
  StudyPostEditPage({required this.postInfo});

  @override
  State<StudyPostEditPage> createState() => _StudyPostEditPageState();
}

class _StudyPostEditPageState extends State<StudyPostEditPage> {
  String postCategory = '게시판을 선택하세요';
  int imageCount = 0;
  List<String> boardName = ['공지사항', '가입인사', '자유', '질문', '모임후기', '자료실'];
  final TextEditingController titleEditingController = TextEditingController();
  final TextEditingController contentEditingController = TextEditingController();
  ImagePicker picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'gs://circlet-9c202.appspot.com');
  List<XFile> images = [];
  List<String> existingImageUrls = []; // 기존 이미지 URL 리스트
  late Future<List<String>> imageUrlsFuture;
  UserState us = Get.find<UserState>();
  List<String> allImagePaths = [];
  bool isSubmitting = false; /// 수정하기 버튼
  StudyState ss = Get.put(StudyState());
  String code = "";
  String language = "";
  @override
  void initState() {
    super.initState();
    if(ss.studyList[0]['studyHost'] != us.userList[0]['nickname'])
      setState(() {
        boardName = ['가입인사', '자유', '질문', '모임후기', '자료실'];
      });
    imageUrlsFuture = _loadPostData(); // 게시글 데이터 로드
  }

  @override
  void dispose() {
    titleEditingController.dispose();
    contentEditingController.dispose();
    super.dispose();
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

  void _dismissLoadingDialog() { /// 로딩 다이얼로그 삭제
    Get.back();
  }

  Future<List<String>> _loadPostData() async {
    List<String> imageUrls = [];
    try {
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance.collection('studyPostInfo').doc(widget.postInfo['docId']).get();
      if (postSnapshot.exists) {
        var data = postSnapshot.data() as Map<String, dynamic>;
        setState(() {
          postCategory = data['category'];
          titleEditingController.text = data['title'];
          contentEditingController.text = data['content'];
          code = data['code'];
          existingImageUrls = List<String>.from(data['imagePaths'] ?? []);
          imageCount = images.length; // 새로 추가된 이미지는 포함하지 않음
          language = data['language'];
        });

        imageUrls = existingImageUrls.map((path) {
          return 'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/post%2F${Uri.encodeComponent(path)}?alt=media';
        }).toList();
      }
    } catch (e) {
    }
    return imageUrls;
  }

  Future<void> getImage(ImageSource imageSource) async {
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles == null || pickedFiles.isEmpty) return;

    if (imageCount + pickedFiles.length > 3) {
      OkDialog(context, '이미지는 최대 3개까지 추가할 수 있습니다.', f15bw500);
      return;
    }

    setState(() {
      images.addAll(pickedFiles);
      imageCount = existingImageUrls.length + images.length;
    });
  }

  void _removeImage(int index) {
    if (index < 0 || index >= images.length + existingImageUrls.length) return;

    setState(() {
      if (index < existingImageUrls.length) {
        // 기존 이미지 삭제 로직
        existingImageUrls.removeAt(index);
      } else {
        // 새로 추가된 이미지 삭제 로직
        images.removeAt(index - existingImageUrls.length);
      }
      imageCount = existingImageUrls.length + images.length;
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

        // 파일 업로드 및 메타데이터 추가
        UploadTask uploadTask = storageRef.putFile(file, SettableMetadata(customMetadata: {
          'created_at': DateTime.now().toString(),
        }));
        await uploadTask;

        // 업로드 완료 후 파일 경로 반환
        String filePath = '$fileName';
        imagePaths.add(filePath);
      }
    } catch (e) {
    }
    return imagePaths;
  }


  // 카테고리 시트
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: ListView.builder(
            itemCount: boardName.length,
            itemBuilder: (context, index) {
              return ListTile(
                trailing: postCategory == boardName[index]
                    ? Icon(Icons.radio_button_checked)
                    : Icon(Icons.radio_button_unchecked),
                title: Text(boardName[index]),
                onTap: () {
                  setState(() {
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

  Future<void> _updatePost() async {
    _showLoadingDialog();
    try {
      await FirebaseFirestore.instance.collection('studyPostInfo').doc(widget.postInfo['docId']).update({
        'title': titleEditingController.text,
        'content': contentEditingController.text,
        'imagePaths': allImagePaths,
        'category': postCategory,
        'code' : code,
        'language' : language
      });

      Get.back();
      Get.back(result: {
        'title': titleEditingController.text,
        'content': contentEditingController.text,
        'imagePaths': allImagePaths,
        'category': postCategory,
        'code' : code,
        'language' : language
      });
    } catch (e) {
    }
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
            padding: const EdgeInsets.only(top: 30, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView( // Scrollable to avoid overflow
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$language 코드 입력',
                    style: f18bw700,
                    textAlign: TextAlign.center,
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
    final TextEditingController _customLanguageController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 320,
            padding: const EdgeInsets.only(top: 30, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView( // Scrollable to avoid overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('원하시는 언어를 입력해주세요', style: f20bw700,),
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
                          child: Text('확인', style: f16w400,),
                          onPressed: () {
                            final customLanguage = _customLanguageController.text.trim();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '게시글 수정',
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
                      padding: const EdgeInsets.only(left: 16, top: 30, bottom: 12),
                      child: Text(
                        postCategory,
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
                  hintStyle: f18bw700,
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
                  const SizedBox(width: 12),
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
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            SvgPicture.asset(
                              'assets/icon/camera.svg',
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${existingImageUrls.length + images.length}/3', // 기존 이미지와 새 이미지 총합 표시
                              style: f6bw500,
                            ),
                          ],
                        )),
                  ),
                  const SizedBox(width: 8),
                  FutureBuilder<List<String>>(
                    future: imageUrlsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: LoadingScreen());
                      } else if (snapshot.hasError) {
                        return Center(child: Icon(Icons.error));
                      }
                      else {
                        List<String> allImageUrls = [
                          ...existingImageUrls.map((path) {
                            return 'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/post%2F${Uri.encodeComponent(path)}?alt=media';
                          }),
                          ...images.map((image) => image.path)
                        ];
                        return Row(
                          children: List.generate(allImageUrls.length, (index) {
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
                                      child: allImageUrls[index].startsWith('http')
                                          ? CachedNetworkImage(
                                        imageUrl: allImageUrls[index],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      )
                                          : Image.file(
                                        File(allImageUrls[index]),
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
                        );
                      }
                    },
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
            const Divider(
              color: Color(0xffD9D9D9),
              height: 1,
              thickness: 2,
            ),
            Container(
              child:Row(
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
                  const SizedBox(width: 10),
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
                        code == '' ? const SizedBox() : Positioned(
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () async {
          if (!isSubmitting) {
            setState(() {
              isSubmitting = true; // 수정하기 버튼을 누른 상태
            });
            try {
              CollectionReference ref = FirebaseFirestore.instance.collection('studyPostInfo');

              // 이미지 경로를 모두 업로드하고 목록을 받아오기
              List<String> newImagePaths = await _uploadImages(images);
              allImagePaths = [
                ...existingImageUrls,
                ...newImagePaths
              ];
              await _updatePost();
            } catch (e) {
            }
            setState(() {
              isSubmitting = false;
            });
          }
        },
        child: BottomAppBar(
          height: 50,
          color: Color(0xff3648EB),
          child: Center(
            child: Text(
              '수정하기',
              style: f22w500,
            ),
          ),
        ),
      ),


    );
  }
}
