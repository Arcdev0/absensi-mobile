import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/barcode_screen.dart';
import 'package:flutter_application_1/screens/history_screen.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  final String userToken;
  const MainScreen({super.key, required this.userToken});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Default ke Home (tengah)

  // Daftar halaman untuk bottom navigation
  final List<Widget> _pages = [
    HistoryScreen(),
    BarcodeScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo.png', // Ganti dengan path logo kamu
            fit: BoxFit.contain,
          ),
        ),
        title: const Text('Aplikasi Absensi'),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage(
                'assets/profile.png',
              ), // Ganti dengan foto profil
            ),
            onPressed: () {
              // Aksi ketika profil diklik (misalnya ke halaman profil)
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Profil diklik!')));
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
