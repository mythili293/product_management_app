class AppUser {
  final String userId;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      userId: data['id']?.toString() ?? data['userId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'user',
      createdAt:
          DateTime.tryParse(data['created_at']?.toString() ?? '')?.toLocal() ??
              DateTime.tryParse(data['createdAt']?.toString() ?? '')
                  ?.toLocal() ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
