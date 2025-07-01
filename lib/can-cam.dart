import 'package:flutter/material.dart';
    import 'package:yolo_realtime_plugin/yolo_realtime_plugin.dart';

    class YoloCameraScreen extends StatefulWidget {
      const YoloCameraScreen({Key? key}) : super(key: key);

      @override
      State<YoloCameraScreen> createState() => _YoloCameraScreenState();
    }

    class _YoloCameraScreenState extends State<YoloCameraScreen> {
      YoloRealtimeController? yoloController;

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
            captureBox: (boxes) {
              // 인식된 박스 정보 활용
            },
            captureImage: (data) async {
              // 이미지 데이터 활용
            },
          ),
        );
      }

      List<String> activeClasses = [
        "car",
        "person",
        "tv",
        "laptop",
        "mouse",
        "bottle",
        "cup",
        "keyboard",
        "cell phone",
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