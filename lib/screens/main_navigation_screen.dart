import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'lbs_screen.dart';
import 'profile_screen.dart';
import 'donation_screen.dart';

class MainNavigationScreen extends StatefulWidget {
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
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        backgroundColor: Colors.blue,
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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Artikel',
          ),
          BottomNavigationBarItem( 
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
        selectedItemColor: Colors.cyan, 
        unselectedItemColor: Colors.blueGrey.shade400, 
        onTap: _onItemTapped,
      ),
    );
  }
}