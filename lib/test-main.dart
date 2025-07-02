import 'package:flutter/material.dart';
      import 'package:camera/camera.dart';
      import 'can-cam.dart'; // CanCam 위젯 임포트

      Future<void> main() async {
        // Flutter 엔진과 위젯 바인딩을 초기화합니다.
        WidgetsFlutterBinding.ensureInitialized();

        runApp(const MyApp());
      }

      class MyApp extends StatelessWidget {
        const MyApp({Key? key}) : super(key: key);

        @override
        Widget build(BuildContext context) {
          return MaterialApp(
            title: '캔 파인더',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            home: const HomeScreen(), // 홈 화면으로 설정
            debugShowCheckedModeBanner: false,
          );
        }
      }

      class HomeScreen extends StatelessWidget {
        const HomeScreen({Key? key}) : super(key: key);

        @override
        Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('캔 파인더'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '카메라를 실행하려면 아래 버튼을 누르세요',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 버튼 클릭 시 카메라 화면으로 이동
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const YoloCameraScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('카메라 열기'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }