import 'dart:convert'; // Untuk encode dan decode JSON
import 'package:http/http.dart' as http; // Library untuk HTTP requests
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class ApiService {
  // Base URL untuk API Anda. Penting: Ganti ini jika IP server berubah.
  final String baseUrl = 'http://193.203.160.191:83/api';

  // Metode untuk melakukan login
  Future<String?> login(String email, String password, String deviceId) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      print(
        'Kirim ke server: ${jsonEncode({'email': email, 'password': password, 'device_id': deviceId})}',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_id': deviceId,
        }),
      );

      print(
        'Login Response: Status ${response.statusCode}, Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['access_token'] != null) {
          return data['access_token'];
        } else if (data['token'] != null) {
          return data['token'];
        } else if (data['data'] != null && data['data']['token'] != null) {
          return data['data']['token'];
        } else {
          throw Exception('Token tidak ditemukan di respons');
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? 'Login gagal';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Gagal login: $e');
    }
  }

  // Metode untuk melakukan logout
  Future<bool> logout(String token) async {
    final url = Uri.parse(
      '$baseUrl/logout',
    ); // Membuat URL lengkap untuk endpoint logout
    try {
      final response = await http.post(
        // Melakukan HTTP POST request
        url,
        headers: {
          'Content-Type':
              'application/json', // Memberi tahu server bahwa body adalah JSON
          'Authorization':
              'Bearer $token', // Mengirim token autentikasi di header Authorization
        },
      );

      // Cetak status code dan body respons untuk debugging
      print(
        'Logout Response: Status ${response.statusCode}, Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        // Jika respons sukses
        return true; // Logout berhasil
      } else {
        // Jika respons tidak sukses
        final errorData = jsonDecode(
          response.body,
        ); // Decode body error respons
        print(
          'Logout failed: ${errorData['message'] ?? 'Unknown error'}',
        ); // Cetak pesan error
        return false; // Logout gagal
      }
    } catch (e) {
      // Menangkap error jaringan atau error lainnya
      print('Logout error: $e'); // Cetak error ke konsol
      return false; // Logout gagal karena error
    }
  }
}
