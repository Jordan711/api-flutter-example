/**
 * NOTES SCREEN
 *
 * This is the main screen after login.
 * It shows a list of all the user's notes.
 *
 * Users can:
 * - View their notes
 * - Tap a note to edit it
 * - Tap the + button to create a new note
 * - Delete notes with swipe gesture
 * - Logout
 */

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import 'note_edit_screen.dart';
import 'login_screen.dart';
import 'account_settings_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // List of notes
  List<Note> _notes = [];

  // Loading state
  bool _isLoading = true;

  // Error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  /**
   * Load notes from the API
   */
  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notes = await apiService.getNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /**
   * Delete a note
   */
  Future<void> _deleteNote(Note note) async {
    try {
      await apiService.deleteNote(note.id!);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }

      // Reload notes
      _loadNotes();
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  /**
   * Navigate to note edit screen
   */
  Future<void> _navigateToEdit({Note? note}) async {
    // Navigate and wait for result
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(note: note),
      ),
    );

    // If note was created/updated, reload the list
    if (result == true) {
      _loadNotes();
    }
  }

  /**
   * Navigate to account settings
   */
  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
    );
  }

  /**
   * Logout
   */
  Future<void> _logout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Clear token
      await apiService.logout();

      // Navigate to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          // Settings button for account management
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Account Settings',
          ),
        ],
      ),
      body: _buildBody(),
      // Floating action button to add new note
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /**
   * Build the body based on current state
   */
  Widget _buildBody() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No notes yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to create your first note',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // List of notes
    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return _buildNoteCard(note);
        },
      ),
    );
  }

  /**
   * Build a card for a single note
   */
  Widget _buildNoteCard(Note note) {
    return Dismissible(
      key: Key(note.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteNote(note);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          title: Text(
            note.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: note
                      .getTagsList()
                      .map((tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 10),
                            ),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateToEdit(note: note),
        ),
      ),
    );
  }
}
