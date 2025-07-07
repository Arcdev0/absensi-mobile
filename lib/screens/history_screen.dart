import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:arcdev_absensi/services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int? _id;
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;
  bool _isAscending = false;
  DateTime? _selectedDate;

  final DateFormat _apiDateFormat = DateFormat("HH:mm dd MMMM yyyy", 'en_US');

  final Map<String, String> _statusNoteMap = {
    'presensi': 'Kamu Hadir tepat waktu, tetap semangat ya!',
    'sakit': 'Kamu sakit ya, Semoga lekas sembuh ya!',
    'terlambat': 'Kamu terlambat nih, next time jangan lagi ya!',
    'izin': 'Semoga urusannya diperlancar ya!',
  };

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
<<<<<<< HEAD
<<<<<<< HEAD
    if (id != null) {
      await _fetchHistory(id);
    }
  }

  Future<void> _fetchHistory(int id) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/history/$id");
    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "*/*",
          "Authorization":
              "Bearer 1|0ZNts3xhnevdzBsaydNwjqps0qj", // Token contoh
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
=======
    if (id != null && token != null) {
      await _fetchHistory(id, token);
    } else {
      print("ID atau Token tidak ditemukan");
>>>>>>> tyo
=======
    if (id != null && token != null) {
      await _fetchHistory(id, token);
    } else {
>>>>>>> 71da0d7f5cf5da12b5e11c6f988fd54ab99c1f2a
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchHistory(int id, String token) async {
    try {
      final apiService = ApiService();
      final data = await apiService.getHistoryByID(id: id, token: token);
      setState(() {
        _historyData = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error saat ambil history: $e");
      setState(() => _isLoading = false);
    }
  }

  void _sortData() {
    setState(() {
      _isAscending = !_isAscending;
      _historyData.sort((a, b) {
        DateTime dateA = _apiDateFormat.parse(a['date']);
        DateTime dateB = _apiDateFormat.parse(b['date']);
        return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    });
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Warna header, tombol, dan selected date
              onPrimary: Colors.white, // Warna teks pada header
              onSurface: Colors.black, // Warna teks normal
            ),
            dialogBackgroundColor: Colors.white, // Warna latar dialog
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  List<Map<String, dynamic>> get _filteredData {
    if (_selectedDate == null) return _historyData;

    return _historyData.where((item) {
      final date = _apiDateFormat.parse(item['date']);
      return date.year == _selectedDate!.year &&
          date.month == _selectedDate!.month &&
          date.day == _selectedDate!.day;
    }).toList();
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                          label: Text(
                            _selectedDate == null
                                ? 'Pilih Tanggal'
                                : DateFormat(
                                  'dd MMM yyyy',
                                ).format(_selectedDate!),
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            _isAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                          ),
                          onPressed: _sortData,
                          tooltip: 'Urutkan tanggal',
                        ),
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed:
                                () => setState(() => _selectedDate = null),
                            tooltip: 'Reset filter',
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredData.isEmpty
                            ? const Center(
                              child: Text('Tidak ada data untuk tanggal ini.'),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _filteredData.length,
                              itemBuilder: (context, index) {
                                final item = _filteredData[index];
                                final date = _apiDateFormat.parse(item['date']);
                                final status = item['status'] ?? '';
                                final color = _getStatusColor(status);
                                final waktu = DateFormat(
                                  'hh.mm a',
                                ).format(date);
                                final note =
                                    _statusNoteMap[status.toLowerCase()] ?? "-";

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${date.day}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('MMM').format(date),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                status,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Waktu : $waktu',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Catatan : $note',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
      case 'presensi':
        return Colors.green;
      case 'sakit':
      case 'izin':
        return Colors.amber[800]!;
      case 'terlambat':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }
}
