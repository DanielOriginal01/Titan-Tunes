enum UserRole { auditeur, artiste, admin }

class User {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String avatarUrl;
  final bool lowDataMode;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.avatarUrl,
    this.lowDataMode = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final roleValue = (json['role'] as String?)?.toLowerCase();
    return User(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == roleValue,
        orElse: () => UserRole.auditeur,
      ),
      avatarUrl: json['avatarUrl'] as String? ?? '',
      lowDataMode: json['lowDataMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'lowDataMode': lowDataMode,
    };
  }
}
