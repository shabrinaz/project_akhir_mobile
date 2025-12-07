import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const Color kLbsBackground = Color(0xFFF7F9FC);        
const Color kLbsCardBg = Colors.white;                 
const Color kLbsCardBorder = Color(0xFF007BFF);        
const Color kLbsCardShadow = Color(0x22007BFF);        

const Color kLbsStatusTextColor = Color(0xFF007BFF);   
const Color kLbsStatusErrorColor = Colors.red;        

const Color kLbsButtonColor = Color(0xFF007BFF);       
const Color kLbsButtonTextColor = Colors.white;        

const Color kLbsUserMarkerColor = Colors.cyan;         

class LBSScreen extends StatefulWidget {
  const LBSScreen({Key? key}) : super(key: key);

  @override
  State<LBSScreen> createState() => _LBSScreenState();
}

class _LBSScreenState extends State<LBSScreen> {
  static const LatLng _defaultCenter = LatLng(-7.7770, 110.4072);
  LatLng _currentPosition = _defaultCenter;
  bool _isLoading = true;
  String _locationStatus = 'Memuat lokasi...';

  @override
  void initState() {
    super.initState();
    _fetchAndSetLocation();
  }

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
            'Lokasi Saat Ini:\nLat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
        return Future.error(
          'Izin lokasi ditolak. Anda harus memberikan izin.',
        );
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLbsBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: kLbsCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kLbsCardBorder, width: 1.6),
                  boxShadow: [
                    BoxShadow(
                      color: kLbsCardShadow,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildMap(),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              _locationStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _locationStatus.startsWith('ERROR')
                    ? kLbsStatusErrorColor
                    : kLbsStatusTextColor,
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchAndSetLocation,
                icon: const Icon(Icons.my_location),
                label: Text(
                  _isLoading ? 'Memuat Peta...' : 'Perbarui Lokasi',
                  style: TextStyle(
                    fontSize: 16,
                    color: kLbsButtonTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kLbsButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    final Marker userMarker = Marker(
      width: 80.0,
      height: 80.0,
      point: _currentPosition,
      child: Icon(
        Icons.location_pin,
        color: kLbsUserMarkerColor,
        size: 40.0,
      ),
    );

    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentPosition,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.projectAkhirMobile',
        ),
        MarkerLayer(
          markers: [userMarker],
        ),
      ],
    );
  }
}
