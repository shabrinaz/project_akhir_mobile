class User {
  int? id;
  final String username;
  final String password; // (boleh di-hash)
  int points;
  String? profileImagePath; // 🔹 path foto profil

  User({
    this.id,
    required this.username,
    required this.password,
    this.points = 0,
    this.profileImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'points': points,
      'profile_image_path': profileImagePath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      points: map['points'] ?? 0,
      profileImagePath: map['profile_image_path'],
    );
  }
}
