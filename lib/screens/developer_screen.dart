import 'package:flutter/material.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Developer",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF007BFF),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informasi Developer",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text("Nama  : (isi sendiri)"),
            Text("NIM   : (isi sendiri)"),
            Text("Kelas : (isi sendiri)"),
            // Tambah info lain sesuka kamu
          ],
        ),
      ),
    );
  }
}
