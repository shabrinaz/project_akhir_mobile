import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/session_manager.dart';
import '../helpers/db_helper.dart';
import '../models/user_model.dart';
import 'developer_screen.dart';

/// 🎨 WARNA-WARNA PROFIL (UBAH DI SINI AJA)
const Color kProfileBackgroundColor = Color(0xFFF7F9FC);

const Color kProfileNameTextColor = Colors.black87;

const Color kPointsCardBg = Colors.white;
const Color kPointsCardBorder = Color(0xFF007BFF);
const Color kPointsIconColor = Color(0xFF007BFF);

const Color kConvertCardBg = Colors.white;
const Color kConvertCardBorder = Color(0xFF007BFF);

const Color kDeveloperCardBg = Colors.white;
const Color kDeveloperCardBorder = Color(0xFF007BFF);
const Color kDeveloperTextColor = Color(0xFF007BFF);

const Color kLogoutButtonColor = Colors.red;
const Color kLogoutTextColor = Colors.white;

const Color kCameraCircleColor = Colors.white;
const Color kCameraIconColor = Color(0xFF007BFF);

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionManager _sessionManager = SessionManager();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  User? _currentUser;
  bool _isLoading = true;

  // Mata uang
  final List<String> _currencyCodes = ['IDR', 'USD', 'EUR', 'JPY'];
  String _selectedCurrency = 'IDR';

  final Map<String, double> _currencyRateVsIdr = {
    'IDR': 1.0,
    'USD': 1 / 16000,
    'EUR': 1 / 17500,
    'JPY': 1 / 110,
  };

  final Map<String, String> _currencySymbols = {
    'IDR': 'Rp',
    'USD': '\$',
    'EUR': '€',
    'JPY': '¥',
  };

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = await _sessionManager.getUserId();

    if (userId != null) {
      final user = await _dbHelper.getUserById(userId);
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } else {
      final username = prefs.getString('username') ?? 'Pengguna';
      setState(() {
        _currentUser = User(username: username, password: '', points: 0);
        _isLoading = false;
      });
    }
  }

  // ===== FOTO PROFIL =====
  Future<void> _pickProfileImage() async {
    try {
      if (_currentUser == null || _currentUser!.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User belum terdaftar di database.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      _currentUser = User(
        id: _currentUser!.id,
        username: _currentUser!.username,
        password: _currentUser!.password,
        points: _currentUser!.points,
        profileImagePath: file.path,
      );

      await _dbHelper.updateUser(_currentUser!);

      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===== KONVERSI POIN =====
  int get _points => _currentUser?.points ?? 0;

  double _getConvertedAmount() {
    final double baseIdr = _points * 100.0; // 1 poin = Rp 100
    final rate = _currencyRateVsIdr[_selectedCurrency] ?? 1.0;
    return baseIdr * rate;
  }

  String _formatConvertedAmount() {
    final amount = _getConvertedAmount();
    final symbol = _currencySymbols[_selectedCurrency] ?? '';

    if (_selectedCurrency == 'IDR') {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: '$symbol ',
        decimalDigits: 0,
      ).format(amount);
    } else if (_selectedCurrency == 'USD') {
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: '$symbol ',
        decimalDigits: 2,
      ).format(amount);
    } else if (_selectedCurrency == 'EUR') {
      return NumberFormat.currency(
        locale: 'de_DE',
        symbol: '$symbol ',
        decimalDigits: 2,
      ).format(amount);
    } else if (_selectedCurrency == 'JPY') {
      return NumberFormat.currency(
        locale: 'ja_JP',
        symbol: '$symbol ',
        decimalDigits: 0,
      ).format(amount);
    }

    return "$symbol ${amount.toStringAsFixed(2)}";
  }

  // ===== LOGOUT =====
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    await _sessionManager.clearSession();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final username = _currentUser!.username;
    final profileImagePath = _currentUser!.profileImagePath;
    final File? profileFile =
        (profileImagePath != null && profileImagePath.isNotEmpty)
            ? File(profileImagePath)
            : null;

    // ❗️TIDAK ADA SCAFFOLD DI SINI – ini cuma isi body
    return Container(
      color: kProfileBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      profileFile != null ? FileImage(profileFile) : null,
                  child: profileFile == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        )
                      : null,
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: InkWell(
                    onTap: _pickProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kCameraCircleColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kCameraIconColor,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: kCameraIconColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              username,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kProfileNameTextColor,
              ),
            ),

            const SizedBox(height: 28),

            // TOTAL POIN
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: kPointsCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPointsCardBorder, width: 1.6),
              ),
              child: ListTile(
                leading: Icon(Icons.stars, color: kPointsIconColor),
                title: const Text(
                  "Total Poin",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text("$_points poin"),
              ),
            ),

            // KONVERSI POIN
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kConvertCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kConvertCardBorder, width: 1.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Konversi Poin",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "1 poin = Rp 100",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("Mata Uang: "),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedCurrency,
                        items: _currencyCodes
                            .map(
                              (code) => DropdownMenuItem<String>(
                                value: code,
                                child: Text(code),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedCurrency = value;
                          });
                        },
                      ),
                      const Spacer(),
                      Text(
                        _formatConvertedAmount(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // CARD DEVELOPER
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DeveloperScreen(),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: kDeveloperCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: kDeveloperCardBorder, width: 1.6),
                ),
                child: Row(
                  children: [
                    Text(
                      "Developer",
                      style: TextStyle(
                        color: kDeveloperTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        size: 18, color: kDeveloperTextColor),
                  ],
                ),
              ),
            ),

            // LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kLogoutButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Keluar",
                  style: TextStyle(
                    color: kLogoutTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
