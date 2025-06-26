import 'package:flutter/material.dart';
import 'package:arcdev_absensi/screens/change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String userToken;

  const SettingsScreen({super.key, required this.userToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangePasswordScreen(userToken: userToken, userUUID: ''),
    );
  }
}
