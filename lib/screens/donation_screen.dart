import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎨 WARNA — EDIT BAGIAN INI AJA ✔
const Color kDonationBackground = Color(0xFFF4F8FF); // Background halaman
const Color kTimezoneBorder = Color(0xFF007BFF); // Border dropdown
const Color kTimezoneIcon = Color(0xFF007BFF); // Icon jam
const Color kTimezoneText = Color(0xFF003B88); // Text zona waktu

/// 🎨 Warna card tiap organisasi (ubah sesuka hati)
const Color kUnicefColor = Color(0xFF2E89FF);
const Color kPalestinaColor = Color(0xFFE53935);
const Color kTimurTengahColor = Color(0xFF00897B);
const Color kAfrikaColor = Color(0xFF43A047);

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
  // 🔵 DATA ORGANISASI — sudah 2026 ✔
  final List<DonationOrg> _donationOrganizations = [
    DonationOrg(
      title: 'Unicef',
      deadlineUtc: DateTime.utc(2026, 3, 5, 15, 0, 0),
      icon: Icons.child_care,
      color: kUnicefColor,
    ),
    DonationOrg(
      title: 'Palestina',
      deadlineUtc: DateTime.utc(2026, 3, 10, 12, 0, 0),
      icon: Icons.flag,
      color: kPalestinaColor,
    ),
    DonationOrg(
      title: 'Timur Tengah',
      deadlineUtc: DateTime.utc(2026, 3, 15, 8, 0, 0),
      icon: Icons.mosque,
      color: kTimurTengahColor,
    ),
    DonationOrg(
      title: 'Afrika',
      deadlineUtc: DateTime.utc(2026, 3, 20, 20, 0, 0),
      icon: Icons.public,
      color: kAfrikaColor,
    ),
  ];

  String _selectedTimezoneKey = 'WIB';

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

  Future<void> _loadTimezone() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('donation_timezone') ?? 'WIB';
    setState(() {
      _selectedTimezoneKey =
          _timezones.containsKey(saved) ? saved : 'WIB';
    });
  }

  void _onTimezoneChange(String? newKey) async {
    if (newKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('donation_timezone', newKey);

    setState(() => _selectedTimezoneKey = newKey);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Zona waktu diubah ke ${_timezones[newKey]!['name']}",
        ),
      ),
    );
  }

  // Convert UTC → timezone terpilih
  String _formatDeadline(DateTime utc) {
    final tz = _timezones[_selectedTimezoneKey] ?? _timezones['WIB']!;
    final local = utc.add(Duration(hours: tz['offsetHours']));

    return "${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(local)}|"
        "${DateFormat('HH:mm', 'id_ID').format(local)}|"
        "${tz['name']}";
  }

  // CARD ORGANISASI
  Widget _buildDonationCard(DonationOrg org) {
    final parts = _formatDeadline(org.deadlineUtc).split('|');
    final date = parts[0];
    final time = "${parts[1]} ${parts[2]}";

    final bool isClosed = org.deadlineUtc.isBefore(DateTime.now().toUtc());

    final Color baseColor = org.color;
    final Color titleColor = baseColor;
    final Color dateColor =
        isClosed ? Colors.red : baseColor.withOpacity(0.9);
    final Color timeColor = baseColor.withOpacity(0.8);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: baseColor, width: 2),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(org.icon, size: 40, color: baseColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul organisasi
                  Text(
                    org.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Teks "Ditutup" atau tanggal
                  Text(
                    isClosed ? "DONASI SUDAH DITUTUP" : date,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: dateColor,
                    ),
                  ),

                  // Jam + zona waktu hanya kalau belum tutup
                  if (!isClosed)
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: timeColor,
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

  // DROPDOWN ZONA WAKTU
  Widget _buildTimezoneSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kTimezoneBorder, width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTimezoneKey,
          icon: Icon(Icons.access_time, color: kTimezoneIcon),
          items: _timezones.keys.map((String key) {
            return DropdownMenuItem(
              value: key,
              child: Text(
                _timezones[key]!['name'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: _onTimezoneChange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDonationBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE + SELECTOR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Zona Waktu:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTimezoneText,
                  ),
                ),
                _buildTimezoneSelector(),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              "Tanggal penutupan disesuaikan dengan zona waktu yang Anda pilih.",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),

            const SizedBox(height: 24),

            // LIST ORGANISASI
            Column(
              children: _donationOrganizations
                  .map((org) => _buildDonationCard(org))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
