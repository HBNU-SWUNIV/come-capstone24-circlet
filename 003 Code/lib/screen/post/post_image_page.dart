import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../components/components.dart';

class PostImagePage extends StatefulWidget {
  @override
  State<PostImagePage> createState() => _PostImagePageState();

  final Map<String, dynamic> postInfo;

  PostImagePage({required this.postInfo});
}

class _PostImagePageState extends State<PostImagePage> {
  final PageController controller = PageController();
  int idx = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${idx} / ${widget.postInfo['imagePaths'].length}'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: widget.postInfo['imagePaths'].length,
        onPageChanged: (int pageIndex) {
          setState(() {
            idx = pageIndex + 1;
          });
        },
        itemBuilder: (context, index) => Container(
          color: Colors.black,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: 'https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/post%2F${widget.postInfo['imagePaths'][index]}?alt=media',
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
