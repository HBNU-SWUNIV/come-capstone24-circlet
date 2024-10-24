import 'dart:io';
import 'package:circlet/screen/lounge/lounge/lounge_view_page.dart';
import 'package:circlet/util/font/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../provider/user_state.dart';
import '../util/color.dart';



class TextFormBox extends StatelessWidget {
  final String hintText;
  final TextEditingController textController;
  final VoidCallback onTap;
  final ValueChanged onChange;
  final String? multiline;
  final TextInputType? keyboardType;

  const TextFormBox(
      {Key? key,
      required this.hintText,
      required this.textController,
      required this.onTap,
      required this.onChange,
      this.multiline,
      this.keyboardType,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: multiline == 'true' ? 5 : 1,
      maxLines: multiline == 'true' ? null : 1,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(width: 1.5, color: Color(0xffEBEBEB)),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xff3648EB))),
        contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 13),
        hintText: hintText,
        hintStyle: f14w300HintGray,
      ),
      style: TextStyle(
        color: Color(0xff6E6E6E),
      ),
      controller: textController,
      onChanged: onChange,
      keyboardType: keyboardType ?? TextInputType.text,
    );
  }
}


class BigTextFormBox extends StatelessWidget {
  final String hintText;
  final TextEditingController textController;
  final VoidCallback onTap;
  final ValueChanged onChange;
  final String? multiline;

  const BigTextFormBox(
      {Key? key,
        required this.hintText,
        required this.textController,
        required this.onTap,
        required this.onChange,
        this.multiline,
       })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: multiline == 'true' ? 5 : 1,
      maxLines: multiline == 'true' ? null : 1,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(width: 1.5, color: Color(0xffEBEBEB)),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xff3648EB))),
        contentPadding:
        EdgeInsets.only(top: 15, bottom: 15, left: 13, right: 13),
        hintText: hintText,
        hintStyle: f14w300HintGray,
      ),
      style: TextStyle(
        color: Color(0xff6E6E6E),
      ),
      controller: textController,
      onChanged: onChange,
      keyboardType:  multiline == 'true' ? TextInputType.multiline:TextInputType.text,
    );
  }
}


class suffixTextFormBox extends StatelessWidget {
  final String hintText;
  final TextEditingController textController;
  final VoidCallback onTap;
  final ValueChanged onChange;
  final String? suffixText;
  final bool isText;
  final bool isIcon;
  final bool visible;
  final bool isContainer;
  final String? containerText;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final VoidCallback? onpressed;
  final TextInputType? keyboardType;
  final bool enabled;

  const suffixTextFormBox(
      {Key? key,
      required this.hintText,
      required this.textController,
      required this.onTap,
      required this.onChange,
      this.enabled = true,
      this.isText = false,
      this.isIcon = false,
      this.isContainer = false,
      this.textStyle,
      this.backgroundColor,
      this.visible = true,
      this.onpressed,
      this.containerText,
      this.keyboardType,
      this.suffixText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: !visible!,
      keyboardType: keyboardType ?? TextInputType.text,
      enabled: enabled,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(width: 1.5, color: Color(0xffEBEBEB)),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xff3648EB))),
        contentPadding:EdgeInsets.symmetric(horizontal: 15,vertical: 13),
        hintText: hintText,
        hintStyle: f12w300HintGray,
        suffixIcon: suffixText != null
            ? Text(suffixText!, style: f14rw500)
            : isIcon
                ? visible
                    ? IconButton(
                        icon: Icon(
                          Icons.visibility,
                          color: Colors.black,
                        ),
                        onPressed: onpressed)
                    : IconButton(
                        icon: Icon(
                          Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: onpressed)
                : isContainer
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, top: 9, bottom: 9),
                        child: GestureDetector(
                          onTap: onTap,
                          child: Container(
                            width: 70,
                            decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                                child: Text(
                              containerText!,
                              style: textStyle,
                            )),
                          ),
                        ),
                      )
                    : null,
      ),
      style: f14bw300,
      controller: textController,
      onChanged: onChange,
    );
  }
}


class suffixTextFormBox2 extends StatelessWidget {
  final String hintText;
  final TextEditingController textController;
  final VoidCallback onTap;
  final ValueChanged onChange;
  final String? suffixText;
  final String? containerText;
  final VoidCallback? onpressed;
  final TextInputType? keyboardType;
  final bool enabled;

  const suffixTextFormBox2(
      {Key? key,
        required this.hintText,
        required this.textController,
        required this.onTap,
        required this.onChange,
        this.enabled = true,
        this.onpressed,
        this.containerText,
        this.keyboardType,
        this.suffixText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          keyboardType: keyboardType ?? TextInputType.text,
          enabled: enabled,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(width: 1.5, color: Color(0xffEBEBEB)),
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Color(0xff3648EB))),
            contentPadding:
            EdgeInsets.only(top: 15, bottom: 15, left: 13, right: 13),
            hintText: hintText,
            hintStyle: f14w300HintGray,),
          style: f14bw300,
          controller: textController,
          onChanged: onChange,
        ),
        Positioned(
          right: 10,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(

                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Center(
                      child: Text(
                        containerText!,
                        style: f14w400,
                      )),
                ),
              ),
            ))
      ],
    );
  }
}

class IconText extends StatelessWidget {
  final String image;
  final String text;
  final bool isLarge;
  final VoidCallback ontap;
  final bool check;

  const IconText(
      {Key? key,
      required this.image,
      required this.text,
      required this.ontap,
      required this.isLarge,
      this.check = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Column(
        children: [
          Container(
            width: isLarge ? 75 : 54,
            height: isLarge ? 75 : 54,
            decoration: BoxDecoration(
                color: Color(0xffF2F2F2),
                borderRadius: BorderRadius.circular(8),
                border: check ? Border.all(color: mainColor, width: 3) : null),
            child: Center(
              child: SizedBox(
                width: isLarge ? 40 : 24,
                height: isLarge ? 40 : 24,
                child: SvgPicture.asset(
                  '${image}',
                ),
              ),
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            '${text}',
            style: TextStyle(
              fontSize: isLarge ? 13 : 9,
              fontFamily: 'NotoSans',
            ),
          )
        ],
      ),
    );
  }
}

class ImageButton extends StatelessWidget {
  final String image;
  final VoidCallback ontap;
  final double? iconSize;

  const ImageButton({
    Key? key,
    required this.image,
    required this.ontap,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Column(
        children: [
          iconSize == null
              ? SvgPicture.asset('${image}')
              : SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: SvgPicture.asset('${image}'),
                ),
        ],
      ),
    );
  }
}

Decoration techStackDecoration(String itemName) {
  switch (itemName) {
    case "IOS":
      return BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      );
    case "안드로이드":
      return BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      );
    default:
      return BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      );
  }
}

class ButtonStyle1 extends StatelessWidget {
  final String text;
  final VoidCallback ontap;
  final bool checked;

  const ButtonStyle1({
    Key? key,
    required this.text,
    required this.ontap,
    this.checked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: mainColor,
          //borderRadius: BorderRadius.circular(5)
        ),
        child: Center(
          // 텍스트를 가운데에 위치시키기 위해 Center 위젯 추가
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class ButtonStyle2 extends StatelessWidget {
  final String text;
  final VoidCallback ontap;
  final String value;

  const ButtonStyle2({
    Key? key,
    required this.text,
    required this.ontap,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: 35,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: value == text ? mainColor : grayColor2,
              width: 1,
            )),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Center(
            // 텍스트를 가운데에 위치시키기 위해 Center 위젯 추가
            child: Text(
              text,
              style: value == text ? f14mw400 : f14g2w400,
            ),
          ),
        ),
      ),
    );
  }
}

class DropDownService extends StatelessWidget {
  final double width;
  final List<String> item;
  final ValueChanged onChange;
  final String? selectedValue;

  const DropDownService({
    Key? key,
    required this.width,
    required this.item,
    required this.onChange,
    required this.selectedValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: grayColor)),
      child: Padding(
        padding: EdgeInsets.only(top: 2, right: 5, bottom: 2),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            iconStyleData: IconStyleData(
                icon: SvgPicture.asset('assets/icon/dropdown.svg'),
                iconSize: 15),
            value: selectedValue,
            items: item.map((String item) {
              return DropdownMenuItem<String>(
                child: Text(
                  item,
                  style: f14bw400,
                ),
                value: item,
              );
            }).toList(),
            onChanged: onChange,
          ),
        ),
      ),
    );
  }
}

/// 앱바 컴포넌트
class StyledAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;

  StyledAppBar({required this.text});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // leading: BackButton(color: blackColor,),
      title: Text(
        text,
        style: f20bw500,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1), // Divider의 높이 설정
        child: Divider(
          color: Color(0xffEBEBEB), // Divider의 색상 설정
          height: 1, // Divider의 높이 설정
          thickness: 1, // Divider의 두께 설정
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
/// 뒤로 가는 앱바 컴포넌트
class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final VoidCallback onTap;

  BackAppBar({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        onTap: onTap,
          child: Icon(Icons.arrow_back_ios_new)),
      title: Text(
        text,
        style: f20bw500,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1), // Divider의 높이 설정
        child: Divider(
          color: Color(0xffEBEBEB), // Divider의 색상 설정
          height: 1, // Divider의 높이 설정
          thickness: 1, // Divider의 두께 설정
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}



class StudyInfo {
  String studyName;
  String studyCategory;
  String studyLocation;
  String studyIntro;
  List<String> tags;
  int members;
  int views;

  StudyInfo(this.studyName, this.studyCategory, this.studyLocation,
      this.studyIntro, this.tags, this.members, this.views);
}

class StudyInfoDB {
  String id;
  String studyName;
  String studyHost;
  List<String> studyInterest;
  String sido;
  String gungu;
  String studyIntro;
  List<String> techStack;
  List<String> studyUserList;
  List<String> signUpList;


  StudyInfoDB({required this.id, required this.studyName, required this.studyHost,
    required this.sido, required this.gungu, required this.studyIntro, required this.studyInterest, required this.techStack, required this.studyUserList,
    required this.signUpList});
}

class Message {
  final String text;
  final String userId;
  final bool isUserMessage;

  Message(this.text, this.isUserMessage, this.userId);
}

class PostInfo {
  String id;
  String title;
  String content;
  String createDate;
  String date;
  String category;
  String author;
  int likeCount;
  int commentCount;
  int viewCount;
  bool like;
  List<String> likeList;
  List<String> imagePaths;

  PostInfo({
    required this.id,
    required this.title,
    required this.content,
    this.createDate = '',
    required this.date,
    required this.category,
    this.author = '',
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.like = false,
    required this.likeList,
    required this.imagePaths,
  });

  factory PostInfo.fromMap(Map<String, dynamic> map) {
    return PostInfo(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createDate: map['createDate'] ?? '',
      date: map['date'] ?? '',
      category: map['category'] ?? '',
      author: map['author'] ?? '',
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      viewCount: map['viewCount'] ?? 0,
      like: map['like'] ?? false,
      likeList: List<String>.from(map['likeList'] ?? []),
      imagePaths: List<String>.from(map['imhs'] ?? []),
    );
  }
}

Future<PostInfo?> getPostInfo(String postId) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    if (doc.exists) {
      return PostInfo.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      print('Document does not exist');
      return null;
    }
  } catch (e) {
    print('Error getting document: $e');
    return null;
  }
}



// class PostItem extends StatefulWidget {
//   final PostInfo postInfo;
//   final VoidCallback onHeartTap;
//   final VoidCallback onRemoveTap;
//   final Function(PostInfo) onPostUpdated; // 추가된 콜백
//   final bool studypost;
//   final UserState us;
//   final StudyInfoDB? studyInfo;
//   final String userImage;
//   const PostItem({
//     Key? key,
//     required this.postInfo,
//     required this.onHeartTap,
//     required this.onRemoveTap,
//     required this.onPostUpdated, // 추가된 콜백
//     required this.studypost,
//     required this.us,
//     required this.userImage,
//     this.studyInfo,
//   }) : super(key: key);
//
//   @override
//   _PostItemState createState() => _PostItemState();
// }

// class _PostItemState extends State<PostItem> {
//
//   @override
//   Widget build(BuildContext context) {
//     bool isLiked = widget.postInfo.likeList.contains(widget.us.userList[0]['docId']);
//     return GestureDetector(
//       onTap: () async {
//         final result = await Get.to(() => PostViewPage(postInfo: widget.postInfo, studypost: widget.studypost, studyInfo: widget.studyInfo));
//         if (result != null) {
//           if (result is bool && result == true) {
//             widget.onRemoveTap(); // 게시글이 삭제된 경우 새로고침 콜백 호출
//           } else {
//             widget.onPostUpdated(result); // 게시글이 업데이트된 경우 업데이트 콜백 호출
//           }
//           widget.onRemoveTap();
//         }
//       },
//       child: Container(
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left: 15, top: 26, bottom: 10),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     child: Row(
//                       children: [
//                         ClipOval(
//                           child: Container(
//                               height: 40,
//                               width: 40,
//                               child: widget.userImage != '' ?
//                               Image.network(
//                                 widget.userImage,
//                                 fit: BoxFit.cover,
//                                 width: 40,
//                                 height: 40,
//                               ) : Image.asset('assets/image/default_profile.png')
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           widget.postInfo.author,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontFamily: 'NotoSans',
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       //Get.to(OtherUserProfilePage(postInfo: widget.postInfo));
//                     },
//                   ),
//                   Spacer(),
//                   Text(
//                     widget.postInfo.date,
//                     style: TextStyle(
//                         fontSize: 8,
//                         color: Color(0xffABABAB),
//                         fontFamily: 'NotoSans',
//                         fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(width: 25), // 너무 가까워보임
//                 ],
//               ),
//             ),
//             Row(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 14), // 좌우 동일한 패딩 설정
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         child: Text(
//                           widget.postInfo.title,
//                           maxLines: null,
//                           overflow: TextOverflow.visible,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                             fontFamily: 'NotoSans',
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(left: 2),
//                         child: Text(
//                           widget.postInfo.content,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             fontFamily: 'NotoSans',
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       if (widget.postInfo.imagePaths.isNotEmpty)
//                         Stack(
//                           children: [
//                             Container(
//                               width: Get.width - 28, // 패딩에 맞춰 너비 설정
//                               height: 220,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(6),
//                                 child: Image.network(
//                                   widget.postInfo.imagePaths[0],
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             if (widget.postInfo.imagePaths.length > 1)
//                               Positioned(
//                                 top: 7,
//                                 right: 7,
//                                 child: Container(
//                                   width: 29,
//                                   height: 26,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(30),
//                                     color: Color(0xff7E889C),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       '${widget.postInfo.imagePaths.length}',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.white,
//                                         fontFamily: 'NotoSans',
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 23,
//             ),
//             _ThinBottomLine(),
//             Padding(
//               padding: EdgeInsets.only(left: 21, top: 11, bottom: 16),
//               // 위 아래 12하면 가운데
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: widget.onHeartTap,
//                     child: SvgPicture.asset(
//                         isLiked ? 'assets/icon/Heart.svg' : 'assets/icon/emptyHeart.svg'),
//                   ),
//                   const SizedBox(width: 5),
//                   Text('${widget.postInfo.likeCount}',
//                       style: TextStyle(
//                           fontFamily: 'Bold',
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700)),
//                   const SizedBox(width: 6),
//                   SvgPicture.asset('assets/icon/chat.svg'),
//                   const SizedBox(width: 5),
//                   Text('${widget.postInfo.commentCount}',
//                       style: TextStyle(
//                           fontFamily: 'NotoSans',
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700)),
//                   Spacer(),
//                   Text(widget.postInfo.category,
//                       style: TextStyle(
//                           fontSize: 10,
//                           fontFamily: 'NotoSans',
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xffABABAB))),
//                   const SizedBox(width: 29),
//                 ],
//               ),
//             ),
//             _ThickBottomLine()
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _ThinBottomLine() {
//     return Container(
//       color: Color(0xffEBEBEB),
//       height: 1,
//       width: double.infinity,
//     );
//   }
//
//   Widget _ThickBottomLine() {
//     return Container(
//       color: Color(0xffEBEBEB),
//       height: 10,
//       width: double.infinity,
//     );
//   }
// }



// class noticeItem extends StatelessWidget {
//   PostInfo postInfo;
//   bool studypost; // post가 스터디인지 라운지인지 true스터디 false 라운지
//
//   noticeItem({required this.postInfo, required this.studypost});
//
//   String _text(String title) {
//     if (title.length > 10) {
//       return title.substring(0, 10) + '...';
//     } else {
//       return title;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return GestureDetector(
//       onTap: () {
//         Get.to(PostViewPage(postInfo: postInfo, studypost: studypost));
//       },
//       child: Padding(
//           padding: EdgeInsets.only(left: 18, right: 31, top: 10, bottom: 10),
//           child: Row(
//             children: [
//               Container(
//                 width: 33,
//                 height: 19,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: Color(0xff3648EB)),
//                 child: Center(
//                   child: Text(
//                     '공지',
//                     style: f10w700,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.only(left: 12),
//                 child: Text(_text(postInfo.title), style: f12bw700),
//               ),
//               Spacer(),
//               Text(postInfo.date as String, style: f8gw500),
//             ],
//           )),
//     );
//   }
//
// }

class tabCategory extends StatelessWidget {
  final String tabImage;
  final String tabName;

  const tabCategory({Key? key, required this.tabImage, required this.tabName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              child: SvgPicture.asset(tabImage),
            ),
            const SizedBox(width: 5),
            Text(tabName, style: f9bw700)
          ],
        ));
  }
}

class DecoratedTabBar extends StatelessWidget implements PreferredSizeWidget {
  //탭바 색깔 조정
  final TabBar tabBar;
  final BoxDecoration decoration;

  DecoratedTabBar({required this.tabBar, required this.decoration});

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(decoration: decoration)),
        tabBar,
      ],
    );
  }
}

