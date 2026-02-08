/**
 * USER MODEL
 *
 * This class represents a user in our app.
 * It's used to store user data after login/register.
 *
 * The fromJson factory constructor converts JSON from the API
 * into a User object.
 */

class User {
  final int id;
  final String username;
  final String createdAt;

  User({
    required this.id,
    required this.username,
    required this.createdAt,
  });

  /**
   * Create a User object from JSON data
   *
   * Example JSON from API:
   * {
   *   "id": 1,
   *   "username": "john",
   *   "created_at": "2024-01-15T10:30:00.000Z"
   * }
   */
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      createdAt: json['created_at'],
    );
  }

  /**
   * Convert User object to JSON
   * (Useful if we need to send user data to the API)
   */
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'created_at': createdAt,
    };
  }
}
