import 'package:flutter/material.dart';

import '../util/loadingScreen.dart';


showLoading(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    builder: (ctx) {
      return Center(child: LoadingScreen());
    },
    context: context,
  );
}