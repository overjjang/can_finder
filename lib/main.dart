import 'package:flutter/material.dart';
import 'barcode.dart';          // ↩︎ 이미 올리신 바코드 스캐너
// import 'can_cam.dart';      // YOLO-캡쳐 화면이 필요하다면 추가로 import

void main() => runApp(const CanFinderApp());

/// ─────────────────────────────────────────────────────────────
///  전체 앱(테마·라우팅) ─ MyApp 대체 버전
/// ─────────────────────────────────────────────────────────────
class CanFinderApp extends StatelessWidget {
  const CanFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Can Finder',
      theme: ThemeData(                       // Material 3 + 색상 시드 예시
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const _Shell(),                  // ← 하단 탭을 품은 루트
    );
  }
}

/// ─────────────────────────────────────────────────────────────
///  Shell : 하단 NavigationBar + 3개의 탭 화면
/// ─────────────────────────────────────────────────────────────
class _Shell extends StatefulWidget {
  const _Shell({super.key});

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 1; // 기본 탭을 Scan(=BarcodeScannerPage)으로

  // 필요 페이지를 미리 리스트에 담아두면 setState 때 간단
  late final List<Widget> _pages = [
    const _HomePage(),
    const BarcodeScannerPage(),
    const _SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ① 현재 선택된 페이지 보여주기
      body: _pages[_index],

      // ② Material 3 NavigationBar (BottomNavigationBar 로 바꿔도 무방)
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
///  Home & Settings : 간단한 자리표시용 위젯
///  추후 기능이 필요하면 별도 파일로 분리해도 됩니다.
/// ─────────────────────────────────────────────────────────────
class _HomePage extends StatelessWidget {
  const _HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Welcome to Can Finder')),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Settings (Coming Soon)')),
    );
  }
}
