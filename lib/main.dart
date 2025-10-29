import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_navigation_screen.dart'; 
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Care News',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      // AuthWrapper adalah gerbang utama
      home: const AuthWrapper(), 
      debugShowCheckedModeBanner: false,
    );
  }
}

// WIDGET BARU: AuthWrapper (Pengecek Status Login)
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _isLoggedIn; // Status null berarti loading

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Baca status login dari SharedPreferences
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }
  
  // Fungsi callback yang dipanggil oleh Login/Logout Screen
  void _updateAuthStatus() {
    // Memaksa AuthWrapper untuk memeriksa status lagi dan memuat layar yang benar
    _checkLoginStatus(); 
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      // Tampilkan loading saat mengecek status
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } 
    
    if (_isLoggedIn == true) {
      // Jika login, tampilkan MainNavigationScreen
      return MainNavigationScreen(onLogout: _updateAuthStatus);
    } else {
      // Jika belum login, tampilkan LoginScreen
      return LoginScreen(onLoginSuccess: _updateAuthStatus);
    }
  }
}