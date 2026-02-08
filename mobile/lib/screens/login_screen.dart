/**
 * LOGIN/REGISTER SCREEN
 *
 * This screen handles both login and registration.
 * Users can toggle between the two modes.
 */

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'notes_screen.dart';
import 'setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Track if we're in login or register mode
  bool _isLoginMode = true;

  // Track loading state
  bool _isLoading = false;

  // Track errors
  String? _errorMessage;

  // Password visibility
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /**
   * Handle login
   */
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validation
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter username and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call API
      await apiService.login(username, password);

      // Success - navigate to notes screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NotesScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /**
   * Handle registration
   */
  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validation
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter username and password';
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _errorMessage = 'Username must be at least 3 characters';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call API
      await apiService.register(username, password);

      // Success - navigate to notes screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NotesScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /**
   * Toggle between login and register mode
   */
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
    });
  }

  /**
   * Change server address
   * Clears saved URL and navigates back to setup screen
   */
  Future<void> _changeServer() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Server?'),
        content: Text(
          'This will clear the current server address and take you back to server setup.\n\n'
          'Current server: ${apiService.baseUrl ?? 'Not set'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Change Server'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Get current URL before clearing
      final currentUrl = apiService.baseUrl;

      // Clear the saved base URL
      await apiService.setBaseUrl('');

      // Navigate to setup screen with current URL pre-filled
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SetupScreen(initialUrl: currentUrl),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Settings button to change server
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _changeServer,
            tooltip: 'Change Server',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App icon
                const Icon(
                  Icons.note_alt,
                  size: 80,
                  color: Colors.blue,
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  _isLoginMode ? 'Welcome Back!' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  _isLoginMode
                      ? 'Login to access your notes'
                      : 'Register to start taking notes',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 32),

                // Username field
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  autocorrect: false,
                ),

                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
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

                const SizedBox(height: 24),

                // Login/Register button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_isLoginMode ? _handleLogin : _handleRegister),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isLoginMode ? 'Login' : 'Register',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 16),

                // Toggle between login and register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLoginMode
                          ? "Don't have an account? "
                          : "Already have an account? ",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isLoginMode ? 'Register' : 'Login',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
