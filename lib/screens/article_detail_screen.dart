// lib/screens/article_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk simulasi DB/Poin
import 'package:url_launcher/url_launcher.dart';             // Untuk membuka URL
import '../models/article_model.dart';
import 'package:intl/intl.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart'; // Sudah ada di atas, tapi tidak apa-apa

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  // Controller untuk mendeteksi posisi scroll
  late ScrollController _scrollController;
  // Status apakah poin sudah diberikan untuk artikel ini
  bool _pointsAwarded = false; 

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Tambahkan listener untuk mendeteksi scroll
    _scrollController.addListener(_scrollListener);
    // Cek status poin saat inisialisasi
    _checkInitialPointsStatus();
  }

  @override
  void dispose() {
    // 🚩 PERBAIKAN BUG DISINI: Mengganti listener yang salah menjadi _scrollListener
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  // Fungsi untuk memuat status poin saat widget dimuat
  Future<void> _checkInitialPointsStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String articleId = widget.article.url;
    
    // Perbarui state jika poin untuk artikel ini sudah diberikan sebelumnya
    if (prefs.getBool('awarded_$articleId') == true) {
      setState(() {
        _pointsAwarded = true;
      });
    }
  }

  // LOGIKA DETEKSI SCROLL HINGGA BAWAH (Menggunakan hasClients)
  void _scrollListener() {
    // GUARD CLAUSE: Pastikan controller sudah terpasang sebelum mengakses .position
    if (!_scrollController.hasClients) {
      return;
    }
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    // Asumsi: Mencapai 95% dari total scroll sudah cukup untuk memberikan poin
    if (currentScroll >= maxScroll * 0.95) {
      if (!_pointsAwarded) {
        _awardUserPoints();
      }
    }
  }

  // LOGIKA PENAMBAHAN POIN (Simulasi Penyimpanan DB)
  Future<void> _awardUserPoints() async {
    // Cek ganda di awal fungsi (lebih aman)
    if (_pointsAwarded) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String articleId = widget.article.url; 
    final int pointsToAdd = 10; 
    
    // Cek apakah poin untuk artikel ini sudah pernah diberikan
    if (prefs.getBool('awarded_$articleId') == true) {
       setState(() { _pointsAwarded = true; }); // Perbarui state jika ternyata sudah
      return;
    }
    
    int currentTotalPoints = prefs.getInt('user_total_points') ?? 0;
    
    // 1. Simpan total poin baru
    await prefs.setInt('user_total_points', currentTotalPoints + pointsToAdd);
    // 2. Tandai artikel ini sudah diberi poin
    await prefs.setBool('awarded_$articleId', true);

    setState(() {
      _pointsAwarded = true; // Set status agar poin tidak ditambah ganda
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('脂 Berhasil! Anda mendapatkan $pointsToAdd poin! Total poin Anda: ${currentTotalPoints + pointsToAdd}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // FUNGSI MEMBUKA URL ASLI (Menggunakan url_launcher)
  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(widget.article.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka URL. Pastikan URL valid.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk memformat tanggal
  String _formatDate(DateTime? date) {
    if (date == null) return 'Tanggal tidak diketahui';
    // Format ke waktu lokal Indonesia
    return DateFormat('EEEE, dd MMMM yyyy, HH:mm').format(date.toLocal()); 
  }

  // Menggabungkan deskripsi dan konten
  String _getFullContent(String? description, String? content) {
    String finalContent = description ?? '';
    
    if (content != null && content.isNotEmpty) {
      if (finalContent.isNotEmpty) {
        finalContent += '\n\n'; 
      }
      finalContent += content;
    }

    if (finalContent.isEmpty) {
      return "Maaf, konten artikel penuh tidak tersedia.";
    }
    
    return finalContent;
  }

  @override
  Widget build(BuildContext context) {
    final String fullTextContent = _getFullContent(widget.article.description, widget.article.content);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Artikel", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true, 
      
      // Menggunakan ScrollController untuk mendeteksi scroll
      body: SingleChildScrollView(
        controller: _scrollController, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildArticleImage(context),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Judul
                  Text(
                    widget.article.title,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.2, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),

                  const Divider(height: 30, thickness: 1.5, color: Colors.blue), // Warna Divider tema cerah

                  // Konten Artikel Penuh
                  Text(
                    fullTextContent,
                    style: const TextStyle(fontSize: 17, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  
                  const SizedBox(height: 25),

                  // Kotak Poin (Indikator)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // Warna latar belakang disesuaikan dengan status/tema
                      color: _pointsAwarded ? Colors.green.withOpacity(0.1) : Colors.blue.shade50.withOpacity(0.5),
                      // Border disesuaikan dengan status/tema
                      border: Border.all(color: _pointsAwarded ? Colors.green : Colors.blue, width: 1.5), 
                      borderRadius: BorderRadius.circular(10), // Bentuk kotak seragam
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ikon disesuaikan dengan status/tema
                        Icon(_pointsAwarded ? Icons.check_circle : Icons.warning, color: _pointsAwarded ? Colors.green : Colors.cyan, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _pointsAwarded
                                ? "Poin sudah ditambahkan! Anda sudah menyelesaikan artikel ini."
                                : "Gulir hingga akhir artikel untuk mendapatkan poin!",
                            // Warna teks disesuaikan dengan status/tema
                            style: TextStyle(color: _pointsAwarded ? Colors.green : Colors.blueGrey, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // Tombol Lihat Sumber Asli (Aktif)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _launchUrl, // Panggil fungsi peluncur URL
                      icon: const Icon(Icons.public, color: Colors.white),
                      label: const Text(
                        'Lihat Sumber Asli Artikel',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan, // Warna tombol aksen cerah
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Bentuk kotak seragam
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Tambahkan ruang ekstra di bawah untuk memastikan scroll mencapai akhir
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget terpisah untuk gambar
  Widget _buildArticleImage(BuildContext context) {
    final imageUrl = widget.article.urlToImage;
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey)),
              ),
            )
          else
            Container(color: Colors.grey[200], child: const Center(child: Text("No Image"))),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}