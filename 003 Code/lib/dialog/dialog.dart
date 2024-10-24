import 'package:circlet/util/color.dart';
import 'package:circlet/util/font/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

/// 메세지만 있는 확인용 다이얼로그
showConfirmTapDialog(BuildContext context, String message, VoidCallback onTap) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.only(top: 40, bottom: 25),
          content: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              width: 350,
              child: Text(
                '${message}',
                style: f15bw400,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 70,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: mainColor,
                  ),
                  child: Center(
                    child: Text(
                      '확인',
                      style: f16w500,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      });
}

/// 확인용 다이얼로그
showOnlyConfirmDialog(BuildContext context, String title, String message) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.only(top: 40, bottom: 25),
          title: Text(
            '${title}',
            style: f20bw700,
          ),
          content: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              width: 350,
              child: Text(
                '${message}',
                style: f15bw400,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  width: 70,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: mainColor,
                  ),
                  child: Center(
                    child: Text(
                      '확인',
                      style: f16w500,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      });
}

/// 확인과 onTap 다이얼로그
showOnlyConfirmTapDialog(
    BuildContext context, String title, String message, VoidCallback onTap) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.only(top: 40, bottom: 25),
          title: Text(
            '${title}',
            style: f20bw700,
          ),
          content: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              width: 350,
              child: Text(
                '${message}',
                style: f15bw400,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 70,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: mainColor,
                  ),
                  child: Center(
                    child: Text(
                      '확인',
                      style: f16w500,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      });
}

/// 확인 취소 누르는 거
showComponentDialog(
    BuildContext context, String message, VoidCallback confirmTap) {
  // show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.only(top: 40, bottom: 25),
            // title: Text('${title}',style: f20bw700,),
            content: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: 350,
                child: Text(
                  '${message}',
                  style: f15bw400,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      width: 70,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: mainColor,
                      ),
                      child: Center(
                        child: Text(
                          '취소',
                          style: f16w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: confirmTap,
                    child: Container(
                      width: 70,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: mainColor,
                      ),
                      child: Center(
                        child: Text(
                          '확인',
                          style: f16w500,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ]);
      });
}
/// 확인 및 취소 다이얼로그(게시글 수정/삭제, 스터디 가입 등등)
showConfirmationDialog(
    BuildContext context,
    String content,
    TextStyle textStyle,
    VoidCallback onConfirmTap,
    ) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: 320,
          height: 208,
          padding:
          const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 24),
          child: Column(
            children: [
              Text(
                content,
                style: textStyle,
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){ Get.back();},
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Color(0xffEEEEEE)
                        ),
                        child: Center(child: Text('취소', style: f16dcw400)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){ Get.back();},
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Color(0xff212121)
                        ),
                        child: Center(child: Text('등록', style: f16w400)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 확인 버튼만 있는 다이얼로그
OkDialog(
    BuildContext context,
    String content,
    TextStyle textStyle,
    ) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: 320,
          height: 192,
          padding:
          const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 24),
          child: Column(
            children: [
              Text(
                content,
                style: textStyle,
              ),
              const SizedBox(height: 36),
              Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                child: Expanded(
                  child: GestureDetector(
                    onTap: (){ Get.back();},
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Color(0xff212121)
                      ),
                      child: Center(child: Text('확인', style: f16w400)),
                    ),
                  ),
                ),),
            ],
          ),
        ),
      );
    },
  );
}

/// 신고 다이얼로그
showReportDialog(
    BuildContext context,
    TextEditingController reportReasonController, // 컨트롤러 추가
    VoidCallback onConfirmTap,
    ) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(  // 스크롤 가능하게 만들기
          child: Container(
            width: 320,
            padding: const EdgeInsets.only(
                top: 24, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '신고하기 ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  '신고 사유를 입력해주세요',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: reportReasonController, // 컨트롤러 연결
                  maxLength: 30,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xffEFEFEF),
                    contentPadding: const EdgeInsets.all(10),
                    hintText: '최대 30자 입력 가능',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onConfirmTap, // 확인 버튼 클릭 시 동작
                        child: Container(
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xff212121),
                          ),
                          child: const Center(
                            child: Text('확인', style: TextStyle(color: Colors.white)),
                          ),
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


