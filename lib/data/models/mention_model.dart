class Mention {
  final String userId;
  final String displayName;

  Mention({required this.userId, required this.displayName});

  // For serialization/deserialization to/from Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
    };
  }

  factory Mention.fromMap(Map<String, dynamic> map) {
    return Mention(
      userId: map['userId'],
      displayName: map['displayName'],
    );
  }
}