// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  // 📌 Tambahkan callback untuk memberitahu navigasi utama agar di-logout
  final VoidCallback onLogout;

  const ProfileScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Data user placeholder (simulasi)
  final String _username = "PembacaBeritaBaik";
  final String _photoUrl = "https://i.pravatar.cc/150?img=12";

  // Konversi
  final double _pointToRupiahRate = 10.0;
  final double _usdToRupiahExchangeRate = 16000;
  final double _cnyToRupiahExchangeRate = 2200;

  int _totalPoints = 0;
  String _currency = 'IDR';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // --- Fungsi Load Data dan Konversi ---
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    int points = prefs.getInt('user_total_points') ?? 0;

    setState(() {
      _totalPoints = points;
    });
  }

  // Menghitung nilai konversi
  String _convertPoints() {
    // ... (Logika konversi tetap sama)
    double valueInRupiah = _totalPoints * _pointToRupiahRate;
    double finalValue;
    String symbol;
    String locale;

    if (_currency == 'IDR') {
      finalValue = valueInRupiah;
      symbol = 'Rp ';
      locale = 'id_ID';
    } else if (_currency == 'USD') {
      finalValue = valueInRupiah / _usdToRupiahExchangeRate;
      symbol = '\$';
      locale = 'en_US';
    } else if (_currency == 'CNY') {
      finalValue = valueInRupiah / _cnyToRupiahExchangeRate;
      symbol = '¥ ';
      locale = 'zh_CN';
    } else {
      return "0.00 IDR";
    }

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(finalValue);
  }

  void _onCurrencyChange(String? newCurrency) {
    if (newCurrency != null) {
      setState(() {
        _currency = newCurrency;
      });
    }
  }

  // FUNGSI LOGOUT
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Hapus session
    await prefs.remove('isLoggedIn');

    // 2. Beri pesan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda berhasil Logout'),
      ),
    );

    // 3. Panggil callback yang ada di MainNavigationScreen
    widget.onLogout();
  }

  // --- UI/Tampilan ---

  @override
  Widget build(BuildContext context) {
    // Scaffold di ProfileScreen tidak lagi memiliki AppBar
    // karena akan dikelola oleh MainNavigationScreen.

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // ... (Bagian Foto, Username, Poin, Konversi tetap sama)
          // 1. Foto Profil
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blueGrey.shade100,
            backgroundImage: NetworkImage(_photoUrl),
          ),
          const SizedBox(height: 15),

          // 2. Username
          Text(
            _username,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),

          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 20),

          // 3. Total Poin
          _buildInfoCard(
            icon: Icons.star_rate_rounded,
            title: "Total Poin Didapat",
            value: '$_totalPoints Poin',
            color: Colors.orange,
          ),
          const SizedBox(height: 20),

          // 4. Konversi Poin ke Mata Uang
          _buildInfoCard(
            icon: Icons.account_balance_wallet,
            title: "Nilai Konversi Poin",
            value: _convertPoints(),
            color: Colors.green,
          ),
          const SizedBox(height: 20),

          // 5. Pemilih Mata Uang (Dropdown)
          _buildCurrencySelector(),

          const SizedBox(height: 40),

          // 6. Tombol Logout
          ElevatedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Aturan Konversi
          Text(
            "Aturan Konversi: 10 Poin = Rp 100.00",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ... (Widget _buildInfoCard dan _buildCurrencySelector tetap sama)
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currency,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
          hint: const Text("Pilih Mata Uang Konversi"),
          items: <String>['IDR', 'USD', 'CNY'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value == 'IDR'
                    ? 'Rupiah (IDR)'
                    : value == 'USD'
                    ? 'US Dollar (USD)'
                    : 'Yuan (CNY)',
              ),
            );
          }).toList(),
          onChanged: _onCurrencyChange,
        ),
      ),
    );
  }
}
