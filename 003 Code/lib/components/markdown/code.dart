import 'package:circlet/util/font/font.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/material.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  final String language;

  CodeElementBuilder({required this.language});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width,
      child: HighlightView(
        element.textContent,
        language: language,
        theme: atomOneDarkTheme,
        textStyle: f12bw700,
      ),
    );
  }
}

