import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int? _id;
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadID();
  }

  Future<void> _loadID() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    String? token = prefs.getString('token');

    setState(() => _id = id);
    if (id != null && token != null) {
      await _fetchHistory(id, token);
    } else {
      print("ID atau Token tidak ditemukan");
      setState(() => _isLoading = false);
    }
  }

Future<void> _fetchHistory(int id, String token) async {
  final url = Uri.parse("http://193.203.160.191:83/api/history/$id");
  try {
    final response = await http.get(
      url,
      headers: {
        "Accept": "*/*",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      setState(() {
        _historyData = data.map((e) => e as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Gagal memuat data');
    }
  } catch (e) {
    print("Error: $e");
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absen'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey.shade200,
                    child: Text(
                      'ID: $_id',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child:
                        _historyData.isEmpty
                            ? const Center(
                              child: Text('Tidak ada data riwayat.'),
                            )
                            : ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: _historyData.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = _historyData[index];
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          item['status'] == 'Presensi'
                                              ? Colors.green
                                              : Colors.red,
                                      child: Icon(
                                        item['status'] == 'Presensi'
                                            ? Icons.check
                                            : Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      '${item['date']} (${item['type'] ?? "-"})',
                                    ),
                                    subtitle: Text(
                                      'Status: ${item['status']}\nCatatan: ${item['extra']}',
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
