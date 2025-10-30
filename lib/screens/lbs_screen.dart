// lib/screens/lbs_screen.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart'; // Import Flutter Map
import 'package:latlong2/latlong.dart'; // Import LatLng

class LBSScreen extends StatefulWidget {
  const LBSScreen({Key? key}) : super(key: key);

  @override
  State<LBSScreen> createState() => _LBSScreenState();
}

class _LBSScreenState extends State<LBSScreen> {
  // Koordinat default (misal: Jakarta, Indonesia)
  static const LatLng _defaultCenter = LatLng(-7.8004, 110.3912);
  LatLng _currentPosition = _defaultCenter;
  bool _isLoading = true;
  String _locationStatus = 'Memuat lokasi...';

  @override
  void initState() {
    super.initState();
    _fetchAndSetLocation();
  }

  // --- Fungsi Lokasi ---
  Future<void> _fetchAndSetLocation() async {
    setState(() {
      _isLoading = true;
      _locationStatus = 'Memeriksa izin dan layanan lokasi...';
    });

    try {
      final position = await _determinePosition();

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _locationStatus =
            '\nLat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
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

  // --- UI/Tampilan ---
  @override
  Widget build(BuildContext context) {
    // Perhatikan: AppBar sudah dihandle oleh MainNavigationScreen
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
                        : Colors.blueGrey,
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
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
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
    return FlutterMap(
      options: MapOptions(
        // Center Map pada lokasi yang sudah didapat atau default
        initialCenter: _currentPosition,
        initialZoom: 15.0, // Zoom yang cukup dekat
      ),
      children: [
        // Tile Layer (Map Tiles dari OpenStreetMap)
        TileLayer(
          // URL template OpenStreetMap (Gratis)
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.projectAkhirMobile', // Wajib ada
        ),

        // Marker untuk Posisi Saat Ini
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: _currentPosition,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
