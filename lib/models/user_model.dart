// lib/models/user_model.dart

class User {
  int? id;
  final String username;
  final String password; // Akan di-hash
  int points;

  User({
    this.id,
    required this.username,
    required this.password,
    this.points = 0,
  });

  // Konversi objek User menjadi Map (untuk disimpan di DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'points': points,
    };
  }

  // Konversi Map (dari DB) menjadi objek User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      points: map['points'] ?? 0,
    );
  }
}