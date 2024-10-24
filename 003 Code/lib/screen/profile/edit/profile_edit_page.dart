import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/screen/profile/edit/edit_interest_page.dart';
import 'package:circlet/util/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../components/components.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';
import '../../../util/font/font.dart';

class ProfileEditPage extends StatefulWidget {
  ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  bool _isLoading = true;
  TextEditingController messageController = TextEditingController();
  TextEditingController techStackController = TextEditingController();
  TextEditingController gitController = TextEditingController();
  TextEditingController blogController = TextEditingController();


  XFile? image;
  final ImagePicker picker = ImagePicker();
  final us = Get.put(UserState());
  FocusNode searchFocusNode = FocusNode();
  List techList = ['Flutter', 'Java', 'JavaScript', 'Kotlin', 'React', 'Rust', 'Swift', 'Node.js','Spring', 'React Native', 'Python', 'MATLAB'];
  List filteredlist = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getUserDetailList(us.userList[0]['docId']);
      print('가져온 userDetailList? ${us.userDetailList.value}');
      messageController.text = us.userDetailList[0]['introduce'];
      gitController.text = us.userDetailList[0]['gitUrl'];
      blogController.text = us.userDetailList[0]['blogUrl'];
      _isLoading = false;
      setState(() {});
    });
  }

  ///userDetail update 함수
  Future<void> updateUserDetail() async {
    CollectionReference ref = FirebaseFirestore.instance.collection('userDetail');
    try {
      QuerySnapshot snapshot2 = await ref.where('userId', isEqualTo: '${us.userDetailList[0]['userId']}').get();
      String documentId = snapshot2.docs.first.id;

      await ref.doc(documentId).update({
          'interest': us.userDetailList[0]['interest'],
          'techStack': us.userDetailList[0]['techStack'],
          'introduce': messageController.text,
          'gitUrl' : gitController.text,
          'blogUrl' : blogController.text,
      });
      print('userDetail 업데이트 완료');
    } catch (e) {
      print(e);
    }
  }
  /// 이미지를 갤러리에서 가져오는 함수
  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      image = XFile(pickedFile.path);
      setState(() {});
    }
  }

  /// 이미지 캐시 삭제 함수
  Future _deleteImageFromCache() async {
    String imageUrl = 'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${us.userList[0]['docId']}?alt=media';
    await CachedNetworkImage.evictFromCache(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: BackAppBar(text: '프로필 수정',onTap: (){Get.back();},),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(),)
            : Padding(
          padding: EdgeInsets.only(top: 12, left: 12, right: 12),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // 원형으로 설정
                          color: grayColor2,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        width: 115,
                        height: 115,
                        /// Cached 네트워크 이미지
                        child: ClipOval( // 이미지를 원형으로 자르기 위해 ClipOval 사용
                          child: image != null ?Image.file(
                            fit: BoxFit.cover,
                            File(image!.path),
                          ):CachedNetworkImage(
                            imageUrl: 'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/userImage%2F${us.userList[0]['docId']}?alt=media',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                      /// 프로필 이미지 옆 수정 버튼
                      Positioned(
                        top: 80,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            getImage(ImageSource.gallery);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: lightGrayColor,
                                width: 1,
                              ),
                            ),
                            child: Icon(Icons.edit, color: Colors.black, size: 22,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5,),
                /// 닉네임
                Center(
                  child: Text(
                    us.userList[0]['nickname'],
                    style: f16gray800w700,
                  ),
                ),
                const SizedBox(height: 16,),
                /// 프로필 메세지
                Text('프로필 메세지', style: f12gray800w500),
                const SizedBox(height: 10,),
                TextFormBox(
                  hintText: '나를 설명하고 싶은 메세지를 작성해주세요.',
                  textController: messageController,
                  onTap: () {},
                  onChange: (v) {},
                ),
                const SizedBox(height: 16,),
                /// 관심분야
                Row(
                  children: [
                    Text('관심분야', style: f12gray800w500,),
                    SizedBox(width: 12,),
                    GestureDetector(
                        onTap: () {
                          Get.to(() => EditInterestPage(itemList: us.userDetailList[0]['interest']));
                          setState(() {});
                        },
                        child: Icon(Icons.add_circle_outlined, color: blackColor, size: 16,)
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Obx(() => Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.start,
                  spacing: 5,
                  runSpacing: 5,
                  children: us.userDetailList[0]['interest'].map<Widget>((item) {
                    return Container(
                      height: 28,
                      padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: interestBackgroundColor[item],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: interestTextColor[item],
                        ),
                      ),
                    );
                  }).toList(
                  ),
                ),),
                const SizedBox(height: 16,),
                /// 기술스택
                Text('기술스택', style: f12gray800w500,),
                const SizedBox(height: 10,),
                SearchBar(
                  controller: techStackController,
                  hintText: 'ex) Java',
                  hintStyle: MaterialStateProperty.all(f12w300HintGray),
                  trailing: [
                    SvgPicture.asset('assets/icon/search.svg', width: 16,),
                  ],
                  backgroundColor: MaterialStatePropertyAll(whiteColor),
                  surfaceTintColor: MaterialStatePropertyAll(Colors.transparent),
                  shape: MaterialStateProperty.all(
                    ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  side: MaterialStateProperty.all(
                      BorderSide(width: 1.5, color: Color(0xffEBEBEB))),
                  padding: MaterialStateProperty.all(EdgeInsets.only(left: 5, right: 10,top: 5, bottom: 10)),
                  constraints: BoxConstraints(maxHeight: 60),
                  shadowColor: MaterialStatePropertyAll(Colors.transparent),
                  onChanged: (v) {
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
                  height: 10,
                ),
                /// 기술스텍 검색어가 있다면 검색된 리스트 show, 없다면 null
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
                                  us.userDetailList[0]['techStack'].add(filteredlist[index]);
                                  techStackController.clear();
                                  filteredlist.clear();
                                  print('변경된 테크스텍${us.userDetailList[0]['techStack']}');
                                  setState(() {});
                                },
                                child: Text(
                                  filteredlist[index],
                                  style: f12gray800w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ))
                    :Container(),
                /// 선택된 기술스택 목록, 기술스텍 데이터가 있어야하며 검색중이 아닐시 show
                us.userDetailList[0]['techStack'].isNotEmpty&&techStackController.text.isEmpty?
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.start,
                      spacing: 5,
                      // 좌우 간격
                      runSpacing: 5,
                      // 상하 간격
                      children: us.userDetailList[0]['techStack'].asMap().entries.map<Widget>((entry) {
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
                                style: f12w400,
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 6,
                              child: GestureDetector(
                                onTap: () {
                                  us.userDetailList[0]['techStack'].removeAt(index);
                                  print('스텍이 삭제된 리스트?${us.userDetailList[0]['techStack']}');
                                  setState(() {

                                  });
                                },
                                child: Container(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16,),
                    /// 깃허브
                    Text('깃허브 링크', style: f12gray800w500),
                    const SizedBox(height: 10,),
                    TextFormBox(
                      hintText: '(선택)',
                      textController: gitController,
                      onTap: () {},
                      onChange: (v) {},
                    ),
                    const SizedBox(height: 16,),
                    /// 블로그
                    Text('블로그 링크', style: f12gray800w500),
                    const SizedBox(height: 10,),
                    TextFormBox(
                      hintText: '(선택)',
                      textController: blogController,
                      onTap: () {},
                      onChange: (v) {},
                    ),
                    const SizedBox(height: 16,),
                    GestureDetector(
                      onTap: () async {
                        print('image???${image}');
                        image != null? storageAddImage(image, '${us.userList[0]['docId']}', 'userImage'):null;
                        await updateUserDetail();
                        _deleteImageFromCache();
                        Get.back();
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                            color: mainColor
                          ,borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            '변경하기',
                            style: f18w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,)


                  ],
                )
                    :Container(),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

