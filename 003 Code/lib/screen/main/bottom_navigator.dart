import 'dart:ffi';

import 'package:circlet/firebase/firebase_user.dart';
import 'package:circlet/provider/user_state.dart';
import 'package:circlet/screen/cafe/cafe_main.dart';
import 'package:circlet/screen/home/myClass.dart';
import 'package:circlet/screen/lounge/lounge/lounge_page.dart';
import 'package:circlet/screen/class_search/study_search_page.dart';
import 'package:circlet/util/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../cafe/study_cafe_main.dart';
import '../profile/profile/user_profile_page.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> with TickerProviderStateMixin {
  final us = Get.put(UserState());
  List<Widget> _widgetOptions = [];
  late TabController _bottomTabController;
  int _currentIndex = 0;


  @override
  void initState() {
    print('유저리스트?${us.userList.value}');
    super.initState();
    _widgetOptions = [MyClass(),StudySearchPage(),LoungePage(),CafeMain(),UserProfilePage()];
    _bottomTabController = TabController(length: 5, vsync: this,initialIndex: 0);
    _currentIndex = 0;
    setState(() {});
    // _bottomTabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: _widgetOptions,
        controller: _bottomTabController,
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 0.2, color: grayColor),
          ),
        ),
        child: TabBar(
          onTap: (index){
            setState(() {
              _currentIndex = index;
            });
          },
          controller: _bottomTabController,
          unselectedLabelStyle: TextStyle(fontSize: 8,fontFamily: 'NotoSans'),
          labelStyle: TextStyle(fontSize: 8,fontFamily: 'NotoSans'),
          unselectedLabelColor: grayColor,
          labelColor: blackColor,
          tabs: <Widget>[
            Tab(
              icon: SvgPicture.asset(
                'assets/icon/bottom_navi/main.svg',
                width: 24, // 아이콘 크기를 조정할 수 있습니다.
                height: 24,
                color: _currentIndex == 0 ? blackColor : grayColor,
              ),
              text: '메인',
            ),
            Tab(
              icon: SvgPicture.asset(
                'assets/icon/bottom_navi/study.svg',
                width: 24, // 아이콘 크기를 조정할 수 있습니다.
                height: 24,
                color: _currentIndex == 1 ? blackColor : grayColor,
              ),
              text: '모임찾기',
            ),
            Tab(
              icon: SvgPicture.asset(
                'assets/icon/bottom_navi/lounge.svg',
                width: 24, // 아이콘 크기를 조정할 수 있습니다.
                height: 24,
                color: _currentIndex == 2 ? blackColor : grayColor,
              ),
              text: '라운지',
            ),
            Tab(
              icon: SvgPicture.asset(
                'assets/icon/bottom_navi/cafe.svg',
                width: 24, // 아이콘 크기를 조정할 수 있습니다.
                height: 24,
                color: _currentIndex == 3 ? blackColor : grayColor,
              ),
              text: '주변카페',
            ),
            Tab(
              icon: SvgPicture.asset(
                'assets/icon/bottom_navi/userProfile.svg',
                width: 24, // 아이콘 크기를 조정할 수 있습니다.
                height: 24,
                color: _currentIndex == 4 ? blackColor : grayColor,
              ),
              text: '프로필',
            )
          ],
        ),
      ),
    );
  }
}
