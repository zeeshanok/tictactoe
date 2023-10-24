/// Model representing a user
class User {
  final int id;
  final String? username;
  final String? profileUrl;
  final String email;
  final String? bio;

  User({
    this.bio,
    this.username,
    this.profileUrl,
    required this.id,
    required this.email,
  });

  User.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        username = map['username'],
        bio = map['bio'],
        email = map['email'],
        profileUrl = map['profileUrl'];

  @override
  bool operator ==(covariant User other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}
