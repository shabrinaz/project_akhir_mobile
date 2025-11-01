// lib/screens/lbs_screen.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LBSScreen extends StatefulWidget {
  const LBSScreen({Key? key}) : super(key: key);

  @override
  State<LBSScreen> createState() => _LBSScreenState();
}

class _LBSScreenState extends State<LBSScreen> {
  // Koordinat default di sekitar UPN Veteran Yogyakarta (Babarsari)
  static const LatLng _defaultCenter = LatLng(-7.7770, 110.4072);
  LatLng _currentPosition = _defaultCenter;
  bool _isLoading = true;
  String _locationStatus = 'Memuat lokasi...';

  // 1. Definisikan Lokasi Donasi beserta Nama
  final List<Map<String, dynamic>> _donationPoints = [
    {
      'name': 'Panti Asuhan Sinar Harapan',
      'latlng': const LatLng(-7.7730, 110.4000)
    }, // Barat Laut UPN
    {
      'name': 'Masjid Kampus Al-Akbar',
      'latlng': const LatLng(-7.7755, 110.4125)
    }, // Timur Laut UPN
    {
      'name': 'Posko PMI Babarsari',
      'latlng': const LatLng(-7.7810, 110.4100)
    }, // Tenggara UPN
    {
      'name': 'Gereja St. Antonius',
      'latlng': const LatLng(-7.7800, 110.4030)
    }, // Barat Daya UPN
  ];

  @override
  void initState() {
    super.initState();
    _fetchAndSetLocation();
  }

  // --- Fungsi Lokasi (Tidak Berubah) ---

  Future<void> _fetchAndSetLocation() async {
    // ... (Fungsi ini tidak berubah, hanya isinya yang dipersingkat)
    setState(() {
      _isLoading = true;
      _locationStatus = 'Memeriksa izin dan layanan lokasi...';
    });

    try {
      final position = await _determinePosition();

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _locationStatus =
            'Lokasi Saat Ini:\nLat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationStatus = 'ERROR: ${e.toString()}';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lokasi Gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Position> _determinePosition() async {
    // ... (Fungsi ini tidak berubah)
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        'Layanan lokasi dinonaktifkan. Mohon aktifkan GPS Anda.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak. Anda harus memberikan izin.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Izin lokasi ditolak permanen. Silakan ubah di Pengaturan.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // 2. Fungsi untuk menampilkan SnackBar
  void _showLocationPopup(String locationName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Lokasi Donasi: $locationName',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.pink.shade700,
      ),
    );
  }

  // --- UI/Tampilan (Tidak Berubah) ---
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bagian Peta
        Expanded(flex: 4, child: _buildMap()),

        // Bagian Status dan Tombol
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _locationStatus,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _locationStatus.startsWith('ERROR')
                        ? Colors.red
                        : Colors.blue, // Warna status sesuai tema
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _fetchAndSetLocation,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Memuat Peta...' : 'Perbarui Lokasi',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan, // Warna tombol aksen cerah
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)), // Bentuk kotak seragam
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget Peta
  Widget _buildMap() {
    // 3. Buat daftar marker donasi dengan GestureDetector
    final List<Marker> donationMarkers = _donationPoints.map((point) {
      final String name = point['name'];
      final LatLng latLng = point['latlng'];

      return Marker(
        width: 80.0,
        height: 80.0,
        point: latLng,
        // Gunakan GestureDetector untuk menangani tap/tekan
        child: GestureDetector(
          onTap: () => _showLocationPopup(name), // Panggil fungsi pop-up
          child: const Icon(
            Icons.pin_drop, // Ikon donasi
            color: Colors.pink, // Warna Marker yang berbeda untuk donasi
            size: 40.0,
          ),
        ),
      );
    }).toList();

    // Tambahkan marker posisi saat ini (tidak bisa ditekan)
    final List<Marker> allMarkers = [
      // Marker Posisi Saat Ini
      Marker(
        width: 80.0,
        height: 80.0,
        point: _currentPosition,
        child: const Icon(
          Icons.location_pin,
          color: Colors.cyan, // Marker Posisi Saat Ini (warna cyan)
          size: 40.0,
        ),
      ),
      // Tambahkan Marker Lokasi Donasi
      ...donationMarkers,
    ];

    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentPosition,
        initialZoom: 14.0,
      ),
      children: [
        // Tile Layer (Map Tiles dari OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.projectAkhirMobile',
        ),

        // MarkerLayer
        MarkerLayer(
          markers: allMarkers, // Gunakan daftar semua marker
        ),
      ],
    );
  }
}