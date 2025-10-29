// lib/screens/register_screen.dart (Kode Lengkap dan Sudah Diperbaiki)

import 'package:flutter/material.dart';
import '../helpers/db_helper.dart'; // Pastikan path ini benar
import '../models/user_model.dart'; // Pastikan path ini benar

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username dan Password tidak boleh kosong!')),
        );
      }
      return;
    }
    
    // --- OPERASI ASYNC DIMULAI ---
    final newUser = User(username: username, password: password);
    final result = await _dbHelper.registerUser(newUser);
    // --- OPERASI ASYNC SELESAI ---

    // Gunakan if (mounted) setelah await
    if (mounted) {
      if (result > 0) {
        // Registrasi Berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registrasi Berhasil! Silakan Login.'),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman Login
        Navigator.of(context).pop();
      } else if (result == -1) {
        // Gagal: Username sudah ada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Gagal: Username sudah digunakan.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Gagal lainnya (misalnya error database)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Registrasi Gagal. Coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register User Baru')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('DAFTAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Kembali ke Login
              },
              child: const Text('Sudah punya akun? Kembali ke Login.'),
            ),
          ],
        ),
      ),
    );
  }
}