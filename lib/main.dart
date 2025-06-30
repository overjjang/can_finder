import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter_tts/flutter_tts.dart';

List<Color> accessibleColors = [
  Colors.black,
  Colors.white,
  Colors.yellow,
  Colors.blue,
  Colors.red,
  Colors.green,
];

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시각장애인용 앱',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', ''), // 한국어
        const Locale('en', ''), // 영어
      ],
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? controller;
  Color selectedColor = Colors.blue;
  Color backgroundColor = Colors.white;

  late final BarcodeScanner barcodeScanner;
  final FlutterTts flutterTts = FlutterTts();

  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    barcodeScanner = BarcodeScanner();
    initCamera();
  }

  Future<void> initCamera() async {
    await Permission.camera.request();
    if (cameras.isNotEmpty) {
      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller!.initialize();
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    barcodeScanner.close();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> scanBarcode() async {
    if (controller == null || !controller!.value.isInitialized || isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final XFile file = await controller!.takePicture();

      final inputImage = InputImage.fromFilePath(file.path);
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        for (final barcode in barcodes) {
          final String? rawValue = barcode.rawValue;
          if (rawValue != null) {
            print('바코드 인식 성공: $rawValue');
            await flutterTts.speak("바코드 인식 완료");
            break; // 첫번째 바코드만 음성 출력 후 종료
          }
        }
      } else {
        print('바코드 인식 실패');
        await flutterTts.speak("바코드 인식 실패");
      }
    } catch (e) {
      print('바코드 인식 중 오류 발생: $e');
      await flutterTts.speak("바코드 인식 실패");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: controller != null && controller!.value.isInitialized
                ? CameraPreview(controller!)
                : Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isProcessing ? null : scanBarcode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(200, 60),
                    ),
                    child: Text(isProcessing ? '처리중...' : '촬영'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _openColorSettings(context),
                    icon: Icon(Icons.settings),
                    label: Text('설정'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      minimumSize: Size(200, 60),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openColorSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('색상 설정'),
          content: Wrap(
            spacing: 10,
            children: accessibleColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                    backgroundColor = color == Colors.black ? Colors.white : Colors.black;
                  });
                  Navigator.of(dialogContext).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selectedColor == color ? Colors.white : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: selectedColor == color
                      ? Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
