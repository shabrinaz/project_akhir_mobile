// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  // Callback untuk memberitahu root widget agar me-reload state
  final VoidCallback onLoginSuccess; 

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  // Simulasi login
  Future<void> _handleLogin(BuildContext context) async {
    // Di sini Anda akan memvalidasi username/password ke DB nyata.
    // Untuk simulasi, kita langsung anggap sukses.
    
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Set status login menjadi true
    await prefs.setBool('isLoggedIn', true);
    
    // 2. Simpan username simulasi (opsional)
    await prefs.setString('username', 'PembacaBeritaBaik');

    // 3. Panggil callback untuk navigasi ke MainNavigationScreen
    onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Berita Login'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.public, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              // Input Simulasi
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),
              
              // Tombol Login
              ElevatedButton(
                onPressed: () => _handleLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('LOGIN', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 10),
              const Text("Login akan otomatis sukses untuk simulasi.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}