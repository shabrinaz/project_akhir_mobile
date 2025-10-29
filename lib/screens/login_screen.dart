// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/db_helper.dart'; // Import DatabaseHelper
import 'register_screen.dart'; 

// Ubah menjadi StatefulWidget
class LoginScreen extends StatefulWidget {
  // Callback untuk memberitahu root widget agar me-reload state
  final VoidCallback onLoginSuccess; 

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Tambahkan Controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // LOGIKA LOGIN DENGAN VALIDASI DATABASE
  Future<void> _handleLogin() async {
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

    // 1. Panggil fungsi login yang sesungguhnya di database
    // Fungsi ini akan menghash password dan membandingkannya di DB
    final user = await _dbHelper.loginUser(username, password);

    if (mounted) {
      if (user != null) {
        // 2. Jika user ditemukan (Login Sukses)
        final prefs = await SharedPreferences.getInstance();
        
        // Simpan status login dan data user
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', user.username);
        // Anda juga bisa menyimpan user ID, dll.
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Login Berhasil! Selamat datang, ${user.username}')),
        );
        
        // 3. Panggil callback untuk navigasi ke MainNavigationScreen
        widget.onLoginSuccess();
      } else {
        // 2. Jika user tidak ditemukan (Login Gagal)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Login Gagal. Username atau Password salah.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              
              // Input Username (dihubungkan ke Controller)
              TextField( 
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              // Input Password (dihubungkan ke Controller)
              TextField( 
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),
              
              // Tombol Login (memanggil _handleLogin yang sudah diperbaiki)
              ElevatedButton(
                onPressed: _handleLogin, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('LOGIN', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              
              // Tombol Register
              TextButton(
                onPressed: () {
                  // Navigasi ke RegisterScreen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Belum punya akun? Daftar sekarang!', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}