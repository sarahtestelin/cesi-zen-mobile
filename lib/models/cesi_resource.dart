class CesiResource {
  final String id;
  final String title;
  final String description;
  final String category;
  final bool isActive;

  CesiResource({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isActive,
  });

  factory CesiResource.fromJson(Map<String, dynamic> json) {
    return CesiResource(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      isActive: json['ressourceIsActive'] == true,
    );
  }
}
