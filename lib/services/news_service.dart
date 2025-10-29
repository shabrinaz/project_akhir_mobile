// lib/services/news_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart'; // Pastikan path ini benar

class NewsService {
  final String _apiKey = '0be632134bee42d8bbf876c1fd9a795c';
  final String _baseUrl = 'https://newsapi.org/v2/everything';
  final int _minContentLength = 100; // Kriteria: Konten minimal 100 karakter untuk dianggap 'lengkap'
  final int _maxArticlesToReturn = 15; // Jumlah artikel yang diminta di Home Screen
  
  // Keyword gabungan yang Anda minta
  final String _defaultQuery = "donation OR charity OR global affairs OR business"; 

  // Fungsi yang bertugas mengambil dan memfilter list artikel
  Future<List<Article>> fetchNews(String query) async {
    // Gunakan query dari TextField, jika kosong, gunakan query gabungan default
    final apiQuery = query.isEmpty ? _defaultQuery : query;

    // Tambahkan parameter bahasa (en) dan minta lebih banyak artikel (pageSize=40) 
    // untuk memberi ruang bagi proses filtering
    final url = Uri.parse(
        '$_baseUrl?q=$apiQuery&language=en&pageSize=40&sortBy=publishedAt&apiKey=$_apiKey'); 

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'ok' && data['articles'] != null) {
          
          List<Article> allArticles = [];
          
          // 1. Parse semua artikel yang valid (memiliki judul, url, dan gambar)
          for (var articleJson in data['articles']) {
            if (articleJson['url'] != null && articleJson['title'] != null && articleJson['urlToImage'] != null) {
              allArticles.add(Article.fromJson(articleJson));
            }
          }
          
          // 2. LOGIKA PENYARINGAN ARTIKEL LENGKAP
          List<Article> filteredArticles = allArticles.where((article) {
            final content = article.content ?? '';
            
            // Filter: Konten harus lebih panjang dari batas minimum DAN tidak boleh terpotong 
            // (tanda terpotong khas NewsAPI adalah '...[' di akhir)
            return content.length > _minContentLength && !content.contains('...[');
            
          }).toList();

          // 3. Kembalikan hanya sejumlah maksimum artikel yang diminta (15 artikel)
          return filteredArticles.take(_maxArticlesToReturn).toList();
        
        } else {
          throw Exception('Data tidak tersedia atau status API tidak valid. Coba ganti keyword.');
        }
      } else {
        throw Exception('Gagal memuat berita. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Menangkap error jaringan atau parsing
      throw Exception('Gagal terhubung ke server atau terjadi kesalahan: ${e.toString()}');
    }
  }
}