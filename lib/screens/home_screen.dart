import 'package:flutter/material.dart';
import 'package:project_akhir_mobile/screens/article_detail_screen.dart'; 
import '../services/news_service.dart'; 
import '../models/article_model.dart'; 

class HomeScreen extends StatefulWidget {
  // ✅ Kunci Perbaikan: Konstruktor HANYA membutuhkan Key.
  // HomeScreen TIDAK memerlukan parameter apapun dari MainNavigationScreen.
  const HomeScreen({Key? key}) : super(key: key); 

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  final NewsService _newsService = NewsService(); 
  List<Article> _allArticles = []; 
  List<Article> _filteredArticles = []; 
  bool _isLoading = true;
  String _searchQuery = ''; 
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  // --- Fungsi Data dan Logika ---

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _allArticles = [];
      _filteredArticles = []; 
    });

    try {
      final List<Article> fetchedArticles = await _newsService.fetchNews(_searchQuery);
      
      setState(() {
        _allArticles = fetchedArticles;
        _applyTitleFilter(); 
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error fetching news in UI: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Gagal memuat data: ${e.toString()}');
    }
  }
  
  // FUNGSI FILTER JUDUL (Lokal)
  void _applyTitleFilter() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      _filteredArticles = _allArticles;
    } else {
      _filteredArticles = _allArticles.where((article) {
        return article.title.toLowerCase().contains(query);
      }).toList();
    }
    
    setState(() {});
  }

  void _performSearch() {
    _applyTitleFilter();
  }
  
  void _showErrorSnackbar(String message) {
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // --- UI/Tampilan ---

  @override
  Widget build(BuildContext context) {
    // 📌 Perhatian: Tidak ada Scaffold atau AppBar di sini, 
    // karena MainNavigationScreen sudah menyediakannya.
    
    return Column(
      children: <Widget>[
        // 1. Fitur Searching
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari donasi, bisnis, dunia...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _applyTitleFilter(); 
                },
              ),
            ),
            onChanged: (_) => _applyTitleFilter(), 
            onSubmitted: (_) => _applyTitleFilter(), 
          ),
        ),

        // 2. Tampilan List Artikel
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredArticles.isEmpty
                  ? Center(child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        _allArticles.isEmpty
                          ? "Tidak ada artikel yang lengkap ditemukan."
                          : "❌ Tidak ada artikel yang judulnya mengandung '${_searchController.text}'.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ))
                  : RefreshIndicator( 
                      onRefresh: _fetchNews, 
                      child: ListView.builder(
                        itemCount: _filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = _filteredArticles[index];
                          return _buildArticleCard(context, article);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // Widget Item List (Gambar Atas, Judul Bawah)
  Widget _buildArticleCard(BuildContext context, Article article) {
    final imageUrl = article.urlToImage;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article), 
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        elevation: 6, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Gambar Atas
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.blueGrey,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey))),
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(child: Text("Gambar Tidak Tersedia", style: TextStyle(color: Colors.grey)))),
            ),
            
            // Judul Bawah
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                article.title,
                maxLines: 3, 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}