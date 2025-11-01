// lib/screens/main_navigation_screen.dart

import 'package:flutter/material.dart';
// Import semua halaman yang akan ditampilkan di Bottom Nav Bar
import 'home_screen.dart'; 
import 'lbs_screen.dart';
import 'profile_screen.dart';
// Import halaman baru
import 'donation_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  // 📌 Callback wajib dari AuthWrapper untuk memicu navigasi ke LoginScreen
  final VoidCallback onLogout; 
  const MainNavigationScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  // List halaman yang akan ditampilkan
  late final List<Widget> _widgetOptions; 

  @override
  void initState() {
    super.initState();
    // Inisialisasi list widget
    _widgetOptions = <Widget>[
      const HomeScreen(),
      const DonationScreen(), // Halaman baru di Index 1
      const LBSScreen(),
      // Meneruskan callback onLogout dari AuthWrapper ke ProfileScreen
      ProfileScreen(onLogout: widget.onLogout), 
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Menentukan AppBar berdasarkan halaman yang aktif
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Artikel';
      case 1:
        return 'Donasi';
      case 2:
        return 'Donasi Terdekat';
      case 3:
        return 'Profil';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        backgroundColor: Colors.blue, // Biru cerah
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tampilan di-refresh.')),
                    );
                  },
                ),
              ]
            : null,
      ),
      
      // Tampilkan halaman yang dipilih
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Diperlukan untuk 4 item atau lebih
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem( // Item baru
            icon: Icon(Icons.favorite),
            label: 'Donasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Jelajah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan, // Warna Aksen Cerah
        unselectedItemColor: Colors.blueGrey.shade400, // Abu-abu yang lebih netral
        onTap: _onItemTapped,
      ),
    );
  }
}