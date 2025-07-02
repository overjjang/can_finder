import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:yolo_realtime_plugin/yolo_realtime_plugin.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'dart:developer' as developer;

class YoloCameraScreen extends StatefulWidget {
  const YoloCameraScreen({Key? key}) : super(key: key);

  @override
  State<YoloCameraScreen> createState() => _YoloCameraScreenState();
}

class _YoloCameraScreenState extends State<YoloCameraScreen> {
  YoloRealtimeController? yoloController;
  List<dynamic>? lastBoxes;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    yoloInit();
  }

  Future<void> yoloInit() async {
    yoloController = YoloRealtimeController(
      fullClasses: fullClasses,
      activeClasses: activeClasses,
      androidModelPath: 'assets/models/yolov5s_320.pt',
      androidModelWidth: 320,
      androidModelHeight: 320,
      androidConfThreshold: 0.5,
      androidIouThreshold: 0.5,
      iOSModelPath: 'yolov5s',
      iOSConfThreshold: 0.5,
    );
    try {
      await yoloController?.initialize();
      setState(() {});
    } catch (e) {
      print('ERROR: $e');
    }
  }

  void onBoxCaptured(List<dynamic> boxes) {
    if (isPaused) return;
    for (var box in boxes) {
      final label = box.label ?? '';
      if (label == 'bottle' || label == 'cup' || label == 'can') {
        setState(() {
          isPaused = true;
          lastBoxes = [box];
        });
        break;
      }
    }
  }

  void onImageCaptured(Uint8List? data) async {
    if (!isPaused || data == null) {
      developer.log('onImageCaptured: 조건 불충족');
      return;
    }

    img.Image? origin = img.decodeImage(data);
    if (origin == null) {
      developer.log('onImageCaptured: 이미지 디코딩 실패');
      return;
    }

    final int origW = origin.width;
    final int origH = origin.height;

    // 이미지 중앙에서 고정 크기 영역 추출
    // 원본 이미지의 60%를 추출하는 예시
    final double cropRatio = 0.6;
    final int cropWidth = (origW * cropRatio).round();
    final int cropHeight = (origH * cropRatio).round();

    // 중앙 기준 좌표 계산
    final int x1 = ((origW - cropWidth) / 2).round();
    final int y1 = ((origH - cropHeight) / 2).round();

    // 크롭 영역이 이미지 범위 내에 있는지 확인
    if (x1 < 0 || y1 < 0 || x1 + cropWidth > origW || y1 + cropHeight > origH) {
      developer.log('onImageCaptured: 크롭 영역이 이미지 범위를 벗어남');
      return;
    }

    // 중앙 영역 크롭
    final crop = img.copyCrop(
      origin,
      x: x1,
      y: y1,
      width: cropWidth,
      height: cropHeight,
    );

    // 회전 필요시 적용 (현재는 회전 없음)
    final cropBytes = Uint8List.fromList(img.encodePng(crop));

    developer.log('크롭 정보: 원본=${origW}x${origH}, 중앙=(${x1},${y1}), 크기=${cropWidth}x${cropHeight}');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CroppedImageScreen(imageBytes: cropBytes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (yoloController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('YOLO 객체 인식')),
      body: YoloRealTimeView(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        controller: yoloController!,
        drawBox: true,
        captureBox: onBoxCaptured,
        captureImage: onImageCaptured,
      ),
    );
  }

  List<String> activeClasses = [
    "car", "person", "tv", "laptop", "mouse", "bottle", "cup", "keyboard", "cell phone", "can"
  ];
  List<String> fullClasses = [
    "person",
    "bicycle",
    "car",
    "motorcycle",
    "airplane",
    "bus",
    "train",
    "truck",
    "boat",
    "traffic light",
    "fire hydrant",
    "stop sign",
    "parking meter",
    "bench",
    "bird",
    "cat",
    "dog",
    "horse",
    "sheep",
    "cow",
    "elephant",
    "bear",
    "zebra",
    "giraffe",
    "backpack",
    "umbrella",
    "handbag",
    "tie",
    "suitcase",
    "frisbee",
    "skis",
    "snowboard",
    "sports ball",
    "kite",
    "baseball bat",
    "baseball glove",
    "skateboard",
    "surfboard",
    "tennis racket",
    "bottle",
    "wine glass",
    "cup",
    "fork",
    "knife",
    "spoon",
    "bowl",
    "banana",
    "apple",
    "sandwich",
    "orange",
    "broccoli",
    "carrot",
    "hot dog",
    "pizza",
    "donut",
    "cake",
    "chair",
    "couch",
    "potted plant",
    "bed",
    "dining table",
    "toilet",
    "tv",
    "laptop",
    "mouse",
    "remote",
    "keyboard",
    "cell phone",
    "microwave",
    "oven",
    "toaster",
    "sink",
    "refrigerator",
    "book",
    "clock",
    "vase",
    "scissors",
    "teddy bear",
    "hair drier",
    "toothbrush"
  ];
}

class CroppedImageScreen extends StatelessWidget {
  final Uint8List imageBytes;
  const CroppedImageScreen({required this.imageBytes, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('크롭된 이미지')),
      body: Center(child: Image.memory(imageBytes)),
    );
  }
}