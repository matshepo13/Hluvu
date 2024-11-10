import 'package:flutter/services.dart';

class DialogService {
  static Future<String> getDialog() async {
    try {
      return await rootBundle.loadString('assets/dialog.txt');
    } catch (e) {
      print('Error loading dialog.txt: $e');
      return '';
    }
  }
}