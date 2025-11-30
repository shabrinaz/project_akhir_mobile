import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'lbs_screen.dart';
import 'profile_screen.dart';
import 'donation_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const MainNavigationScreen({Key? key, required this.onLogout})
      : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomeScreen(),
      const DonationScreen(),
      const LBSScreen(),
      ProfileScreen(onLogout: widget.onLogout),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // 🔼 LEBIH ATAS
        child: AppBar(
          backgroundColor: const Color(0xFF007BFF),
          elevation: 0,
          centerTitle: false,

          // 🔵 NA IKAN TEXT AGAR LEBIH PAS
          title: Padding(
            padding: const EdgeInsets.only(top: 8), // 🔼 NAIKIN SEDIKIT
            child: Text(
              _getTitle(_selectedIndex),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 🔵 BAGIAN MELENGKUNG
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),

          actions: _selectedIndex == 0
              ? [
                  Padding(
                    padding: const EdgeInsets.only(top: 8), // NAIKIN ICON JUGA
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tampilan di-refresh.')),
                        );
                      },
                    ),
                  )
                ]
              : null,
        ),
      ),

      body: _widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.newspaper), label: 'Artikel'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Donasi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on), label: 'Jelajah'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
