class Note {
  final String id;
  final String title;
  final String description;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });
}
