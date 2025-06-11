import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late CameraController _cameraController;
  late BarcodeScanner _barcodeScanner;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission(); // 권한 먼저 요청
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
      _barcodeScanner = BarcodeScanner(); // 바코드 인식기 생성
    } else {
      print('카메라 권한 거부됨');
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();

    _cameraController.startImageStream((image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final WriteBuffer allBytes = WriteBuffer();
        for (Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }

        final bytes = allBytes.done().buffer.asUint8List();
        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          inputImageData: InputImageData(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            imageRotation: InputImageRotation.rotation0deg,
            inputImageFormat: InputImageFormat.nv21,
            planeData: image.planes.map(
                  (Plane plane) {
                return InputImagePlaneMetadata(
                  bytesPerRow: plane.bytesPerRow,
                  height: plane.height,
                  width: plane.width,
                );
              },
            ).toList(),
          ),
        );

        final barcodes = await _barcodeScanner.processImage(inputImage);
        for (Barcode barcode in barcodes) {
          final value = barcode.rawValue;
          if (value != null) {
            print("📦 바코드 내용: $value"); // 바코드 출력
          }
        }
      } catch (e) {
        print('에러 발생: $e');
      }

      _isDetecting = false;
    });

    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text("바코드 스캐너")),
      body: CameraPreview(_cameraController),
    );
  }
}
