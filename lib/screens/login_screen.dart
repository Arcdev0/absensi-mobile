import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/change_password_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // final deviceId = await _getDeviceId(); // Ambil device ID (Asli - dikomentari)
      final deviceId = 'dummy-device-id-123456'; // Dummy device ID

      final result = await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        deviceId,
      );

      final token = result['token'];
      final mustChangePassword = result['must_change_password'] ?? false;

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      if (mustChangePassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(userToken: token),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(userToken: token)),
        );
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('Invalid email')) {
        errorMessage = 'Email tidak ditemukan';
      } else if (e.toString().contains('Invalid')) {
        errorMessage = 'Email atau password salah';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Gagal terhubung ke server, periksa koneksi Anda';
      } else {
        errorMessage = 'Error: $e';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ??
          'unknown_android_id'; // Ganti androidId dengan id
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios_id';
    }

    return 'unknown_device';
  }

  Future<bool> _checkAndroid10OrAbove() async {
    if (!Platform.isAndroid) return false;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 29;
  }

  Future<String> _getAlternativeAndroidId(AndroidDeviceInfo androidInfo) async {
    return 'alt-android-${androidInfo.board}-${androidInfo.bootloader}-${androidInfo.fingerprint?.hashCode}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade700,
                  Colors.blue.shade500,
                ],
                stops: const [0.1, 0.5, 0.9],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FlutterLogo(size: 80),
                              const SizedBox(height: 24),
                              Text(
                                'Selamat Datang',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Silakan login untuk melanjutkan',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email tidak boleh kosong';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password tidak boleh kosong';
                                  }
                                  if (value.length < 6) {
                                    return 'Password minimal 6 karakter';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade800,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 4,
                                  ),
                                  child:
                                      _isLoading
                                          ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : const Text(
                                            'LOGIN',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  // Navigasi ke halaman lupa password
                                },
                                child: Text(
                                  'Lupa Password?',
                                  style: TextStyle(color: Colors.blue.shade800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
