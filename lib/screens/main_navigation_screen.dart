import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'lbs_screen.dart';
import 'profile_screen.dart';
import 'donation_screen.dart';

const Color kNavBarColor = Color(0xFF007BFF);
const Color kNavBarTextColor = Colors.white;
const double kNavBarRadius = 22;

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
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          backgroundColor: kNavBarColor,
          automaticallyImplyLeading: false,
          elevation: 0,

          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(kNavBarRadius),
            ),
          ),

          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _getTitle(_selectedIndex),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kNavBarTextColor,
              ),
            ),
          ),

          actions: _selectedIndex == 0
              ? [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 4),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tampilan artikel di-refresh.')),
                        );
                      },
                    ),
                  )
                ]
              : null,
        ),
      ),

      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: kNavBarColor,
          unselectedItemColor: Colors.blueGrey.shade400,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.newspaper), label: 'Artikel'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Donasi'),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_on), label: 'Jelajah'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
