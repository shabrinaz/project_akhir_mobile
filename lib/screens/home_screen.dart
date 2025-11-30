import 'package:flutter/material.dart';
import 'package:project_akhir_mobile/screens/article_detail_screen.dart';
import '../services/news_service.dart';
import '../models/article_model.dart';

/// 🎨 WARNA–WARNA CUSTOM (EDIT BAGIAN INI AJA)
const Color kHomeBackground = Color(0xFFF7F9FC);
const Color kSearchBorder = Color(0xFF007BFF);
const Color kSearchIcon = Color(0xFF007BFF);
const Color kSearchFill = Colors.white;

const Color kCardBorder = Color(0xFF007BFF);
const Color kCardShadow = Color(0x22007BFF);
const Color kCardBackground = Colors.white;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService _newsService = NewsService();
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _newsService.fetchNews("");
      setState(() {
        _allArticles = result;
        _filteredArticles = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e"), backgroundColor: Colors.red),
      );
    }
  }

  void _searchArticles() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredArticles = _allArticles;
      } else {
        _filteredArticles = _allArticles.where((a) {
          return a.title.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kHomeBackground,
      child: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _searchArticles(),
              decoration: InputDecoration(
                filled: true,
                fillColor: kSearchFill,
                hintText: "Cari artikel",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: kSearchIcon),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: kSearchIcon),
                  onPressed: () {
                    _searchController.clear();
                    _searchArticles();
                  },
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: kSearchBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: kSearchBorder, width: 2),
                ),
              ),
            ),
          ),

          // LIST ARTIKEL
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: kSearchBorder))
                : _filteredArticles.isEmpty
                    ? const Center(
                        child: Text(
                          "Tidak ada artikel ditemukan",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchNews,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filteredArticles.length,
                          itemBuilder: (context, index) {
                            return _buildArticleCard(_filteredArticles[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // CARD ARTIKEL
  Widget _buildArticleCard(Article article) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: kCardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kCardShadow,
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
          border: Border.all(color: kCardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: article.urlToImage != null
                  ? Image.network(
                      article.urlToImage!,
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 170,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text("No Image"),
                      ),
                    ),
            ),

            // JUDUL
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                article.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
