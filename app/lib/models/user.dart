/// Model representing a user
class User {
  final int? id;
  final String? username;
  final String? profileUrl;
  final String email;
  final String? bio;

  User(
      {this.id, this.bio, this.username, this.profileUrl, required this.email});
  User.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        username = map['username'],
        bio = map['bio'],
        email = map['email'],
        profileUrl = map['profileUrl'];
}
