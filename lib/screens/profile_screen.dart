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
  // Data user yang diperbarui
  final String _username = "Zeva Mila Sabrina";
  final String _nim = "124230043"; // Ditambahkan NIM
  // Menggunakan URL gambar dari profil Rakamin (diambil dari tautan Google)
  final String _photoUrl = "https://www.rakamin.com/profile/zeva-mila-sabrina-meo03scczfk3sefj"; 

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

  // Widget baru untuk Pesan dan Kesan
  Widget _buildPesanKesanCard() {
    const String pesan = "Mata kuliah pemrograman mobile dosennya gak jelasssssssssssssss, ngga pernah ngajar tiba tiba disuruh projek akhir";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10), // Bentuk kotak seragam
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pesan dan Kesan:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            pesan,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // --- UI/Tampilan ---

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 1. Foto Profil (Dibuat bulat)
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue.shade100,
            // Menggunakan NetworkImage dari URL yang Anda berikan
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
          const SizedBox(height: 5),

          // 2b. NIM (Ditambahkan)
          Text(
            'NIM: $_nim',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),

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
            color: Colors.cyan, 
          ),
          const SizedBox(height: 20),

          // 5. Pemilih Mata Uang (Dropdown)
          _buildCurrencySelector(),
          const SizedBox(height: 40),
          
          // 2c. Pesan dan Kesan
          _buildPesanKesanCard(),
          const SizedBox(height: 30), 

          // 6. Tombol Logout
          ElevatedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan, 
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

        ],
      ),
    );
  }

  // Widget _buildInfoCard (Diperbarui untuk ukuran seragam)
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity, // Memastikan lebar penuh
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: color.withOpacity(0.5), width: 1.5), 
      ),
      child: SizedBox(
        height: 80, // Menetapkan TINGGI MINIMUM agar seragam
        child: Row(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Pusatkan vertikal
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
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pilih Mata Uang Konversi:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity, // Memastikan lebar penuh
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade300, width: 1.5), // Border warna tema cerah
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currency,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.cyan), 
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
        ),
      ],
    );
  }
}