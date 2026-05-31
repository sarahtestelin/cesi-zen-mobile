class AppUser {
  final String id;
  final String mail;
  final String pseudo;
  final bool active;
  final String role;

  AppUser({
    required this.id,
    required this.mail,
    required this.pseudo,
    required this.active,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      mail: json['mail']?.toString() ?? '',
      pseudo: json['pseudo']?.toString() ?? '',
      active: json['appUserIsActive'] == true,
      role: json['role']?.toString() ?? '',
    );
  }
}
