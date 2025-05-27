import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Home_screen.dart';
import 'package:flutter_application_1/screens/history_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import '../services/api_service.dart'; // Pastikan path import benar

class MainScreen extends StatefulWidget {
  final String userToken;
  const MainScreen({super.key, required this.userToken});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Default ke Home (tengah)

  final List<Widget> _pages = [
    HistoryScreen(),
    HomeScreen(
      userToken: '',
      apiService: ApiService(),
    ), // Ganti dengan widget.userToken nanti
    // SettingsScreen
    // (),
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
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        title: const Text('Aplikasi Absensi'),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/profile.png'),
            ),
            onPressed: () {
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
