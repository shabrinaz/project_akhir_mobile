import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart'; 

class NewsService {
  final String _apiKey = '0be632134bee42d8bbf876c1fd9a795c';
  final String _baseUrl = 'https://newsapi.org/v2/everything';
  final int _minContentLength = 100; // Konten minimal 100 karakte
  final int _maxArticlesToReturn = 15; // Jumlah artikel 
  
  final String _defaultQuery = "donation OR charity OR global affairs OR business"; 

  // Fungsi memfilter list artikel
  Future<List<Article>> fetchNews(String query) async {
    final apiQuery = query.isEmpty ? _defaultQuery : query;

    final url = Uri.parse(
        '$_baseUrl?q=$apiQuery&language=en&pageSize=40&sortBy=publishedAt&apiKey=$_apiKey'); 

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok' && data['articles'] != null) {
          List<Article> allArticles = [];
          for (var articleJson in data['articles']) {
            if (articleJson['url'] != null && articleJson['title'] != null && articleJson['urlToImage'] != null) {
              allArticles.add(Article.fromJson(articleJson));
            }
          }
          
          List<Article> filteredArticles = allArticles.where((article) {
            final content = article.content ?? '';
            return content.length > _minContentLength && !content.contains('...[');
          }).toList();
          return filteredArticles.take(_maxArticlesToReturn).toList();
        } else {
          throw Exception('Data tidak tersedia atau status API tidak valid. Coba ganti keyword.');
        }
      } else {
        throw Exception('Gagal memuat berita. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server atau terjadi kesalahan: ${e.toString()}');
    }
  }
}