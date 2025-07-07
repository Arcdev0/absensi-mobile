import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math';

class QrCodeManager {
  static final QrCodeManager _instance = QrCodeManager._internal();

  factory QrCodeManager() => _instance;

  String userUUID = '';
  late DateTime _lastGeneratedTime;
  Position? _currentPosition;

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final now = DateTime.now();
      final diff = now.difference(_lastGeneratedTime).inSeconds;

      if (diff >= 300) {
        await _updateQrData();
        _countdownSeconds = 300;
      } else {
        _countdownSeconds = 300 - diff;
      }

      _listener?.call(_currentQrData, _countdownSeconds);
    });
  }

  Future<void> _updateLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Gagal mendapatkan lokasi: $e');
    }
  }

  Future<void> _updateQrData() async {
    await _updateLocation();

    _lastGeneratedTime = DateTime.now();
    final now = _lastGeneratedTime;
    final formattedDate =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    final formattedTime =
        "${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}";
    final randomCode = _generateRandomCode(8);

    final locationPart = _currentPosition != null
        ? "${_currentPosition!.latitude.toStringAsFixed(5)},${_currentPosition!.longitude.toStringAsFixed(5)}"
        : "unknown_location";

    _currentQrData =
        "${userUUID}_${formattedDate}_${formattedTime}_${locationPart}_$randomCode";

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

class _BarcodeScreenState extends State<BarcodeScreen>
    with WidgetsBindingObserver {
  final QrCodeManager _qrCodeManager = QrCodeManager();
  String _qrData = "";
  int _countdown = 0;
  String? _uuid;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      final lastTime = _qrCodeManager._lastGeneratedTime;
      final diff = now.difference(lastTime).inSeconds;

      if (diff >= 300) {
        _qrCodeManager.setUUID(_qrCodeManager.userUUID);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
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
      body: const BarcodeScreen(),
    );
  }
}
