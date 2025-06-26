import 'package:flutter/material.dart';
import 'package:arcdev_absensi/screens/barcode_screen.dart';
import 'package:arcdev_absensi/screens/history_screen.dart';
import 'package:arcdev_absensi/screens/settings_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final String userToken;
  final String userUUID;
  const MainScreen({
    super.key,
    required this.userToken,
    required this.userUUID,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Default ke Home (tengah)

  // Daftar halaman untuk bottom navigation
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HistoryScreen(),
      BarcodeScreen(),
      SettingsScreen(
        userToken: widget.userToken,
      ), // Kirim token dari MainScreen
    ];
  }

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
          child: Image.asset('assets/ARC.png', fit: BoxFit.contain),
        ),
        title: const Text('Aplikasi Absensi'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('profile.png'),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  animType: AnimType.bottomSlide,
                  title: 'Konfirmasi Logout',
                  desc: 'Apakah Anda yakin ingin logout?',
                  btnCancelOnPress: () {},
                  btnCancelText: 'Batal',
                  btnOkOnPress: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('token');
                    await prefs.remove('uuid');
                    await prefs.remove('id');
                    await prefs.setBool('isLoggedIn', false);

                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  btnOkText: 'Logout',
                  btnOkColor: Colors.red,
                ).show();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
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
