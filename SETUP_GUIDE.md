# Complete Setup Guide for Beginners

This guide will walk you through setting up and running the Notes App from scratch. Follow each step carefully!

## 📋 What You Need Before Starting

### 1. Install Node.js

Node.js lets you run JavaScript on your computer (needed for the backend).

1. Go to [https://nodejs.org/](https://nodejs.org/)
2. Download the **LTS version** (recommended for most users)
3. Run the installer and follow the prompts
4. **Verify installation**: Open a terminal/command prompt and type:
   ```bash
   node --version
   ```
   You should see something like `v18.17.0`

### 2. Install Flutter

Flutter is used to build the mobile app.

**Full instructions:** [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

**Quick steps for Windows:**
1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Extract the zip file to a location like `C:\src\flutter`
3. Add Flutter to your PATH (the installer guide shows how)
4. Open a NEW terminal and run: `flutter doctor`
5. Fix any issues it finds

**Quick steps for Mac:**
1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install/macos)
2. Extract and move to a permanent location
3. Update your PATH in `.zshrc` or `.bash_profile`
4. Run `flutter doctor` and fix any issues

### 3. Install an IDE

Choose one:

**VS Code** (Recommended for beginners):
1. Download from [code.visualstudio.com](https://code.visualstudio.com/)
2. Install the **Flutter extension** (search "Flutter" in Extensions)
3. Install the **Thunder Client extension** (for testing API)

**Android Studio** (Good for Flutter development):
1. Download from [developer.android.com/studio](https://developer.android.com/studio)
2. Install Flutter and Dart plugins
3. Set up an Android emulator

### 4. Set Up an Emulator or Device

You need a way to run the Flutter app:

**Option A: Android Emulator** (Easier)
1. Open Android Studio
2. Go to Tools → Device Manager
3. Create a new Virtual Device (Pixel 5 recommended)
4. Download a system image when prompted
5. Click the play button to start the emulator

**Option B: Physical Device**
1. Enable Developer Options on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging in Developer Options
3. Connect phone to computer via USB
4. Run `flutter devices` to verify it's detected

## 🚀 Step-by-Step Setup

### Step 1: Open the Project

1. Open your terminal/command prompt
2. Navigate to the project folder:
   ```bash
   cd path/to/api-flutter-test
   ```

### Step 2: Set Up the Backend

1. **Navigate to backend folder:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

   This downloads all the required packages (Express, SQLite, etc.). It might take a minute.

3. **Start the server:**
   ```bash
   npm start
   ```

   You should see:
   ```
   ✅ Database initialized successfully
   ✅ Server running on http://localhost:3000
   📡 Also accessible via your local IP on port 3000
   ```

4. **Find your computer's IP address:**

   **Windows:**
   - Open Command Prompt
   - Type: `ipconfig`
   - Look for "IPv4 Address" under your active network adapter
   - Example: `192.168.1.100`

   **Mac/Linux:**
   - Open Terminal
   - Type: `ifconfig | grep "inet "`
   - Or: `hostname -I`
   - Look for your local IP (usually starts with 192.168 or 10.0)

5. **Write down your IP address!** You'll need it for the mobile app.
   Example: `192.168.1.100`

**Important:** Keep this terminal window open! The server needs to keep running.

### Step 3: Test the Backend (Optional but Recommended)

Open a **NEW terminal window** and test if the API is working:

```bash
# Test the API
curl http://localhost:3000
```

You should get a JSON response showing available endpoints.

**Or use Thunder Client:**
1. Open VS Code
2. Click Thunder Client icon in sidebar
3. Create a new request
4. Set to GET and enter: `http://localhost:3000`
5. Click Send
6. You should see a JSON response

### Step 4: Set Up the Mobile App

1. **Open a NEW terminal window** (keep backend running in the other one!)

2. **Navigate to mobile folder:**
   ```bash
   cd path/to/api-flutter-test/mobile
   ```

3. **Get Flutter dependencies:**
   ```bash
   flutter pub get
   ```

   This downloads all Flutter packages.

4. **Make sure an emulator is running or device is connected:**
   ```bash
   flutter devices
   ```

   You should see at least one device listed.

   **If no devices:**
   - Start your Android emulator, OR
   - Connect your phone via USB

5. **Run the app:**
   ```bash
   flutter run
   ```

   The app will build (this takes a while the first time - be patient!) and launch on your device.

### Step 5: Configure the App

Once the app opens:

1. **Enter your server address:**

   **If using Android emulator on the same computer:**
   ```
   http://10.0.2.2:3000
   ```

   **If using a real device:**
   ```
   http://YOUR_IP:3000
   ```
   Replace `YOUR_IP` with the IP address you found in Step 2.4

   Example: `http://192.168.1.100:3000`

2. **Important notes:**
   - Use `http://` not `https://`
   - Include the port `:3000`
   - Make sure your phone and computer are on the **same WiFi network**

3. Tap **Continue**

### Step 6: Create an Account

1. Tap **Register** at the bottom
2. Enter a username (at least 3 characters)
3. Enter a password (at least 6 characters)
4. Tap **Register**

You should be logged in and see an empty notes list!

### Step 7: Create Your First Note

1. Tap the blue **+** button
2. Enter a title (e.g., "My First Note")
3. Enter some content
4. Optionally add tags (e.g., "test, personal")
5. Tap the checkmark or **Save** button

Congratulations! You've created your first note! 🎉

## 🎯 What to Do Next

### Play Around with the App

- Create more notes
- Edit existing notes (tap on them)
- Delete notes (swipe left)
- Logout and login again
- Create another user account

### Read the Code

Now that it's working, start reading the code to understand how it works:

1. **Backend:**
   - Start with `backend/server.js` - Read the comments!
   - Then read `backend/database.js`

2. **Frontend:**
   - Start with `mobile/lib/main.dart`
   - Then look at the screens in `mobile/lib/screens/`
   - Finally check out the API service in `mobile/lib/services/`

### Experiment

Try making small changes:

- Change the app theme color in `mobile/lib/main.dart`
- Add a new field to notes (like "priority")
- Modify the UI colors and styles
- Add a new API endpoint

## 🐛 Troubleshooting

### Backend Issues

**"npm: command not found"**
- Node.js isn't installed or not in PATH
- Restart your terminal after installing Node.js

**"Cannot find module 'express'"**
- Run `npm install` in the backend folder

**"Error: listen EADDRINUSE"**
- Port 3000 is already in use
- Close any other programs using port 3000
- Or change the port in `backend/server.js`

### Flutter Issues

**"flutter: command not found"**
- Flutter isn't installed or not in PATH
- Follow the Flutter installation guide completely
- Restart your terminal

**"No devices found"**
- Start an Android emulator
- Or connect your phone and enable USB debugging

**"Unable to load asset"**
- Run: `flutter clean && flutter pub get && flutter run`

### Connection Issues

**"Network Error" in app**
- Make sure backend is running (check the terminal)
- Verify the IP address is correct
- If using Android emulator: use `http://10.0.2.2:3000`
- If using real device:
  - Check both devices are on same WiFi
  - Temporarily disable firewall to test
  - Try pinging your computer from your phone

**"Session expired" errors**
- This is normal - tokens expire after 24 hours
- Just login again

## 📚 Next Steps for Learning

1. **Understand HTTP Requests:**
   - Read about GET, POST, PUT, DELETE methods
   - Learn about status codes (200, 404, 500, etc.)
   - Understand request headers and body

2. **Learn SQL Basics:**
   - How to query databases
   - Understanding relationships (foreign keys)
   - Practice writing SQL queries

3. **Master Flutter Widgets:**
   - Do the [Flutter Codelab](https://docs.flutter.dev/get-started/codelab)
   - Experiment with different widgets
   - Learn about state management

4. **Explore More:**
   - Add new features to this app
   - Build your own app from scratch
   - Learn about deployment (hosting the backend online)

## 💡 Tips for Success

1. **Read error messages carefully** - They tell you exactly what's wrong
2. **Google is your friend** - Someone else has had your problem before
3. **Take breaks** - If you're stuck, step away for a bit
4. **Experiment** - Change things and see what happens (you can always undo!)
5. **Ask for help** - Use Stack Overflow, Reddit (r/FlutterDev), or Discord communities

## 📖 Helpful Commands

### Backend Commands
```bash
# Start the server
npm start

# Install dependencies
npm install

# Stop the server
Ctrl+C (in the terminal)
```

### Flutter Commands
```bash
# Run the app
flutter run

# Hot reload (while app is running)
Press 'r' in the terminal

# Hot restart (while app is running)
Press 'R' in the terminal

# Stop the app
Press 'q' in the terminal

# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Check Flutter installation
flutter doctor

# List connected devices
flutter devices
```

## 🎉 You Did It!

You've successfully set up a full-stack application with:
- A Node.js + Express backend
- A SQLite database
- A Flutter mobile app
- User authentication
- Full CRUD operations

This is a real achievement! You're now a full-stack developer! 🚀

Keep building, keep learning, and don't be afraid to break things - that's how you learn best!

---

**Need more help?** Check the README files in the backend/ and mobile/ folders for detailed documentation.
