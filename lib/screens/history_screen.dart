import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _uuid;
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  // Dummy data absen
  final List<Map<String, String>> _dummyHistory = List.generate(
    25,
    (index) => {
      'date': '2025-06-${(index % 30 + 1).toString().padLeft(2, '0')}',
      'time': '${8 + (index % 3)}:${(index % 60).toString().padLeft(2, '0')}',
      'status': index % 2 == 0 ? 'Hadir' : 'Terlambat',
      'location': 'Lokasi ${index % 4 + 1}'
    },
  );

  @override
  void initState() {
    super.initState();
    _loadUUID();
  }

  Future<void> _loadUUID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _uuid = prefs.getString('uuid');
    });
  }

  List<Map<String, String>> get _paginatedData {
    int start = (_currentPage - 1) * _itemsPerPage;
    int end = start + _itemsPerPage;
    return _dummyHistory.sublist(
      start,
      end > _dummyHistory.length ? _dummyHistory.length : end,
    );
  }

  int get _totalPages => (_dummyHistory.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absen'),
        centerTitle: true,
      ),
      body: _uuid == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade200,
                  child: Text(
                    'UUID: $_uuid',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _paginatedData.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _paginatedData[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item['status'] == 'Hadir'
                                ? Colors.green
                                : Colors.orange,
                            child: Icon(
                              item['status'] == 'Hadir'
                                  ? Icons.check
                                  : Icons.access_time,
                              color: Colors.white,
                            ),
                          ),
                          title: Text('${item['date']} - ${item['time']}'),
                          subtitle: Text('Status: ${item['status']}\nLokasi: ${item['location']}'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _currentPage > 1
                            ? () => setState(() => _currentPage--)
                            : null,
                        child: const Text('Sebelumnya'),
                      ),
                      const SizedBox(width: 16),
                      Text('Halaman $_currentPage dari $_totalPages'),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _currentPage < _totalPages
                            ? () => setState(() => _currentPage++)
                            : null,
                        child: const Text('Berikutnya'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
