// lib/screens/lbs_screen.dart

import 'package:flutter/material.dart';

class LBSScreen extends StatelessWidget {
  const LBSScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan Berbasis Lokasi (LBS)'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            Text(
              'Fitur LBS akan datang di sini!',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const Text(
              'Anda dapat menemukan lokasi donasi atau event terdekat.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}