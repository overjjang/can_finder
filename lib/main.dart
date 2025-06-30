import 'package:flutter/material.dart';
import 'barcode.dart'; // 바코드 스캐너 화면 불러오기

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Can Finder',
      home: BarcodeScannerPage(), // 앱 시작 시 바코드 스캐너 화면으로 이동
    );
  }
}
