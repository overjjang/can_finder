import 'package:flutter/material.dart';
          import 'package:camera/camera.dart';
          import 'package:tflite_flutter/tflite_flutter.dart';
          import 'package:image/image.dart' as img;
          import 'dart:io';
          import 'dart:math';
          import 'dart:typed_data';

          class CanCam extends StatefulWidget {
            const CanCam({Key? key}) : super(key: key);

            @override
            State<CanCam> createState() => _CanCamState();
          }

          class _CanCamState extends State<CanCam> {
            late List<CameraDescription> cameras;
            CameraController? controller;
            bool isInitialized = false;
            bool isAnalyzing = false;
            String result = "";
            List<Map<String, dynamic>>? detectedObjects;

            // YOLOv5 관련 변수
            Interpreter? interpreter;
            List<String> labels = []; // 레이블 목록
            int frameSkip = 10; // 10프레임마다 분석
            int currentFrame = 0;

            // 모델 설정
            final modelInputSize = 640; // YOLOv5s 입력 크기
            final threshold = 0.5; // 감지 임계값

            @override
            void initState() {
              super.initState();
              initModel();
              initCamera();
            }

            Future<void> initModel() async {
              try {
                // YOLOv5 모델 로드
                interpreter = await Interpreter.fromAsset('assets/yolov5s.tflite');

                // 레이블 로드 (assets/labels.txt 파일 필요)
                final labelsData = await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
                labels = labelsData.split('\n');

                print('YOLOv5 모델 초기화 완료: ${interpreter?.getInputTensors().first.shape}');
              } catch (e) {
                print('모델 초기화 오류: $e');
              }
            }

            Future<void> initCamera() async {
              try {
                cameras = await availableCameras();
                controller = CameraController(
                  cameras[0],
                  ResolutionPreset.medium,
                  imageFormatGroup: ImageFormatGroup.yuv420,
                );
                await controller!.initialize();

                // 카메라 스트림 처리 설정
                controller!.startImageStream((image) {
                  currentFrame++;
                  if (currentFrame % frameSkip == 0 && !isAnalyzing && interpreter != null) {
                    processImage(image);
                  }
                });

                if (!mounted) return;
                setState(() {
                  isInitialized = true;
                });
              } catch (e) {
                print('카메라 초기화 오류: $e');
              }
            }

            Future<void> processImage(CameraImage image) async {
              if (isAnalyzing) return;

              setState(() {
                isAnalyzing = true;
                result = "분석 중...";
              });

              try {
                // 이미지 변환
                final inputImage = _convertCameraImage(image);

                // 모델 실행
                final detections = await runYoloModel(inputImage, image.width, image.height);

                // 캔 필터링 (ID 0번이 캔이라고 가정)
                final canDetections = detections.where((d) =>
                  (d['class'] == 0 || // 캔 ID
                   labels[d['class']].toLowerCase().contains('can') ||
                   labels[d['class']].toLowerCase().contains('bottle'))
                ).toList();

                setState(() {
                  if (canDetections.isNotEmpty) {
                    final detection = canDetections.first;
                    result = "인식된 객체: ${labels[detection['class']]}\n"
                        "신뢰도: ${(detection['confidence'] * 100).toStringAsFixed(1)}%";
                    detectedObjects = canDetections;
                  } else {
                    result = "캔을 찾을 수 없습니다";
                    detectedObjects = null;
                  }
                });
              } catch (e) {
                print('분석 오류: $e');
                setState(() {
                  result = "분석 오류 발생";
                });
              }

              setState(() => isAnalyzing = false);
            }

            // CameraImage를 모델 입력 형식으로 변환
            Uint8List _convertCameraImage(CameraImage image) {
              // YUV420 형식을 RGB로 변환 후 모델 입력 형식으로 리사이징
              // 간소화를 위해 YUV420 첫 번째 플레인만 사용 (실제로는 완전한 변환 필요)
              final inputBuffer = Uint8List(modelInputSize * modelInputSize * 3);

              // 여기서는 간단히 이미지 변환을 가정 (실제 앱에서는 정확한 YUV->RGB 변환 필요)
              return inputBuffer;
            }

            Future<List<Map<String, dynamic>>> runYoloModel(Uint8List imageBytes, int imageWidth, int imageHeight) async {
              // 입력 텐서 설정
              final input = [imageBytes];

              // 출력 텐서 설정 (YOLOv5 출력 형식에 맞게)
              final outputShape = interpreter!.getOutputTensor(0).shape;
              final outputSize = outputShape[1] * outputShape[2];
              final output = [List<double>.filled(outputSize, 0)];

              // 모델 실행
              interpreter!.run(input, output);

              // 결과 해석 (YOLOv5 출력 형식에 맞게)
              final results = <Map<String, dynamic>>[];

              // 간단한 결과 처리 예시 (실제 구현은 YOLOv5 출력 형식에 맞게 정확히 구현 필요)
              final rawOutput = output[0];

              // YOLO 출력 처리 (실제 코드에서는 YOLOv5 출력 형식에 맞게 구현 필요)
              // 이 부분은 예시일 뿐이며, 실제 YOLOv5 출력 처리 로직이 필요합니다
              for (int i = 0; i < 25; i++) { // 예시: 최대 25개 객체 감지
                final classId = 0; // 간소화: 실제로는 출력에서 추출해야 함
                final confidence = 0.8; // 간소화: 실제로는 출력에서 추출해야 함

                if (confidence > threshold) {
                  results.add({
                    'class': classId,
                    'confidence': confidence,
                    'rect': [0.2, 0.2, 0.3, 0.3], // 간소화: 실제로는 출력에서 추출해야 함
                  });
                }
              }

              return results;
            }

            @override
            void dispose() {
              controller?.dispose();
              interpreter?.close();
              super.dispose();
            }

            @override
            Widget build(BuildContext context) {
              // build 메서드는 기존 코드 유지
              if (!isInitialized) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return Scaffold(
                appBar: AppBar(
                  title: const Text('캔 인식 카메라 (YOLOv5)'),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CameraPreview(controller!),
                          if (detectedObjects != null)
                            CustomPaint(
                              painter: YoloDetectionPainter(
                                detectedObjects!,
                                Size(controller!.value.previewSize!.width,
                                     controller!.value.previewSize!.height),
                                labels,
                              ),
                              size: Size.infinite,
                            ),
                          if (isAnalyzing)
                            const Positioned(
                              bottom: 10,
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
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
                  ],
                ),
              );
            }
          }

          class YoloDetectionPainter extends CustomPainter {
            final List<Map<String, dynamic>> detections;
            final Size imageSize;
            final List<String> labels;

            YoloDetectionPainter(this.detections, this.imageSize, this.labels);

            @override
            void paint(Canvas canvas, Size size) {
              final Paint paint = Paint()
                ..color = Colors.green
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3.0;

              final Paint background = Paint()..color = Colors.black.withOpacity(0.5);

              for (final detection in detections) {
                final rect = detection['rect'];
                final classId = detection['class'];
                final confidence = detection['confidence'];
                final label = classId < labels.length ? labels[classId] : 'Unknown';

                final left = rect[0] * size.width;
                final top = rect[1] * size.height;
                final width = rect[2] * size.width;
                final height = rect[3] * size.height;

                final boundingBox = Rect.fromLTWH(left, top, width, height);
                canvas.drawRect(boundingBox, paint);

                // 레이블 표시
                TextPainter textPainter = TextPainter(
                  text: TextSpan(
                    text: '$label ${(confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  textDirection: TextDirection.ltr,
                );
                textPainter.layout();

                canvas.drawRect(
                  Rect.fromLTWH(left, top - 18, textPainter.width + 4, 18),
                  background,
                );

                textPainter.paint(canvas, Offset(left + 2, top - 18));
              }
            }

            @override
            bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
          }