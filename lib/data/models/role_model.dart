import 'package:flow/data/models/user_models.dart';

class BoardMember {
  final AppUser user;
  final String role; // Например: 'admin', 'editor', 'viewer'

  BoardMember({required this.user, required this.role});
}
