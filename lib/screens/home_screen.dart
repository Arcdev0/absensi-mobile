import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Pastikan path import benar
import 'login_screen.dart'; // Sesuaikan dengan struktur folder Anda

class HomeScreen extends StatelessWidget {
  final ApiService apiService;
  final String userToken;

  HomeScreen({
    super.key,
    required this.userToken,
    ApiService? apiService, // Parameter opsional untuk testing
  }) : apiService = apiService ?? ApiService();

  Future<void> _logout(BuildContext context) async {
    try {
      final success = await apiService.logout(userToken);

      if (success) {
        // Menggunakan pushAndRemoveUntil untuk memastikan semua rute sebelumnya dihapus
        // sehingga pengguna tidak bisa kembali ke home screen dengan tombol back
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false, // Hapus semua rute sebelumnya
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout gagal, coba lagi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Untuk menampilkan token yang lebih aman dari error substring
    String displayedToken =
        userToken.length > 10 ? '${userToken.substring(0, 10)}...' : userToken;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat Datang',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Token: $displayedToken', // Menggunakan token yang sudah dicek panjangnya
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
