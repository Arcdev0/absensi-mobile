import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

class QrCodeManager {
  static final QrCodeManager _instance = QrCodeManager._internal();

  factory QrCodeManager() => _instance;

  String userUUID = '';

  void setUUID(String uuid) {
    if (userUUID != uuid) {
      userUUID = uuid;
      _updateQrData();
      _countdownSeconds = 300;
      _listener?.call(_currentQrData, _countdownSeconds);
      print("UUID changed, QR code regenerated.");
    }
  }

  QrCodeManager._internal();

  static String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(
      length,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  late String _currentQrData;
  late Timer _timer;
  late int _countdownSeconds;
  bool _isInitialized = false;
  Function(String, int)? _listener;

  String get currentQrData => _currentQrData;
  int get countdownSeconds => _countdownSeconds;
  bool get isInitialized => _isInitialized;

  void initialize() {
    if (_isInitialized) return;
    print("Initializing QrCodeManager...");
    _updateQrData();
    _countdownSeconds = 300;
    _startTimer();
    _isInitialized = true;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownSeconds--;
      if (_countdownSeconds <= 0) {
        _updateQrData();
        _countdownSeconds = 300;
      }
      _listener?.call(_currentQrData, _countdownSeconds);
    });
  }

  void _updateQrData() {
    final now = DateTime.now();
    final formattedDate =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    final formattedTime =
        "${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}";
    final randomCode = _generateRandomCode(8);

    _currentQrData =
        "${userUUID}_${formattedDate}_${formattedTime}_$randomCode";
    print("QR Code data updated to: $_currentQrData");
  }

  void addListener(Function(String, int) listener) {
    _listener = listener;
    if (_isInitialized) {
      _listener?.call(_currentQrData, _countdownSeconds);
    }
  }

  void removeListener() {
    _listener = null;
  }

  void dispose() {
    _timer.cancel();
    _isInitialized = false;
    print("QrCodeManager disposed.");
  }
}

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final QrCodeManager _qrCodeManager = QrCodeManager();
  String _qrData = "";
  int _countdown = 0;
  String? _uuid;

  @override
  void initState() {
    super.initState();
    _loadUUIDFromPrefs();
  }

  Future<void> _loadUUIDFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString('uuid') ?? '';

    setState(() {
      _uuid = uuid;
    });

    _qrCodeManager.setUUID(uuid);
    _qrCodeManager.initialize();
    _qrCodeManager.addListener((data, countdown) {
      if (mounted) {
        setState(() {
          _qrData = data;
          _countdown = countdown;
        });
      }
    });
  }

  @override
  void dispose() {
    _qrCodeManager.removeListener();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_uuid != null)
            UuidDisplayWidget(uuid: _uuid!)
          else
            const CircularProgressIndicator(),

          const SizedBox(height: 20),

          const Text(
            'Halaman Barcode',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          if (_qrData.isNotEmpty)
            QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
              gapless: true,
            )
          else
            const CircularProgressIndicator(),

          const SizedBox(height: 30),

          const Text(
            'QR Code akan berubah dalam:',
            style: TextStyle(fontSize: 18),
          ),

          Text(
            _formatDuration(_countdown),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class UuidDisplayWidget extends StatelessWidget {
  final String uuid;

  const UuidDisplayWidget({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) {
    return Text(
      'UUID: $uuid',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }
}

// Main app dan entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('uuid', '123e4567-e89b-12d3-a456-426614174000');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Screen')),
      body:
          const BarcodeScreen(), // Panggil BarcodeScreen tanpa Scaffold & AppBar
    );
  }
}
