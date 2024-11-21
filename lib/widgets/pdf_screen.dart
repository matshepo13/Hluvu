import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class PDFScreen extends StatelessWidget {
  final String path;

  const PDFScreen({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Report'),
        backgroundColor: const Color.fromARGB(255, 159, 109, 168),
      ),
      body: PDFView(
        filePath: path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: false,
      ),
    );
  }
}