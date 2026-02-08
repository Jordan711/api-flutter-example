/**
 * MAIN.DART - App Entry Point
 *
 * This is where the Flutter app starts.
 * It sets up the app theme and determines which screen to show first.
 */

import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/setup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notes_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      // App theme - customize colors here!
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Start with the home page
      home: const HomePage(),
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
    );
  }
}

/**
 * HomePage - Determines which screen to show
 *
 * Flow:
 * 1. If no base URL is set → Show SetupScreen (enter IP)
 * 2. If not logged in → Show LoginScreen
 * 3. If logged in → Show NotesScreen
 */
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  bool _hasBaseUrl = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  /**
   * Check if base URL and token are saved
   * This runs when the app starts
   */
  Future<void> _checkStatus() async {
    // Load saved base URL and token from SharedPreferences
    await apiService.loadBaseUrl();
    await apiService.loadToken();

    setState(() {
      _hasBaseUrl = apiService.baseUrl != null;
      _isLoggedIn = apiService.isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while checking status
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Decide which screen to show
    if (!_hasBaseUrl) {
      // No base URL set - show setup screen
      return const SetupScreen();
    } else if (!_isLoggedIn) {
      // Not logged in - show login screen
      return const LoginScreen();
    } else {
      // Logged in - show notes screen
      return const NotesScreen();
    }
  }
}
