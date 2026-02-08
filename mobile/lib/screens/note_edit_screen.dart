/**
 * NOTE EDIT/CREATE SCREEN
 *
 * This screen is used for both creating new notes and editing existing ones.
 *
 * If a note is passed in, we're editing.
 * If note is null, we're creating a new one.
 */

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note; // Null if creating new note

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  // Text controllers
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // If editing existing note, populate fields
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _tagsController.text = widget.note!.tags;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /**
   * Save the note (create or update)
   */
  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tags = _tagsController.text.trim();

    // Validation
    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Title is required';
      });
      return;
    }

    if (content.isEmpty) {
      setState(() {
        _errorMessage = 'Content is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.note == null) {
        // Create new note
        final newNote = Note(
          userId: 0, // Will be set by the backend
          title: title,
          content: content,
          tags: tags,
        );

        await apiService.createNote(newNote);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note created successfully')),
          );
        }
      } else {
        // Update existing note
        final updatedNote = widget.note!.copyWith(
          title: title,
          content: content,
          tags: tags,
        );

        await apiService.updateNote(updatedNote);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note updated successfully')),
          );
        }
      }

      // Go back and signal success
      if (mounted) {
        Navigator.of(context).pop(true); // true = note was saved
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Create Note'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title field
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter note title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: 16),

                  // Content field
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      hintText: 'Enter note content',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 10,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: 16),

                  // Tags field
                  TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'Enter tags (comma-separated)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                      helperText: 'Example: personal, work, important',
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Save button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveNote,
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? 'Update Note' : 'Create Note'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  // Show timestamps for existing notes
                  if (isEditing && widget.note!.createdAt != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Created: ${_formatDate(widget.note!.createdAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (widget.note!.updatedAt != null)
                      Text(
                        'Last updated: ${_formatDate(widget.note!.updatedAt!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ],
              ),
            ),
    );
  }

  /**
   * Format a date string for display
   * Converts "2024-01-15T10:30:00.000Z" to "Jan 15, 2024 10:30 AM"
   */
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final month = _getMonthName(date.month);
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');

      return '$month ${date.day}, ${date.year} $hour:$minute $period';
    } catch (e) {
      return dateStr; // Return original if parsing fails
    }
  }

  /**
   * Get month name from month number
   */
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
