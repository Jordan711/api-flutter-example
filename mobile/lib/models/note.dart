/**
 * NOTE MODEL
 *
 * This class represents a note in our app.
 * It matches the structure of notes in the backend database.
 *
 * The fromJson and toJson methods convert between JSON and Dart objects,
 * making it easy to work with API responses.
 */

class Note {
  final int? id; // Nullable because new notes don't have an ID yet
  final int userId;
  final String title;
  final String content;
  final String tags;
  final String? createdAt; // Nullable because new notes don't have timestamps yet
  final String? updatedAt;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.tags,
    this.createdAt,
    this.updatedAt,
  });

  /**
   * Create a Note object from JSON data
   *
   * Example JSON from API:
   * {
   *   "id": 1,
   *   "user_id": 1,
   *   "title": "Shopping List",
   *   "content": "Buy milk, eggs",
   *   "tags": "personal, shopping",
   *   "created_at": "2024-01-15T10:30:00.000Z",
   *   "updated_at": "2024-01-15T10:30:00.000Z"
   * }
   */
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      tags: json['tags'] ?? '', // Default to empty string if null
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  /**
   * Convert Note object to JSON
   * Used when creating or updating notes
   */
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
    };
  }

  /**
   * Create a copy of this note with some fields changed
   * Useful for updating notes immutably
   */
  Note copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? tags,
    String? createdAt,
    String? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /**
   * Get tags as a list
   * Splits the comma-separated tags string into a list
   */
  List<String> getTagsList() {
    if (tags.isEmpty) return [];
    return tags.split(',').map((tag) => tag.trim()).toList();
  }
}
