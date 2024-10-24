import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../provider/user_state.dart';

class PdfView extends StatefulWidget {
  final String docId;
  PdfView({super.key, required this.docId});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  final us = Get.put(UserState());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('포트폴리오'),
      ),
      body: SfPdfViewer.network('https://firebasestorage.googleapis.com/v0/b/circlet-9c202.appspot.com/o/portfolio%2F${widget.docId}?alt=media'),
    );
  }
}
