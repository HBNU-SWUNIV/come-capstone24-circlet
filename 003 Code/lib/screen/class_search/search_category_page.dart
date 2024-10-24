import 'package:cached_network_image/cached_network_image.dart';
import 'package:circlet/provider/study_state.dart';
import 'package:circlet/screen/class_search/study_search_result_page.dart';
import 'package:circlet/screen/study/study_home/study_home_page.dart';
import 'package:circlet/util/font/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../components/components.dart';
import '../../firebase/api.dart';
import '../../firebase/firebase_study.dart';
import '../../provider/user_state.dart';
import '../../util/color.dart';
import '../../util/loadingScreen.dart';

class SearchCategoryPage extends StatefulWidget {
  final String categoryName;
  final int initialIndex;

  SearchCategoryPage({required this.categoryName, required this.initialIndex});

  @override
  State<SearchCategoryPage> createState() => _SearchCategoryPageState();
}

class _SearchCategoryPageState extends State<SearchCategoryPage>
    with SingleTickerProviderStateMixin {
  FirebaseStorage storage =
  FirebaseStorage.instanceFor(bucket: 'gs://circlet-9c202.appspot.com');
  StudyState ss = Get.put(StudyState());
  final us = Get.put(UserState());
  late TabController _tabCategoryController;
  List<dynamic> studyInfoList = [];
  List<dynamic> paginatedList = [];
  List<String> districts = [];
  bool isLoading = true;
  bool hasMore = true;
  bool isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();
  bool isLikeButtonDisabled = false;
  final List<String> categories = [
    '전체보기',
    'IOS',
    '안드로이드',
    '웹',
    '게임',
    '네트워크/보안',
    '백엔드/서버',
    '프론트엔드',
    '임베디드',
    '인공지능',
  ];

  final Map<String, String> iconNames = {
    '전체보기': 'grid',
    'IOS': 'apple',
    '안드로이드': 'android',
    '웹': 'web',
    '게임': 'game',
    '네트워크/보안': 'security',
    '백엔드/서버': 'server',
    '프론트엔드': 'frontEnd',
    '임베디드': 'embedded',
    '인공지능': 'ai',
  };

  String sortBy = '최신순';
  String selectedCity = '시/도';
  String selectedDistrict = '군/구';
  int currentPage = 0;
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _tabCategoryController = TabController(
        length: categories.length,
        vsync: this,
        initialIndex: widget.initialIndex);
    _tabCategoryController.addListener(_handleTabSelection);
    _scrollController.addListener(_scrollListener);
    _fetchCategoryStudies(categories[widget.initialIndex], true);
  }

  @override
  void dispose() {
    _tabCategoryController.removeListener(_handleTabSelection);
    _tabCategoryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showDistrictsModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        child: ListView.builder(
          itemCount: districts.length,
          itemBuilder: (context, index) {
            String district = districts[index];
            return ListTile(
              title: Text(district),
              onTap: () {
                setState(() {
                  selectedDistrict = district;
                });
                Navigator.pop(context);
                _fetchCategoryStudies(
                    categories[_tabCategoryController.index],
                    true
                );
              },
            );
          },
        ),
      ),
    );
  }


  Future<void> toggleLike(String docId, bool like) async {
    if (isLikeButtonDisabled) return;
    isLikeButtonDisabled = true;
    try {
      DocumentReference docRef =
      FirebaseFirestore.instance.collection('study').doc(docId);
      DocumentSnapshot docSnapshot = await docRef.get();

      if (like) {
        await docRef.update({
          'likeList': FieldValue.arrayRemove([us.userList[0]['docId']]),
        });
      } else {
        await docRef.update({
          'likeList': FieldValue.arrayUnion([us.userList[0]['docId']]),
        });
      }
      setState(() {
        isLikeButtonDisabled = false;
      });
    } catch (error) {
      print('Failed to toggle like: $error');
    }
  }

  void _handleTabSelection() {
    if (_tabCategoryController.indexIsChanging) {
      _fetchCategoryStudies(categories[_tabCategoryController.index], true);
    }
  }

  Future<void> _fetchCategoryStudies(
      String category, bool isInitialLoad) async {
    if (isFetchingMore) return;

    setState(() {
      if (isInitialLoad) {
        isLoading = true;
        currentPage = 0;
        hasMore = true;
        paginatedList = [];
      }
      isFetchingMore = true;
    });

    try {
      await getStudyInfo(); // 모든 스터디 정보 가져오기

      List<dynamic> filteredStudies;

      if (category == '전체보기') {
        filteredStudies = ss.allStudyList.value;
      } else {
        filteredStudies = ss.allStudyList.value
            .where((study) =>
        study['interest'] != null &&
            study['interest'].contains(category))
            .toList();
      }

      // 시와 군구 필터링 적용
      filteredStudies = filteredStudies
          .where((study) =>
      (selectedCity == '시/도' || study['sido'] == selectedCity) &&
          (selectedDistrict == '군/구' || study['gungu'] == selectedDistrict))
          .toList();

      if (filteredStudies.isNotEmpty) {
        setState(() {
          studyInfoList = filteredStudies;
        });
        _sortAndPaginateStudies();
      } else {
        setState(() {
          hasMore = false;
        });
      }
    } catch (e) {
      print('Error fetching studies: $e');
    } finally {
      setState(() {
        isLoading = false;
        isFetchingMore = false;
      });
    }
  }

  void _sortAndPaginateStudies() {
    List<dynamic> sortedStudies = List.from(studyInfoList);

    if (sortBy == '최신순') {
      sortedStudies
          .sort((a, b) => (b['createDate']).compareTo(a['createDate']));
    } else if (sortBy == '좋아요순') {
      sortedStudies.sort((a, b) => (b['likeList'] as List)
          .length
          .compareTo((a['likeList'] as List).length));
    }

    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    List<dynamic> newItems = sortedStudies.sublist(startIndex,
        endIndex > sortedStudies.length ? sortedStudies.length : endIndex);

    setState(() {
      int addedItemsCount = newItems.length;
      print('$addedItemsCount 개가 추가됨');

      paginatedList.addAll(newItems);
      currentPage++;
      hasMore = endIndex < sortedStudies.length;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasMore && !isLoading) {
        _sortAndPaginateStudies();
      }
    }
  }
  Future<void> _updateDistricts(String city) async {
    if (city.isEmpty || city == '시/도') {
      setState(() {
        districts = [];
        selectedDistrict = '군/구';
      });
      return;
    }

    try {
      List<String> fetchedDistricts = await getDropList(city);
      setState(() {
        print('Fetched districts for $city: $fetchedDistricts');
        districts = fetchedDistricts;
        selectedDistrict = '군/구'; // 선택된 군/구 리셋
      });
    } catch (error) {
      print('Error fetching districts: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Center(child: Text('카테고리', style: f20bw700)),
            ),
            Padding(
              padding: EdgeInsets.only(right: 18),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => StudySearchResultPage());
                },
                child: SvgPicture.asset('assets/icon/search.svg'),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: Color(0xffD0D0D0),
                height: 1,
              ),
              DecoratedTabBar(
                tabBar: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                  ),
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  controller: _tabCategoryController,
                  tabs: categories.map((category) {
                    final iconName = iconNames[category] ?? 'default_icon';
                    return tabCategory(
                        tabImage: 'assets/icon/$iconName.svg',
                        tabName: category);
                  }).toList(),
                ),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.red))),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 13),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          height: 300, // 하단 시트 높이 조정
                          child: ListView(
                            children: [
                              ListTile(
                                title: Text('시/도'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '시/도';
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('서울시'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '서울시';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('부산시'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '부산시';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('인천시'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '인천시';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('대구'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '대구';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('대전'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '대전';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('광주'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '광주';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('울산'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '울산';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('경기도'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '경기도';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('충북'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '충북';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('충남'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '충남';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('전북'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '전북';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('전남'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '전남';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('경북'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '경북';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('경남'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '경남';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('강원도'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '강원도';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                              ListTile(
                                title: Text('제주시'),
                                onTap: () {
                                  setState(() {
                                    selectedCity = '제주시';
                                    _updateDistricts(selectedCity);
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(categories[_tabCategoryController.index], true);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: _buildFilterOption(selectedCity.isEmpty ? '시/도 선택' : selectedCity),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: _showDistrictsModal,
                    child: _buildFilterOption(
                        selectedDistrict.isEmpty ? '구/군 선택' : selectedDistrict
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          height: 150,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text('최신순'),
                                onTap: () {
                                  setState(() {
                                    sortBy = '최신순';
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(
                                      categories[_tabCategoryController.index],
                                      true);
                                },
                              ),
                              ListTile(
                                title: Text('좋아요순'),
                                onTap: () {
                                  setState(() {
                                    sortBy = '좋아요순';
                                  });
                                  Navigator.pop(context);
                                  _fetchCategoryStudies(
                                      categories[_tabCategoryController.index],
                                      true);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: _buildFilterOption(sortBy),
                  ),
                ],
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: paginatedList.length,
              itemBuilder: (context, index) {
                var isOtherLiked = (paginatedList[index]['likeList'] as List?)
                    ?.contains(us.userList[0]['docId']) ??
                    false;
                return Padding(
                  padding: EdgeInsets.only(top: 17, right: 10, left: 10),
                  child: GestureDetector(
                    onTap: () {
                      List<dynamic> list = paginatedList;
                      ss.studyList.value = [list[index]];
                      Get.to(() => StudyHomePage());
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffF1F1F1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Color(0xffF5F5F5),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Color(0xffDDDDDD),
                            blurRadius: 10,
                            offset: Offset(0, 1),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      height: 95,
                      child: Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Container(
                                width: 75,
                                height: 70,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                        'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/studyImage%2F${paginatedList[index]['docId']}?alt=media',
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Center(child: LoadingScreen()),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                      Positioned(
                                          left: 4,
                                          bottom: 4,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await toggleLike(
                                                  paginatedList[index]['docId'],
                                                  isOtherLiked);
                                              setState(() {
                                                if (isOtherLiked) {
                                                  paginatedList[index]
                                                  ['likeList']
                                                      .remove(us.userList[0]
                                                  ['docId']);
                                                } else {
                                                  paginatedList[index]
                                                  ['likeList']
                                                      .add(us.userList[0]
                                                  ['docId']);
                                                }
                                              });
                                            },
                                            child: SvgPicture.asset(
                                                isOtherLiked
                                                    ? 'assets/icon/Heart.svg'
                                                    : 'assets/icon/whiteEmptyHeart.svg',
                                                width: 25,
                                                height: 25),
                                          )),
                                    ],
                                  ),
                                ),
                              )),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Wrap(
                                    children: (paginatedList[index]['interest']
                                    as List?)
                                        ?.map<Widget>((interests) {
                                      Color? backgroundColors =
                                      interestBackgroundColor[
                                      interests];
                                      Color? interestTextColors =
                                      interestTextColor[interests];
                                      return Padding(
                                          padding:
                                          EdgeInsets.only(right: 7),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5),
                                            decoration: BoxDecoration(
                                              color: backgroundColors,
                                              borderRadius:
                                              BorderRadius.circular(30),
                                            ),
                                            child: Text(interests,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                    interestTextColors,
                                                    fontFamily: 'NotoSans',
                                                    fontWeight:
                                                    FontWeight.w700)),
                                          ));
                                    }).toList() ??
                                        []),
                                const SizedBox(height: 6),
                                Text(
                                  paginatedList[index]['studyName'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'NotoSans',
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10, right: 29),
                                  child: Row(
                                    children: [
                                      Text(
                                          '${paginatedList[index]['sido'] ?? ''} ${paginatedList[index]['gungu'] ?? ''}',
                                          style: f10w400DeppGray),
                                      Spacer(),
                                      Text(
                                          '멤버 ${(paginatedList[index]['studyUserList'] as List?)?.length ?? 0}',
                                          style: f10w400DeppGray),
                                      Spacer(),
                                      Text(
                                          '좋아요 ${(paginatedList[index]['likeList'] as List?)?.length ?? 0}',
                                          style: f10w400DeppGray),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String text) {
    return Container(
      width: 90,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffBEBEBE)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 9, right: 5),
        child: Row(
          children: [
            Text(text, style: f14bw300),
            Spacer(),
            SvgPicture.asset('assets/icon/down.svg'),
          ],
        ),
      ),
    );
  }
}
