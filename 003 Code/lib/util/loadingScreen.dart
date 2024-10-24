import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child:  LoadingAnimationWidget.discreteCircle(
          color: Colors.grey,
          secondRingColor: Colors.grey,
          thirdRingColor: Colors.grey,
          size: 25,
        ));
  }
}
