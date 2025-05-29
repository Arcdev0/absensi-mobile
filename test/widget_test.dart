import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/login_screen.dart';

void main() {
  testWidgets('Login page has email and password fields', (
    WidgetTester tester,
  ) async {
    // 1. Build LoginScreen
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // 2. Beri waktu untuk animasi/initialization
    await tester.pumpAndSettle();

    // 3. Verifikasi elemen UI yang diharapkan
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
    expect(find.text('Email'), findsOneWidget); // Label email
    expect(find.text('Password'), findsOneWidget); // Label password
    expect(find.text('LOGIN'), findsOneWidget); // Tombol login
    expect(find.byType(ElevatedButton), findsOneWidget); // Pastikan ada tombol
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Coba submit tanpa input
    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    // Verifikasi pesan error muncul
    expect(find.text('Email tidak boleh kosong'), findsOneWidget);
    expect(find.text('Password tidak boleh kosong'), findsOneWidget);
  });

  testWidgets('Successful navigation after login', (WidgetTester tester) async {
    // Mock navigator observer
    final mockObserver = MockNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(home: const LoginPage(), navigatorObservers: [mockObserver]),
    );

    // Isi form
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('LOGIN'));

    // Tunggu proses async
    await tester.pumpAndSettle();

    // Verifikasi navigasi ke HomeScreen
    expect(find.byType(MainScreen), findsOneWidget);
  });
}

class MockNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Implementasi untuk testing navigasi
  }
}
