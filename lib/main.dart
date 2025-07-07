import 'package:flutter/material.dart';
import 'package:arcdev_absensi/screens/home_screen.dart';
import 'package:arcdev_absensi/screens/login_screen.dart';
import 'package:arcdev_absensi/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return MainScreen(userToken: args['token'], userUUID: args['uuid']);
        },
      },
    );
  }
}
