import 'tag.dart';

class Todo {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final bool isCompleted;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.isCompleted,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      tags: [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userId: json['user_id'] as String,
      isCompleted: json['is_completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'is_completed': isCompleted,
    };
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<Tag>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isCompleted,
    bool clearImageUrl = false,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, description: $description, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, isCompleted: $isCompleted)';
  }
}
