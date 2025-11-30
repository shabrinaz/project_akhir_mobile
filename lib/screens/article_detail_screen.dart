import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

// DB & session
import '../helpers/session_manager.dart';
import '../helpers/db_helper.dart';
import '../models/user_model.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _pointsAwarded = false;

  bool _isFavorite = false;
  static const String _favoritePrefix = 'is_favorite_';

  final SessionManager _sessionManager = SessionManager();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _checkInitialPointsStatus();
    _checkInitialFavoriteStatus();
  }

  Future<void> _checkInitialPointsStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = await _sessionManager.getUserId();
    final String userKey = userId?.toString() ?? 'guest';
    final String articleId = widget.article.url;

    // flag-nya sekarang per user + per artikel
    final flagKey = 'awarded_${userKey}_$articleId';

    if (prefs.getBool(flagKey) == true) {
      setState(() {
        _pointsAwarded = true;
      });
    }
  }

  Future<void> _checkInitialFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String favoriteKey = '$_favoritePrefix${widget.article.url}';

    if (prefs.getBool(favoriteKey) == true) {
      setState(() {
        _isFavorite = true;
      });
    }
  }

  Future<void> _showFavoriteNotification(bool isFavorite) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'favorite_channel_id',
      'Notifikasi Favorit Artikel',
      channelDescription:
          'Memberikan notifikasi saat artikel ditambahkan/dihapus dari favorit.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'favorite_ticker',
      color: Colors.blue,
    );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
    );

    final String title =
        isFavorite ? "Artikel Difavoritkan!" : "Favorit Dihapus.";
    final String articleTitleSnippet = widget.article.title.length > 30
        ? '${widget.article.title.substring(0, 30)}...'
        : widget.article.title;

    final String body = isFavorite
        ? "Artikel '$articleTitleSnippet' telah ditambahkan ke favorit."
        : "Artikel '$articleTitleSnippet' telah dihapus dari daftar favorit.";

    await flutterLocalNotificationsPlugin.show(
      widget.article.url.hashCode.abs(),
      title,
      body,
      platformChannelSpecifics,
      payload: widget.article.url,
    );
  }

  void _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final String favoriteKey = '$_favoritePrefix${widget.article.url}';

    setState(() {
      _isFavorite = !_isFavorite;
    });

    await prefs.setBool(favoriteKey, _isFavorite);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showFavoriteNotification(_isFavorite);
    }
  }

  /// Kasih poin:
  /// - flag per user + per artikel di SharedPreferences
  /// - poin disimpan di kolom `points` user di database
  Future<void> _awardUserPoints() async {
    if (_pointsAwarded) return;

    final prefs = await SharedPreferences.getInstance();
    final int? userId = await _sessionManager.getUserId();
    final String userKey = userId?.toString() ?? 'guest';
    final String articleId = widget.article.url;
    const int pointsToAdd = 10;

    final String flagKey = 'awarded_${userKey}_$articleId';

    // kalau user ini sudah pernah dapat poin dari artikel ini
    if (prefs.getBool(flagKey) == true) {
      setState(() {
        _pointsAwarded = true;
      });
      return;
    }

    int newTotalPoints = pointsToAdd;

    if (userId != null) {
      // update di DB
      User? user = await _dbHelper.getUserById(userId);
      if (user != null) {
        user.points += pointsToAdd;
        newTotalPoints = user.points;
        await _dbHelper.updateUser(user);
      }
    }

    // simpan flag di prefs supaya user ini nggak dapat poin dobel untuk artikel yang sama
    await prefs.setBool(flagKey, true);

    setState(() {
      _pointsAwarded = true;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Anda mendapatkan $pointsToAdd poin! Total poin Anda: $newTotalPoints',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Poin dikasih kalau URL berhasil dibuka
  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(widget.article.url);

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka URL. Pastikan URL valid.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _awardUserPoints();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat membuka URL.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
    final String fullTextContent =
        _getFullContent(widget.article.description, widget.article.content);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Detail Artikel", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildArticleImage(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    height: 30,
                    thickness: 1.5,
                    color: Colors.blue,
                  ),
                  Text(
                    fullTextContent,
                    style: const TextStyle(fontSize: 17, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _pointsAwarded
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.shade50.withOpacity(0.5),
                      border: Border.all(
                        color: _pointsAwarded ? Colors.green : Colors.blue,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _pointsAwarded
                              ? Icons.check_circle
                              : Icons.warning,
                          color:
                              _pointsAwarded ? Colors.green : Colors.cyan,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _pointsAwarded
                                ? "Poin sudah ditambahkan karena kamu membuka sumber artikel."
                                : "Klik tombol 'Lihat Artikel Selengkapnya' untuk mendapatkan poin!",
                            style: TextStyle(
                              color: _pointsAwarded
                                  ? Colors.green
                                  : Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _launchUrl,
                      icon: const Icon(Icons.public, color: Colors.white),
                      label: const Text(
                        'Lihat Artikel Selengkapnya',
                        style:
                            TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                child: const Center(
                  child: Icon(Icons.broken_image,
                      size: 80, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              color: Colors.grey[200],
              child: const Center(child: Text("No Image")),
            ),
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
