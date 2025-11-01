// lib/screens/donation_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Definisi model sederhana untuk Organisasi Donasi
class DonationOrg {
  final String title;
  final String description;
  final DateTime deadlineUtc;
  final IconData icon;
  final Color color;

  DonationOrg({
    required this.title,
    required this.description,
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
      title: 'Unicef (Kesejahteraan Anak)',
      description: 'Membantu anak-anak yang membutuhkan di seluruh dunia.',
      deadlineUtc: DateTime.utc(2025, 11, 5, 15, 0, 0), // 5 Nov 2025, 15:00 UTC
      icon: Icons.child_care,
      color: Colors.blue,
    ),
    DonationOrg(
      title: 'Palestina (Bantuan Darurat)',
      description: 'Donasi untuk bantuan kemanusiaan darurat di Palestina.',
      deadlineUtc: DateTime.utc(2025, 11, 10, 12, 0, 0), // 10 Nov 2025, 12:00 UTC
      icon: Icons.flag,
      color: Colors.red,
    ),
    DonationOrg(
      title: 'Timur Tengah (Air & Sanitasi)',
      description: 'Penyediaan air bersih dan sanitasi di kawasan Timur Tengah.',
      deadlineUtc: DateTime.utc(2025, 11, 15, 8, 0, 0), // 15 Nov 2025, 08:00 UTC
      color: Colors.teal,
      icon: Icons.mosque,
    ),
    DonationOrg(
      title: 'Afrika (Lawan Kelaparan)',
      description: 'Program darurat untuk mengatasi krisis pangan di Afrika.',
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
    // Menggunakan kunci 'donation_timezone'
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zona waktu donasi diubah ke ${_timezones[newTimezoneKey]!['name']}')),
        );
      }
    }
  }


  // Mengubah waktu UTC ke waktu lokal yang dipilih pengguna
  String _formatDeadline(DateTime utcTime) {
    
    final tzData = _timezones[_selectedTimezoneKey] ?? _timezones['WIB']!;
    final offsetHours = tzData['offsetHours'] as int;
    final tzName = tzData['name'] as String;
    
    // Hitung waktu lokal yang diinginkan
    final localTime = utcTime.add(Duration(hours: offsetHours));
    
    // Format ke string yang rapi
    return '${DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id_ID').format(localTime)} $tzName';
  }

  // Widget untuk menampilkan Card Donasi
  Widget _buildDonationCard(DonationOrg org) {
    final deadlineString = _formatDeadline(org.deadlineUtc);
    final isClosed = org.deadlineUtc.isBefore(DateTime.now().toUtc());

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          color: isClosed ? Colors.grey[200] : org.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isClosed ? Colors.grey : org.color.withOpacity(0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(org.icon, size: 30, color: org.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      org.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: org.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                org.description,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Bagian Status Donasi
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 10),
                  Text(
                    'Ditutup: ',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  Text(
                    isClosed ? 'DONASI SUDAH DITUTUP' : deadlineString,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isClosed ? Colors.red : org.color, 
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget untuk Pemilihan Zona Waktu (BARU DI SINI)
  Widget _buildTimezoneSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTimezoneKey,
          icon: const Icon(Icons.access_time, color: Colors.blueAccent),
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
            // BARU: Pemilihan Zona Waktu di atas Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Zona Waktu:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
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
            
            // GridView Donasi
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.85, 
              ),
              itemCount: _donationOrganizations.length,
              itemBuilder: (context, index) {
                return _buildDonationCard(_donationOrganizations[index]);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}