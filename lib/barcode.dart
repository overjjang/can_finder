import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late CameraController _cameraController;
  late BarcodeScanner _barcodeScanner;
  late FlutterTts _tts;

  bool _isDetecting = false;
  bool _isSpeaking  = false;

  String? _lastValue;
  DateTime _lastSpoken = DateTime.fromMillisecondsSinceEpoch(0);

  String? _displayValue;    // 하단 텍스트
  String? _productName;     // API 조회된 상품명

  @override
  void initState() {
    super.initState();
    _initTTS();
    _requestCameraPermission();
  }

  Future<void> _initTTS() async {
    _tts = FlutterTts();
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.awaitSpeakCompletion(true);
    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((msg)   => _isSpeaking = false);
  }

  Future<void> _requestCameraPermission() async {
    if (await Permission.camera.request().isGranted) {
      await _initializeCamera();
      _barcodeScanner = BarcodeScanner();
    } else {
      debugPrint('카메라 권한 거부됨');
    }
  }

  Future<void> _initializeCamera() async {
    final camera = (await availableCameras())
        .firstWhere((c) => c.lensDirection == CameraLensDirection.back);

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
        // 바이트 변환
        final wb = WriteBuffer();
        for (final p in image.planes) wb.putUint8List(p.bytes);
        final bytes = wb.done().buffer.asUint8List();

        // ML Kit 입력 이미지
        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );

        // 바코드 스캔
        final barcodes = await _barcodeScanner.processImage(inputImage);
        for (final barcode in barcodes) {
          final value = barcode.rawValue;
          if (value == null) continue;

          final now = DateTime.now();
          final cool = now.difference(_lastSpoken).inMilliseconds > 2000;

          if (!_isSpeaking && (value != _lastValue || cool)) {
            _lastValue  = value;
            _lastSpoken = now;

            await _fetchProductInfo(value); // 1. API 상품명 조회

            final speakText = _productName != null && _productName != ''
                ? _productName!
                : '알 수 없는 상품';

            await _tts.speak(speakText);   // 2. TTS 발화

            setState(() => _displayValue = '$value  •  $speakText'); // 3. 하단 텍스트 갱신
          }
        }
      } catch (e) {
        debugPrint('에러 발생: $e');
      }
      _isDetecting = false;
    });

    setState(() {}); // 카메라 초기화 후 UI 갱신
  }

  // 식품안전나라 OpenAPI로 상품명 조회
  Future<void> _fetchProductInfo(String barcode) async {
    // (API 키는 실제 서비스 시 별도 관리 필요)
    const apiKey = '1bd77ea13ec242898ac6';
    final url =
        'http://openapi.foodsafetykorea.go.kr/api/$apiKey/C005/json/1/1/BAR_CD=$barcode';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final row = data['C005']?['row']?[0];
        setState(() {
          _productName = row?['PRDLST_NM'] ?? '상품 정보 없음';
        });
      } else {
        setState(() => _productName = '조회 실패(${res.statusCode})');
      }
    } catch (e) {
      setState(() => _productName = '네트워크 오류');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _barcodeScanner.close();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('바코드 스캐너')),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_cameraController)),
          if (_displayValue != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                _displayValue!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
