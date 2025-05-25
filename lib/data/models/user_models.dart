class AppUser {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }
}
