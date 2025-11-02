import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/db_helper.dart'; 
import 'register_screen.dart'; 

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess; 
  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login
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

    final user = await _dbHelper.loginUser(username, password);

    if (mounted) {
      if (user != null) {
        // Jika user ditemukan => login berhasil
        final prefs = await SharedPreferences.getInstance();
        
        // Simpan status login dan data user
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', user.username);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Berhasil! Selamat datang, ${user.username}')),
        );
        
        widget.onLoginSuccess();
      } else {
        // Jika user tidak ditemukan => login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Gagal. Username atau Password salah.'),
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
        title: const Text('Donasi Sosial Virtual'),
        backgroundColor: Colors.blue, // Biru cerah
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.public, size: 80, color: Colors.cyan),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              // Input Username
              TextField( 
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.cyan), 
                ),
              ),
              const SizedBox(height: 15),
              // Input Password 
              TextField( 
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.cyan),
                ),
              ),
              const SizedBox(height: 30),
              
              // Tombol Login
              ElevatedButton(
                onPressed: _handleLogin, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
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
                child: const Text('Belum punya akun? Daftar sekarang!', 
                  style: TextStyle(fontSize: 16, color: Colors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}