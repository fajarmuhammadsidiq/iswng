import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

void main() {
  runApp(const MyApp());
}

/// Entrypoint overlay wajib ada annotation [@pragma('vm:entry-point')]
@pragma('vm:entry-point')
void overlayMain() {
  runApp(const OverlayApp());
}

/// ====================
/// MAIN APP
/// ====================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _overlayPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    setState(() => _overlayPermission = granted);
  }

  Future<void> _requestPermission() async {
    final granted = await FlutterOverlayWindow.requestPermission();
    setState(() => _overlayPermission = granted!);
  }

  Future<void> _showOverlay(String mode) async {
    if (!_overlayPermission) {
      await _requestPermission();
      return;
    }

    await FlutterOverlayWindow.showOverlay(
      overlayTitle: "Overlay Tester",
      overlayContent: "mode:$mode",
      enableDrag: false,
      flag: mode == "clickThrough"
          ? OverlayFlag.clickThrough
          : OverlayFlag.defaultFlag,
    );

    await FlutterOverlayWindow.shareData("mode:$mode");
  }

  Future<void> _closeOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overlay Tester',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Overlay Tester'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overlay Permission: $_overlayPermission',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _requestPermission,
                child: const Text("Minta Izin Overlay"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showOverlay("consumeTouch"),
                child: const Text("Tampilkan Overlay (Menelan sentuhan)"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _showOverlay("clickThrough"),
                child: const Text("Tampilkan Overlay (Melewatkan sentuhan)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _closeOverlay,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Tutup Overlay"),
              ),
              const Spacer(),
              const Text(
                "Petunjuk:\n"
                "- Mode 'Menelan sentuhan': Aplikasi di bawah tidak bisa disentuh.\n"
                "- Mode 'Melewatkan sentuhan': Aplikasi di bawah tetap bisa disentuh.\n\n"
                "Gunakan untuk menguji apakah aplikasi asli kamu terlindungi dari Tapjacking.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//// ====================
/// OVERLAY APP
/// ====================
class OverlayApp extends StatefulWidget {
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  String _mode = 'unknown';

  @override
  void initState() {
    super.initState();

    // Dengarkan pesan dari main app
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is String && event.startsWith('mode:')) {
        setState(() {
          _mode = event.split(':')[1];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TextDirection.ltr, // atau TextDirection.rtl jika diperlukan
      child: Material(
        color: Colors.red.withOpacity(0.8),
        child: Stack(
          alignment: Alignment.topCenter, // Gunakan alignment non-directional
          children: [
            // Banner semi-transparan di atas
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                color: Colors.red.withOpacity(0.8),
                alignment: Alignment.center,
                child: Text(
                  'OVERLAY - mode: $_mode',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
