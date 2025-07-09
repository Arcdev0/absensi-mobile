import 'package:flutter/material.dart';
import 'package:arcdev_absensi/screens/barcode_screen.dart';
import 'package:arcdev_absensi/screens/history_screen.dart';
import 'package:arcdev_absensi/screens/settings_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

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
  int _selectedIndex = 1;
  String _userName = 'User';

  final List<IconData> iconList = [Icons.history, Icons.home, Icons.settings];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HistoryScreen(),
      BarcodeScreen(),
      SettingsScreen(userToken: widget.userToken),
    ];
    _loadUserName();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'User';
    });
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
        backgroundColor: const Color(0xFF0D47A1),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/ARC.png', fit: BoxFit.contain),
        ),
        title: const Text(''),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Text(
                  _userName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const CircleAvatar(
                    backgroundImage: AssetImage('profile.png'),
                  ),
                  onSelected: (value) async {
                    if (value == 'logout') {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.bottomSlide,
                        title: 'Hi, $_userName!',
                        desc:
                            'Apakah $_userName yakin ingin logout dari aplikasi?',
                        btnCancelOnPress: () {},
                        btnCancelText: 'Batal',
                        btnOkOnPress: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        btnOkText: 'Logout',
                        btnOkColor: Colors.blue,
                      ).show();
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => const [
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Text('Logout'),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutBack,
            ),
            child: child,
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 24,
        rightCornerRadius: 24,
        backgroundColor: const Color(0xFF0D47A1),
        activeColor: const Color(0xFFFFFFFF),
        inactiveColor: const Color(0xFFB3E5FC),
        onTap: _onItemTapped,
        splashSpeedInMilliseconds: 300,
      ),
    );
  }
}
