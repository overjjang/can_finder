import 'package:flutter/material.dart';
  import 'package:camera/camera.dart';
  import 'package:tflite/tflite.dart';
  import 'dart:io';

  class CanCam extends StatefulWidget {
    const CanCam({Key? key}) : super(key: key);

    @override
    State<CanCam> createState() => _CanCamState();
  }

  class _CanCamState extends State<CanCam> {
    late List<CameraDescription> cameras;
    CameraController? controller;
    bool isInitialized = false;
    bool isModelLoaded = false;

    // 분석 결과 저장 변수
    String result = "";
    File? capturedImage;
    bool isAnalyzing = false;

    @override
    void initState() {
      super.initState();
      initCamera();
      loadModel();
    }

    // TensorFlow Lite 모델 로드
    Future<void> loadModel() async {
      try {
        await Tflite.loadModel(
          model: "assets/model.tflite",
          labels: "assets/labels.txt",
        );
        setState(() {
          isModelLoaded = true;
        });
        print('텐서플로우 모델 로드 성공');
      } catch (e) {
        print('텐서플로우 모델 로드 오류: $e');
      }
    }

    Future<void> initCamera() async {
      try {
        cameras = await availableCameras();
        controller = CameraController(
          cameras[0],
          ResolutionPreset.medium,
        );
        await controller!.initialize();

        if (!mounted) return;
        setState(() {
          isInitialized = true;
        });
      } catch (e) {
        print('카메라 초기화 오류: $e');
      }
    }

// 이미지 분석 함수 (객체 감지용)
    Future<void> analyzeImage(String imagePath) async {
      setState(() {
        isAnalyzing = true;
        result = "이미지 분석 중...";
      });

      try {
        // 객체 감지 모델 사용
        var recognition = await Tflite.detectObjectOnImage(
          path: imagePath,
          model: "SSDMobileNet", // 또는 "YOLO"
          threshold: 0.3,
          imageMean: 127.5,
          imageStd: 127.5,
          numResultsPerClass: 2,
        );

        setState(() {
          isAnalyzing = false;
          if (recognition != null && recognition.isNotEmpty) {
            result = "인식된 객체:\n";
            for (var item in recognition) {
              // 인식된 객체의 정확도와 위치 정보 포함
              result += "${item['detectedClass']} (${(item['confidenceInClass'] * 100).toStringAsFixed(2)}%)\n";
            }
          } else {
            result = "인식할 수 있는 캔이 없습니다.";
          }
        });
      } catch (e) {
        setState(() {
          isAnalyzing = false;
          result = "이미지 분석 오류: $e";
        });
        print('이미지 분석 오류: $e');
      }
    }

    @override
    void dispose() {
      controller?.dispose();
      Tflite.close();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      if (!isInitialized) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('캔 인식 카메라'),
        ),
        body: Column(
          children: [
            Expanded(
              child: capturedImage != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.file(capturedImage!),
                        if (isAnalyzing)
                          const CircularProgressIndicator(),
                      ],
                    )
                  : CameraPreview(controller!),
            ),
            if (result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.black87,
                width: double.infinity,
                child: Text(
                  result,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: capturedImage != null
                        ? () {
                            setState(() {
                              capturedImage = null;
                              result = "";
                            });
                          }
                        : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 촬영'),
                  ),
                  ElevatedButton.icon(
                    onPressed: capturedImage == null
                        ? () async {
                            try {
                              final image = await controller!.takePicture();
                              setState(() {
                                capturedImage = File(image.path);
                              });
                              analyzeImage(image.path);
                            } catch (e) {
                              print('사진 촬영 오류: $e');
                            }
                          }
                        : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('사진 촬영'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }