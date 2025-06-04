import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _token, _uuid;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      _uuid = prefs.getString('uuid');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _token != null ? 'Token: $_token' : 'Memuat token...',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _uuid != null ? 'UUID: $_uuid' : 'Memuat UUID...',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
