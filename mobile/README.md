# Mobile App (Flutter) Documentation

This is the Flutter mobile app that connects to the Notes API backend.

## 📁 Project Structure

```
mobile/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/
│   │   ├── user.dart          # User data model
│   │   └── note.dart          # Note data model
│   ├── services/
│   │   └── api_service.dart   # API client (handles all HTTP requests)
│   └── screens/
│       ├── setup_screen.dart   # Enter server IP address
│       ├── login_screen.dart   # Login/Register
│       ├── notes_screen.dart   # List of notes
│       └── note_edit_screen.dart # Create/Edit note
├── pubspec.yaml               # Flutter dependencies
└── README.md                  # This file
```

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK** installed - [Installation guide](https://docs.flutter.dev/get-started/install)
2. **Android Studio** or **Xcode** (for iOS) with an emulator set up
3. **VS Code** with Flutter extension (optional but recommended)

### Check Your Flutter Installation

```bash
flutter doctor
```

This command checks if everything is set up correctly. Fix any issues it finds.

### Install Dependencies

```bash
# Navigate to the mobile folder
cd mobile

# Download all packages listed in pubspec.yaml
flutter pub get
```

### Run the App

```bash
# Make sure an emulator is running or a device is connected
flutter devices

# Run the app
flutter run
```

The app will build and launch on your device/emulator.

## 📱 App Flow

### 1. Setup Screen (First Launch)

When you first open the app, you'll see the Setup Screen where you enter your backend server address.

**What to enter:**
- If backend is on your computer and you're using an **Android emulator**: `http://10.0.2.2:3000`
- If backend is on your computer and you're using a **real device**: `http://YOUR_COMPUTER_IP:3000`
  - Find your computer's IP:
    - Windows: `ipconfig` → look for IPv4 Address
    - Mac: `ifconfig | grep "inet "` → look for your local IP
    - Linux: `hostname -I`

Example: `http://192.168.1.100:3000`

**Important:**
- Use `http://` not `https://` (unless you set up SSL on your backend)
- Make sure your device and computer are on the same WiFi network
- Port is usually `3000` (check your backend server output)

### 2. Login/Register Screen

After setting up the server address, you'll see the login screen.

**To create a new account:**
- Tap "Register" at the bottom
- Enter a username (at least 3 characters)
- Enter a password (at least 6 characters)
- Tap "Register"

**To login:**
- Enter your username
- Enter your password
- Tap "Login"

The app saves your login token, so you stay logged in even after closing the app.

### 3. Notes Screen

After logging in, you'll see all your notes.

**Actions:**
- **Create new note**: Tap the blue + button at the bottom right
- **Edit note**: Tap on any note in the list
- **Delete note**: Swipe a note left and confirm deletion
- **Refresh notes**: Pull down on the list
- **Logout**: Tap the logout icon at the top right

### 4. Note Edit Screen

When creating or editing a note:

- **Title**: Short name for your note (required)
- **Content**: The main text of your note (required)
- **Tags**: Comma-separated tags like "work, urgent, personal" (optional)
- **Save**: Tap the checkmark at the top right or the button at the bottom

## 🔧 Code Structure Explained

### Models (Data Classes)

**user.dart:**
```dart
class User {
  final int id;
  final String username;
  final String createdAt;
}
```

Simple class to hold user data. The `fromJson` method converts API responses into User objects.

**note.dart:**
```dart
class Note {
  final int? id;
  final String title;
  final String content;
  final String tags;
  // ...
}
```

Holds note data. The `?` makes fields nullable (can be null). The `toJson` method converts Note objects to JSON for API requests.

### Services

**api_service.dart:**

This is the **most important file** - it handles all communication with the backend.

Key methods:
- `register()` - Create new account
- `login()` - Login with credentials
- `getNotes()` - Fetch all notes
- `createNote()` - Create new note
- `updateNote()` - Update existing note
- `deleteNote()` - Delete a note

**How it works:**
```dart
// 1. Create URL
final url = Uri.parse('$_baseUrl/api/notes');

// 2. Make HTTP request
final response = await http.get(url, headers: _authHeaders);

// 3. Parse JSON response
final data = jsonDecode(response.body);

// 4. Convert to Dart objects
return Note.fromJson(data['note']);
```

### Screens (UI)

Each screen is a **StatefulWidget** because they need to track state (loading, data, errors).

**Common pattern:**
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data when screen opens
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch data from API
      final data = await apiService.getSomeData();

      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator(); // Show loading spinner
    }

    if (_errorMessage != null) {
      return Text('Error: $_errorMessage'); // Show error
    }

    return ListView(...); // Show data
  }
}
```

**Key concepts:**
- `setState()` - Tells Flutter to rebuild the UI
- `async/await` - Handle asynchronous operations (API calls)
- `Navigator` - Navigate between screens
- `ScaffoldMessenger` - Show toast messages

## 🔐 How Authentication Works

### 1. User Logs In

```dart
final result = await apiService.login(username, password);
```

This sends a POST request to `/api/login` with username and password.

### 2. Server Returns Token

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { "id": 1, "username": "john" }
}
```

### 3. App Saves Token

```dart
await setToken(result['token']);
```

The token is saved in `SharedPreferences` (persistent local storage).

### 4. Future Requests Include Token

```dart
headers: {
  'Authorization': 'Bearer $token'
}
```

Every API request after login includes this header. The backend verifies the token to know who the user is.

## 💾 Local Storage (SharedPreferences)

The app stores two pieces of data locally:

1. **base_url** - The backend server address
2. **auth_token** - The JWT token for authentication

```dart
// Save
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);

// Load
final token = prefs.getString('auth_token');

// Remove (logout)
await prefs.remove('auth_token');
```

This data persists even when the app is closed.

## 🎨 Customizing the App

### Change Colors

In `main.dart`:
```dart
theme: ThemeData(
  primarySwatch: Colors.blue, // Change to Colors.purple, Colors.green, etc.
  useMaterial3: true,
),
```

### Change App Name

In `pubspec.yaml`:
```yaml
name: notes_app # Change this
```

### Add More Fields to Notes

1. Update the Note model in `models/note.dart`
2. Update the API service methods if needed
3. Update the note edit screen to show the new field
4. Update the backend to accept the new field

## 🐛 Common Issues

### "No devices found"

**Problem:** No emulator or physical device connected

**Solution:**
- Open Android Studio and start an emulator
- Or connect your phone via USB with USB debugging enabled
- Run `flutter devices` to check

### "Unable to load asset"

**Problem:** Assets not found or pubspec.yaml misconfigured

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### "Network Error"

**Problem:** Can't connect to backend

**Solution:**
1. Verify backend is running (`npm start` in backend folder)
2. Check the base URL is correct
3. If using Android emulator, use `http://10.0.2.2:3000` not `http://localhost:3000`
4. If using real device:
   - Make sure device and computer are on same WiFi
   - Use your computer's IP address
   - Temporarily disable firewall to test

### "Session expired" errors

**Problem:** JWT token expired or invalid

**Solution:** Just login again. Tokens expire after 24 hours for security.

### App crashes on startup

**Problem:** Usually a dependency issue

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Learning Resources

### Flutter Basics

- [Flutter Official Tutorial](https://docs.flutter.dev/get-started/codelab) - Best place to start!
- [Dart Language Tour](https://dart.dev/guides/language/language-tour) - Learn Dart basics
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets) - See all available widgets

### HTTP Requests in Flutter

- [HTTP Package Documentation](https://pub.dev/packages/http)
- [Flutter Networking Tutorial](https://docs.flutter.dev/cookbook/networking/fetch-data)

### State Management

- [setState Explained](https://docs.flutter.dev/ui/interactivity#managing-state)
- For larger apps, consider: Provider, Riverpod, or Bloc

### Navigation

- [Flutter Navigation Guide](https://docs.flutter.dev/cookbook/navigation/navigation-basics)

## 🎯 Next Steps

Once you understand how this app works, try:

1. **Add Features:**
   - Add a search bar to search notes by title/content
   - Add filtering by tags
   - Add note categories
   - Add dark mode
   - Add note sharing (share as text)

2. **Improve UI:**
   - Add animations
   - Better error messages
   - Add images to notes
   - Rich text editing

3. **Add Functionality:**
   - Offline support (save notes locally when offline)
   - Pull-to-refresh on notes list
   - Sort notes by date/title
   - Mark notes as favorites

## 🧪 Testing

Flutter supports unit tests and widget tests:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

Create test files in the `test/` folder.

## 📦 Building for Production

### Android APK

```bash
flutter build apk
```

Find the APK in `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle
```

### iOS App (requires Mac)

```bash
flutter build ios
```

---

**You're now a Flutter developer! 🎉**

Keep experimenting and building. Every feature you add teaches you something new!
