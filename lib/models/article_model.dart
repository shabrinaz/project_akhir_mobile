// lib/models/article_model.dart

class Article {
  // Properti wajib: Judul dan URL harus selalu ada untuk artikel yang valid
  final String title;
  final String url;

  // Properti nullable (opsional): Mungkin null dari respons API
  final String? description;
  final String? urlToImage;
  final String? content;

  // Constructor utama
  Article({
    required this.title,
    required this.url,
    this.description,
    this.urlToImage,
    this.content,
  });

  // Factory constructor untuk mengurai (parse) Map JSON menjadi objek Article
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      // Menggunakan operator ?? untuk nilai default jika data null
      title: json['title'] ?? 'Title Not Available',
      url: json['url'] ?? '', 
      
      description: json['description'], // Akan null jika di JSON null
      urlToImage: json['urlToImage'],
      content: json['content'],
    );
  }
}