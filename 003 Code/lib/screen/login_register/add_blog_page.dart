
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../components/components.dart';
import '../../provider/user_state.dart';
import '../../util/font/font.dart';
import 'add_portfolio_page.dart';

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final us = Get.put(UserState());
  TextEditingController blogController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyledAppBar(
        text: '블로그 등록',
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 28, left: 12, right: 12, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('(선택)', style: f20w500HintGray,),
                Text('사용하는 기술블로그가 있나요?', style: f21bw700,)
              ],
            ),
            const SizedBox(
              height: 18,
            ),
            Center(
              child: Text('기술블로그 링크는 사용자 프로필에 명시되며 다른 유저도 볼 수 ',
                style: f12bw500,),
            ),
            Center(
              child: Text('있습니다. 설정에서 변경 가능합니다.',
                style: f12bw500,),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              width: Get.width,
              height: 45,
              child: TextFormBox(
                hintText: '링크(선택)',
                textController: blogController,
                onTap: () {},
                onChange: (v) {
                  setState(() {

                  });
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text('* 유효하지 않은 링크는 제재를 받을 수 있습니다.',style: f12w300HintGray,),
            Spacer(),
            Spacer(),
            GestureDetector(
              onTap: () {
                us.blogUrl.value = blogController.text;
                print('blogUrl url??');
                print(us.blogUrl.value);
                Get.to(AddPortFolioPage());
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
}
