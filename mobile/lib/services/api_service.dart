/**
 * API SERVICE
 *
 * This class handles all communication with the backend server.
 * It contains methods for:
 * - Authentication (register, login)
 * - Notes CRUD operations (create, read, update, delete)
 *
 * It uses the http package to make HTTP requests.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/note.dart';

class ApiService {
  // Base URL for the API - will be set by user in the app
  String? _baseUrl;

  // JWT token for authenticated requests
  String? _token;

  /**
   * Set the base URL (e.g., "http://192.168.1.100:3000")
   * This is saved to SharedPreferences so it persists
   */
  Future<void> setBaseUrl(String url) async {
    // Remove trailing slash if present
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_url', _baseUrl!);
  }

  /**
   * Load the base URL from SharedPreferences
   */
  Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('base_url');
  }

  /**
   * Get the current base URL
   */
  String? get baseUrl => _baseUrl;

  /**
   * Set the auth token
   * This is saved to SharedPreferences so user stays logged in
   */
  Future<void> setToken(String token) async {
    _token = token;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /**
   * Load the token from SharedPreferences
   */
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  /**
   * Clear the token (for logout)
   */
  Future<void> clearToken() async {
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /**
   * Check if user is logged in
   */
  bool get isLoggedIn => _token != null;

  /**
   * Get auth headers for authenticated requests
   */
  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  /**
   * Get regular headers (no auth)
   */
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  /**
   * AUTHENTICATION METHODS
   */

  /**
   * Register a new user
   *
   * @param username - The username
   * @param password - The password
   * @returns Map with 'user' and 'token' keys, or throws error
   */
  Future<Map<String, dynamic>> register(String username, String password) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set. Please configure the server address.');
    }

    final url = Uri.parse('$_baseUrl/api/register');
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: _headers, body: body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Success - save token and return user
        await setToken(data['token']);
        return {
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        // Error from server
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      // Network or parsing error
      throw Exception('Network error: $e');
    }
  }

  /**
   * Login with existing account
   *
   * @param username - The username
   * @param password - The password
   * @returns Map with 'user' and 'token' keys, or throws error
   */
  Future<Map<String, dynamic>> login(String username, String password) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set. Please configure the server address.');
    }

    final url = Uri.parse('$_baseUrl/api/login');
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: _headers, body: body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success - save token and return user
        await setToken(data['token']);
        return {
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        // Error from server
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      // Network or parsing error
      throw Exception('Network error: $e');
    }
  }

  /**
   * Logout
   * Simply clears the token
   */
  Future<void> logout() async {
    await clearToken();
  }

  /**
   * NOTES METHODS
   */

  /**
   * Get all notes for the logged-in user
   *
   * @returns List of Note objects
   */
  Future<List<Note>> getNotes() async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set');
    }
    if (_token == null) {
      throw Exception('Not logged in');
    }

    final url = Uri.parse('$_baseUrl/api/notes');

    try {
      final response = await http.get(url, headers: _authHeaders);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success - parse and return notes
        final List<dynamic> notesJson = data['notes'];
        return notesJson.map((json) => Note.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token expired or invalid
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception(data['error'] ?? 'Failed to load notes');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /**
   * Create a new note
   *
   * @param note - The Note object to create (id can be null)
   * @returns The created Note object with ID
   */
  Future<Note> createNote(Note note) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set');
    }
    if (_token == null) {
      throw Exception('Not logged in');
    }

    final url = Uri.parse('$_baseUrl/api/notes');
    final body = jsonEncode(note.toJson());

    try {
      final response = await http.post(url, headers: _authHeaders, body: body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Success - return the created note
        return Note.fromJson(data['note']);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception(data['error'] ?? 'Failed to create note');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /**
   * Update an existing note
   *
   * @param note - The Note object with updated data
   * @returns The updated Note object
   */
  Future<Note> updateNote(Note note) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set');
    }
    if (_token == null) {
      throw Exception('Not logged in');
    }
    if (note.id == null) {
      throw Exception('Note ID is required for update');
    }

    final url = Uri.parse('$_baseUrl/api/notes/${note.id}');
    final body = jsonEncode(note.toJson());

    try {
      final response = await http.put(url, headers: _authHeaders, body: body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success - return the updated note
        return Note.fromJson(data['note']);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Note not found');
      } else {
        throw Exception(data['error'] ?? 'Failed to update note');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /**
   * Delete a note
   *
   * @param noteId - The ID of the note to delete
   */
  Future<void> deleteNote(int noteId) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set');
    }
    if (_token == null) {
      throw Exception('Not logged in');
    }

    final url = Uri.parse('$_baseUrl/api/notes/$noteId');

    try {
      final response = await http.delete(url, headers: _authHeaders);

      if (response.statusCode == 200) {
        // Success
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Note not found');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to delete note');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /**
   * USER ACCOUNT METHODS
   */

  /**
   * Change password
   *
   * @param oldPassword - Current password
   * @param newPassword - New password
   */
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set');
    }
    if (_token == null) {
      throw Exception('Not logged in');
    }

    final url = Uri.parse('$_baseUrl/api/user/password');
    final body = jsonEncode({
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });

    try {
      final response = await http.put(url, headers: _authHeaders, body: body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success
        return;
      } else if (response.statusCode == 401) {
        throw Exception(data['error'] ?? 'Current password is incorrect');
      } else if (response.statusCode == 400) {
        throw Exception(data['error'] ?? 'Invalid password');
      } else if (response.statusCode == 403) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception(data['error'] ?? 'Failed to change password');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /**
   * Delete user account
   *
   * @param password - Password for verification
   */
  Future<void> deleteAccount(String password) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set');
    }
    if (_token == null) {
      throw Exception('Not logged in');
    }

    final url = Uri.parse('$_baseUrl/api/user/account');
    final body = jsonEncode({
      'password': password,
    });

    try {
      final response = await http.delete(url, headers: _authHeaders, body: body);

      if (response.statusCode == 200) {
        // Success - clear token
        await clearToken();
        return;
      }

      // Try to parse error message
      try {
        final data = jsonDecode(response.body);
        if (response.statusCode == 401) {
          throw Exception(data['error'] ?? 'Password is incorrect');
        } else if (response.statusCode == 403) {
          throw Exception('Session expired. Please login again.');
        } else {
          throw Exception(data['error'] ?? 'Failed to delete account');
        }
      } catch (e) {
        // If JSON parsing fails, throw generic error
        if (e is Exception) rethrow;
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}

// Global instance of ApiService
// This makes it easy to access from anywhere in the app
final apiService = ApiService();
