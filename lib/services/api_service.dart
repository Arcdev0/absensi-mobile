import 'dart:convert'; // Untuk encode dan decode JSON
import 'package:http/http.dart' as http; // Library untuk HTTP requests
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class ApiService {
  // Base URL untuk API Anda. Penting: Ganti ini jika IP server berubah.
  final String baseUrl = 'http://193.203.160.191:83/api';

  // Metode untuk melakukan login
  Future<Map<String, dynamic>> login(
    String email,
    String password,
    String deviceId,
  ) async {
    final url = Uri.parse('$baseUrl/login');
    try {
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

      print('Login Response: ${response.statusCode}, ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data != null) {
        final token =
            data['access_token'] ?? data['token'] ?? data['data']['token'];
        final mustChangePassword =
            data['data']?['user']?['must_change_password'] ?? false;
        final uuid = data['data']?['user']?['uuid'];

        return {'token': token, 'must_change_password': mustChangePassword, 'uuid':uuid};
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
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

  Future<String> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('$baseUrl/change-password');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      print(
        'Change Password Response: Status ${response.statusCode}, Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['message'] ?? 'Password changed successfully.';
        } else {
          throw Exception(data['message'] ?? 'Failed to change password.');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Change password failed.');
      }
    } catch (e) {
      print('Change Password Error: $e');
      throw Exception('Gagal mengubah password: $e');
    }
  }
  
}
