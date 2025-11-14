class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
    required this.role,
    required this.zone,
  });

  final String id;
  final String fullName;
  final String email;
  final String username;
  final String role;
  final String zone;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      zone: json['zone'] ?? '',
    );
  }
}
