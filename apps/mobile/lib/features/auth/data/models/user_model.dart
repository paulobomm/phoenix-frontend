import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String plan;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.plan,
    required this.createdAt,
  });

  /// Decodifica o payload de um JWT do IAM (`{ sub, email, permissions }`)
  /// num [UserModel]. Retorna `null` se o token for inválido. Usado tanto no
  /// login quanto na restauração de sessão a partir do storage.
  static UserModel? fromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      final email = json['email'] as String? ?? '';
      return UserModel(
        id: json['sub'] as String? ?? '',
        name: email.contains('@') ? email.split('@').first : email,
        email: email,
        plan: 'free',
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      plan: json['plan'] as String? ?? 'free',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'plan': plan,
        'createdAt': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? plan,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
