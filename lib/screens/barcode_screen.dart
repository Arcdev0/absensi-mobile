import 'package:flutter/material.dart';

class BarcodeScreen extends StatelessWidget {
  const BarcodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Halaman Barcode', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          // Tambahkan widget barcode di sini, misalnya pakai package barcode_widget
          Placeholder(fallbackHeight: 100, fallbackWidth: 200),
        ],
      ),
    );
  }
}
