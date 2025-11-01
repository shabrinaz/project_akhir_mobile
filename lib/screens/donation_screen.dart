// lib/screens/donation_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Definisi model sederhana untuk Organisasi Donasi
class DonationOrg {
  final String title;
  final DateTime deadlineUtc;
  final IconData icon;
  final Color color;

  DonationOrg({
    required this.title,
    required this.deadlineUtc,
    required this.icon,
    required this.color,
  });
}

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  // Data Donasi dalam UTC
  final List<DonationOrg> _donationOrganizations = [
    DonationOrg(
      title: 'Unicef',
      deadlineUtc: DateTime.utc(2025, 11, 5, 15, 0, 0), // 5 Nov 2025, 15:00 UTC
      icon: Icons.child_care,
      color: Colors.blue,
    ),
    DonationOrg(
      title: 'Palestina',
      deadlineUtc: DateTime.utc(2025, 11, 10, 12, 0, 0), // 10 Nov 2025, 12:00 UTC
      icon: Icons.flag,
      color: Colors.red,
    ),
    DonationOrg(
      title: 'Timur Tengah',
      deadlineUtc: DateTime.utc(2025, 11, 15, 8, 0, 0), // 15 Nov 2025, 08:00 UTC
      icon: Icons.mosque,
      color: Colors.teal,
    ),
    DonationOrg(
      title: 'Afrika',
      deadlineUtc: DateTime.utc(2025, 11, 20, 20, 0, 0), // 20 Nov 2025, 20:00 UTC
      icon: Icons.public,
      color: Colors.green,
    ),
  ];

  String _selectedTimezoneKey = 'WIB'; // Default ke WIB

  // Mapping untuk Timezone: Key -> {Display Name, Offset dari UTC dalam jam}
  final Map<String, dynamic> _timezones = {
    'WIB': {'name': 'WIB (UTC+7)', 'offsetHours': 7},
    'WITA': {'name': 'WITA (UTC+8)', 'offsetHours': 8},
    'WIT': {'name': 'WIT (UTC+9)', 'offsetHours': 9},
    'LONDON': {'name': 'London (UTC+0)', 'offsetHours': 0},
  };
  
  @override
  void initState() {
    super.initState();
    _loadTimezone();
  }
  
  // Fungsi untuk memuat timezone yang dipilih pengguna
  Future<void> _loadTimezone() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimezone = prefs.getString('donation_timezone') ?? 'WIB'; 
    
    if (mounted) {
      setState(() {
        _selectedTimezoneKey = _timezones.containsKey(savedTimezone) ? savedTimezone : 'WIB';
      });
    }
  }
  
  // FUNGSI UNTUK MENGUBAH TIMEZONE
  void _onTimezoneChange(String? newTimezoneKey) async {
    if (newTimezoneKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('donation_timezone', newTimezoneKey); 
      
      if (mounted) {
        setState(() {
          _selectedTimezoneKey = newTimezoneKey;
        });
        
        // Mengatasi bug LocaleDataException
        final String tzDisplayName = _timezones[newTimezoneKey]!['name'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zona waktu donasi diubah ke $tzDisplayName')),
        );
      }
    }
  }


  // MENGUBAH FUNGSI INI UNTUK MENGHASILKAN STRING YANG DAPAT DI-SPLIT
  String _formatDeadline(DateTime utcTime) {
    
    final tzData = _timezones[_selectedTimezoneKey] ?? _timezones['WIB']!;
    final offsetHours = tzData['offsetHours'] as int;
    final tzName = tzData['name'] as String;
    
    final localTime = utcTime.add(Duration(hours: offsetHours));
    
    // Format: "EEEE, dd MMMM yyyy|HH:mm|TZ_NAME"
    final datePart = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(localTime); 
    final timePart = DateFormat('HH:mm', 'id_ID').format(localTime);
    
    // Menggunakan '|' sebagai separator untuk split
    return '$datePart|$timePart|$tzName'; 
  }

  // Widget untuk menampilkan Card Donasi (Disesuaikan untuk List View 1 Kolom)
  Widget _buildDonationCard(DonationOrg org) {
    final formattedDeadline = _formatDeadline(org.deadlineUtc);
    final parts = formattedDeadline.split('|'); // [Date, Time, TZ Name]
    final dateString = parts[0]; 
    final timeString = '${parts[1]} ${parts[2]}'; // e.g., "11:04 WIB (UTC+7)"
    
    final isClosed = org.deadlineUtc.isBefore(DateTime.now().toUtc());
    // Memastikan kita memiliki akses ke MaterialColor shades
    final MaterialColor safeColor = org.color is MaterialColor ? org.color as MaterialColor : Colors.blue;
    final Color textColor = isClosed ? Colors.red : safeColor.shade800;


    return Card(
      // Memberi margin di bawah setiap kartu untuk memisahkan item list
      margin: const EdgeInsets.only(bottom: 12.0), 
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Bentuk kotak seragam
      child: Container(
        decoration: BoxDecoration(
          color: isClosed ? Colors.grey[200] : org.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          // Border warna tema untuk penyeragaman bentuk kotak
          border: Border.all(color: isClosed ? Colors.red : safeColor.shade400, width: 1.5), 
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row( // Main Row: Icon + Judul/Deadline
            crossAxisAlignment: CrossAxisAlignment.start, // Align ke atas
            children: [
              // 1. ICON (Kiri)
              Icon(org.icon, size: 36, color: safeColor),
              const SizedBox(width: 16),

              // 2. JUDUL ORGANISASI & DEADLINE (Expanded Center)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // JUDUL ORGANISASI
                    Text(
                      org.title, // KEEP THIS
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: safeColor, // Menggunakan warna dari MaterialColor
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8), // Spasi antara judul dan deadline
                    
                    // LABEL DEADLINE
                    Text(
                      'Ditutup:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isClosed ? Colors.red : Colors.grey.shade700,
                      ),
                    ),
                    
                    const SizedBox(height: 2),

                    // TANGGAL (Baris 1 Deadline)
                    Text(
                      isClosed ? 'DONASI SUDAH BERAKHIR' : dateString,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isClosed ? Colors.red.shade800 : textColor,
                      ),
                    ),

                    // WAKTU + ZONA WAKTU (Baris 2 Deadline)
                    if (!isClosed)
                      Text(
                        timeString, 
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget untuk Pemilihan Zona Waktu
  Widget _buildTimezoneSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade300, width: 1.5), // Border warna tema cerah
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTimezoneKey,
          icon: const Icon(Icons.access_time, color: Colors.cyan), // Ikon warna aksen cerah
          hint: const Text("Pilih Zona Waktu"),
          items: _timezones.keys.map((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(_timezones[key]!['name']),
            );
          }).toList(),
          onChanged: _onTimezoneChange,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadTimezone, 
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARU: Pemilihan Zona Waktu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Zona Waktu:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue), // Warna biru cerah
                ),
                _buildTimezoneSelector(),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Tanggal penutupan di bawah ini disesuaikan dengan zona waktu yang Anda pilih.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            
            // LISTVIEW Donasi (Menggunakan Column untuk menampung daftar Card)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _donationOrganizations.map((org) {
                return _buildDonationCard(org);
              }).toList(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}