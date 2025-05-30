import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String userToken;

  const SettingsScreen({super.key, required this.userToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ChangePasswordScreen(userToken: userToken),
    );
  }
}
