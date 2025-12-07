class Article {
  final String title;
  final String url;
  final String? description;
  final String? urlToImage;
  final String? content;

  Article({
    required this.title,
    required this.url,
    this.description,
    this.urlToImage,
    this.content,
  });

  static String? _cleanContent(dynamic rawContent) {
    if (rawContent == null) return null;
    String content = rawContent.toString();

    content = content.replaceAll(
      RegExp(r'\s*\[\+\d+\schars\]$'),
      '',
    );

    return content.trim();
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Title Not Available',
      url: json['url'] ?? '',
      description: json['description'],
      urlToImage: json['urlToImage'],
      content: _cleanContent(json['content']), 
    );
  }
}
