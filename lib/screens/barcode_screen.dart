import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'dart:math';

// Singleton untuk menyimpan data QR Code dan timer agar persisten
class QrCodeManager {
  static final QrCodeManager _instance = QrCodeManager._internal();

  factory QrCodeManager() {
    return _instance;
  }

  QrCodeManager._internal();

  final List<String> _dummyData = [
    "DATA_QR_CODE_12345",
    "ANOTHER_VALUE_98765",
    "THIRD_DUMMY_CODE_ABCDE",
  ];

  late String _currentQrData;
  late Timer _timer;
  late int _countdownSeconds; // Ini yang perlu dipastikan terinisialisasi

  // Menambahkan flag untuk melacak apakah sudah diinisialisasi
  bool _isInitialized = false;

  Function(String, int)? _listener;

  String get currentQrData => _currentQrData;
  int get countdownSeconds => _countdownSeconds;
  bool get isInitialized => _isInitialized; // Getter untuk status inisialisasi

  void initialize() {
    if (_isInitialized) return; // Mencegah inisialisasi berulang

    print("Initializing QrCodeManager...");
    // Inisialisasi data pertama kali
    _currentQrData = _dummyData[0];
    _countdownSeconds = 300; // 5 menit = 300 detik

    _startTimer();
    _isInitialized = true;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownSeconds--;
      if (_countdownSeconds <= 0) {
        _updateQrData();
        _countdownSeconds = 300; // Reset countdown
      }
      _listener?.call(_currentQrData, _countdownSeconds);
    });
  }

  void _updateQrData() {
    final random = Random();
    _currentQrData = _dummyData[random.nextInt(_dummyData.length)];
    print("QR Code data updated to: $_currentQrData");
  }

  void addListener(Function(String, int) listener) {
    _listener = listener;
    // Panggil listener segera setelah ditambahkan agar widget menampilkan data awal
    if (_isInitialized) {
      // Pastikan sudah diinisialisasi sebelum memanggil listener
      _listener?.call(_currentQrData, _countdownSeconds);
    }
  }

  void removeListener() {
    _listener = null;
  }

  void dispose() {
    _timer.cancel();
    _isInitialized =
        false; // Reset status inisialisasi jika benar-benar dibuang
    print("QrCodeManager disposed.");
  }
}

class BarcodeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const BarcodeScreen({super.key, this.userName = '', this.userEmail = ''});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final QrCodeManager _qrCodeManager = QrCodeManager();
  String _qrData = "";
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    // Inisialisasi manager di sini juga sebagai fallback,
    // atau pastikan di main() sudah dipanggil
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
    // Tidak dispose manager di sini agar persisten antar halaman
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
          const Text(
            'Halaman Barcode',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          // Pastikan _qrData tidak kosong sebelum mencoba membuat QrImageView
          if (_qrData.isNotEmpty)
            QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
              gapless: true,
            )
          else
            const CircularProgressIndicator(), // Tampilkan loading jika data belum ada
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
          Text(
            'Data QR saat ini: $_qrData', // Menampilkan data QR saat ini (opsional)
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Pastikan Anda memanggil QrCodeManager().initialize() di fungsi main()
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding Flutter sudah siap
  QrCodeManager()
      .initialize(); // Inisialisasi QrCodeManager sekali di awal aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Builds the main application widget tree.
  ///
  /// This method returns a [MaterialApp] widget configured with a title, theme,
  /// and a home screen that consists of a [Scaffold] with an [AppBar] and a
  /// [BarcodeScreen] as its body.
  /*******  fdd7b337-27b7-4453-8468-b08bcacf7ad0  *******/
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('QR Code Generator')),
        body: const BarcodeScreen(), // Tampilkan BarcodeScreen
      ),
    );
  }
}
