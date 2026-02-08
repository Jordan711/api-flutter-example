/**
 * SETUP SCREEN
 *
 * This is the first screen users see.
 * They enter the backend server IP address here.
 *
 * Example: http://192.168.1.100:3000
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import 'login_screen.dart';

class SetupScreen extends StatefulWidget {
  final String? initialUrl; // Pre-fill with this URL if provided

  const SetupScreen({super.key, this.initialUrl});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  // Controller for the text input field
  final _urlController = TextEditingController();

  // Track loading state
  bool _isLoading = false;

  // Track errors
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill the text field with initial URL if provided
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      _urlController.text = widget.initialUrl!;
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _urlController.dispose();
    super.dispose();
  }

  /**
   * Test connection to the server
   * Returns true if server is accessible, false otherwise
   */
  Future<bool> _testConnection(String url) async {
    try {
      // Try to connect to the base endpoint
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      // Check if we got a successful response
      if (response.statusCode == 200) {
        // Try to parse as JSON to verify it's our API
        try {
          final data = jsonDecode(response.body);
          // Check if it has the expected message from our API
          if (data['message'] != null &&
              data['message'].toString().contains('Notes API')) {
            return true;
          }
        } catch (e) {
          // Not JSON or wrong format
          return false;
        }
      }
      return false;
    } catch (e) {
      // Connection failed (timeout, network error, etc.)
      return false;
    }
  }

  /**
   * Save the base URL and navigate to login screen
   * Tests connection first before saving
   */
  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();

    // Validation
    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a URL';
      });
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      setState(() {
        _errorMessage = 'URL must start with http:// or https://';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Test connection first
      final isConnected = await _testConnection(url);

      if (!isConnected) {
        setState(() {
          _errorMessage =
              'Cannot connect to server at $url\n\n'
              'Please check:\n'
              '• Backend server is running (npm start)\n'
              '• IP address is correct\n'
              '• Phone and computer are on same WiFi\n'
              '• Try http://10.0.2.2:3000 for Android emulator';
          _isLoading = false;
        });
        return;
      }

      // Connection successful - save the URL
      await apiService.setBaseUrl(url);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Connected to server successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App icon
              const Icon(
                Icons.note_alt_outlined,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Notes App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Enter your server address',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 48),

              // URL input field
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://192.168.1.100:3000',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),

              const SizedBox(height: 16),

              // Error message (separate from text field for multi-line support)
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_errorMessage != null) const SizedBox(height: 16),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📡 Server Setup Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Start backend: Run "npm start" in backend folder\n'
                      '2. The server will show your IP address\n'
                      '3. Enter the URL here:\n\n'
                      '   📱 Android Emulator → http://10.0.2.2:3000\n'
                      '   📱 Real Device → http://YOUR_IP:3000\n\n'
                      '4. Make sure phone & computer are on same WiFi',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Test & Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveUrl,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Testing connection...'),
                        ],
                      )
                    : const Text(
                        'Test Connection & Continue',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
