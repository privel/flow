
class AppUser {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String messageToken;

  AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.messageToken,
    this.photoUrl,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      messageToken: map['messageToken'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }
}
