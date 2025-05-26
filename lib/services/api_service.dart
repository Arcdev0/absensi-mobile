import 'dart:convert'; // Untuk encode dan decode JSON
import 'package:http/http.dart' as http; // Library untuk HTTP requests

class ApiService {
  // Base URL untuk API Anda. Penting: Ganti ini jika IP server berubah.
  final String baseUrl = 'http://192.168.1.10:8000/api';

  // Metode untuk melakukan login
  Future<String?> login(String email, String password) async {
    final url = Uri.parse(
      '$baseUrl/login',
    ); // Membuat URL lengkap untuk endpoint login
    try {
      final response = await http.post(
        // Melakukan HTTP POST request
        url,
        headers: {
          'Content-Type':
              'application/json', // Memberi tahu server bahwa body adalah JSON
          'Accept':
              'application/json', // Memberi tahu server bahwa kita mengharapkan respons JSON
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }), // Mengirim email dan password dalam format JSON
      );

      // Cetak status code dan body respons untuk debugging. Sangat membantu!
      print(
        'Login Response: Status ${response.statusCode}, Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        // Jika respons sukses (HTTP 200 OK)
        final data = jsonDecode(
          response.body,
        ); // Decode body respons dari JSON ke Dart Map/Object
        // Logika untuk mencoba berbagai kemungkinan field token dari respons API
        if (data['access_token'] != null) {
          return data['access_token']; // Umumnya untuk Laravel Sanctum/Passport
        } else if (data['token'] != null) {
          return data['token']; // Struktur kustom atau framework lain
        } else if (data['data'] != null && data['data']['token'] != null) {
          return data['data']['token']; // Struktur bertingkat (misal: respons { "data": { "token": "..." } })
        } else {
          // Jika token tidak ditemukan di semua kemungkinan field
          throw Exception('Token tidak ditemukan di respons');
        }
      } else {
        // Jika respons tidak sukses (misal: 401 Unauthorized, 400 Bad Request)
        final errorData = jsonDecode(
          response.body,
        ); // Decode body error respons
        String errorMessage =
            errorData['message'] ??
            'Login gagal'; // Ambil pesan error dari server atau gunakan pesan default
        throw Exception(
          errorMessage,
        ); // Lempar exception dengan pesan error yang lebih spesifik
      }
    } catch (e) {
      // Menangkap error jaringan atau error lainnya
      print('Login error: $e'); // Cetak error ke konsol untuk debugging
      throw Exception(
        'Gagal login: $e',
      ); // Lempar exception yang akan ditangkap oleh UI (LoginPage)
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
