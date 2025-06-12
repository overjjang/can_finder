import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color backgroundColor = Colors.black;
  Color buttonColor = Colors.yellow;

  final List<Map<String, dynamic>> accessibleColors = [
    {"name": "노랑", "color": Colors.yellow},
    {"name": "흰색", "color": Colors.white},
    {"name": "검정", "color": Colors.black},
    {"name": "파랑", "color": Colors.blue},
    {"name": "주황", "color": Colors.orange},
  ];

  final ImagePicker _picker = ImagePicker();

  void _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      // 카메라로 찍은 사진 처리 가능
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진을 찍었습니다.')),
      );
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        color: backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: accessibleColors.map((item) {
            return ListTile(
              leading: CircleAvatar(backgroundColor: item['color']),
              title: Text(
                item['name'],
                style: TextStyle(color: buttonColor),
              ),
              onTap: () {
                setState(() {
                  backgroundColor = item['color'];
                  buttonColor = item['color'] == Colors.black ? Colors.white : Colors.black;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text('시각장애인용 카메라 앱'),
          backgroundColor: buttonColor,
          foregroundColor: backgroundColor == Colors.black ? Colors.white : Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _openCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: backgroundColor == Colors.black ? Colors.white : Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('사진 찍기'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showColorPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: backgroundColor == Colors.black ? Colors.white : Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('설정'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
