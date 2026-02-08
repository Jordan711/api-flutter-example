# 📝 Private Note Taker - Full Stack App for Beginners

**A simple, well-documented project to learn full-stack development**

## What You'll Build

A private note-taking app where you can:
- 📱 Enter your server IP address in the app
- 🔐 Create an account and login
- ✍️ Write notes with titles, content, and tags
- 📋 View all your personal notes
- ✏️ Edit and delete your notes
- 🔒 Keep your notes private (each user sees only their own notes)

## What You'll Learn

- **Backend Development**: Building a REST API with Express.js
- **Database**: Storing data with SQLite
- **Authentication**: User login/register with JWT tokens
- **Security**: Hashing passwords, protecting routes
- **Mobile Development**: Creating a Flutter app
- **API Integration**: Connecting your app to a backend server

## Technology Stack

### Backend (Server)
- **Node.js** - JavaScript runtime for the server
- **Express.js** - Simple web framework for building APIs
- **SQLite** - File-based database (no complex setup needed!)
- **JWT** - Secure tokens for keeping users logged in
- **bcryptjs** - Encrypts passwords so they're never stored as plain text

### Frontend (Mobile App)
- **Flutter** - Build iOS and Android apps from one codebase
- **Dart** - The programming language for Flutter
- **HTTP package** - Makes requests to your backend API

## 📁 Simple Project Structure

```
api-flutter-test/
├── backend/                # Your Express.js server
│   ├── server.js          # Main server file (all routes here)
│   ├── database.js        # Database setup and functions
│   ├── package.json       # Lists the npm packages needed
│   ├── notes.db           # SQLite database (created automatically)
│   └── README.md          # Detailed backend guide
│
├── mobile/                 # Your Flutter app
│   ├── lib/
│   │   ├── main.dart      # App entry point
│   │   ├── screens/       # Different screens (login, notes list, etc.)
│   │   ├── services/      # Code to talk to the backend API
│   │   └── models/        # Data structures (User, Note)
│   ├── pubspec.yaml       # Flutter dependencies
│   └── README.md          # Detailed Flutter guide
│
└── README.md              # This file - start here!
```

**Note**: This is a simplified structure perfect for learning! All backend code is in 2 files, making it easy to understand the whole flow.

## 🚀 Quick Start Guide (15 minutes)

### Prerequisites - Install These First

1. **Node.js** (v16 or higher) - [Download here](https://nodejs.org/)
   - This runs your backend server
   - Check installation: Open terminal and type `node --version`

2. **Flutter SDK** - [Installation guide](https://docs.flutter.dev/get-started/install)
   - This builds your mobile app
   - Check installation: Type `flutter doctor` in terminal

3. **Code Editor** - Pick one:
   - **VS Code** (recommended for beginners) - [Download](https://code.visualstudio.com/)
   - **Android Studio** - [Download](https://developer.android.com/studio)

4. **An emulator or physical device**:
   - Android emulator (comes with Android Studio)
   - Or connect your Android/iOS phone via USB

### Step 1: Set Up the Backend (5 minutes)

```bash
# Open terminal and navigate to backend folder
cd backend

# Install all required packages (this downloads Express, SQLite, etc.)
npm install

# Start the server
npm start
```

You should see: `✅ Server running on http://localhost:3000`

**Find your computer's local IP address** (you'll need this for the app):
- **Windows**: Open Command Prompt → type `ipconfig` → look for "IPv4 Address" (e.g., 192.168.1.100)
- **Mac**: Open Terminal → type `ifconfig | grep "inet "` → look for your local IP
- **Linux**: Open Terminal → type `hostname -I` → first address is usually your local IP

### Step 2: Set Up the Mobile App (5 minutes)

Open a **NEW terminal window** (keep the backend running in the first one!)

```bash
# Navigate to mobile folder
cd mobile

# Download all Flutter packages
flutter pub get

# Run the app (make sure emulator is running or phone is connected)
flutter run
```

The app will build and launch on your device/emulator.

### Step 3: Use the App (5 minutes)

1. **Enter Server IP**:
   - On the first screen, enter `http://YOUR_IP:3000` (e.g., `http://192.168.1.100:3000`)
   - If using Android emulator on same computer, use `http://10.0.2.2:3000`
   - Tap "Save"

2. **Register**: Create a new account
   - Username: pick anything (e.g., "john")
   - Password: at least 6 characters

3. **Login**: Sign in with your new account

4. **Create Notes**:
   - Tap the + button
   - Add a title, content, and tags (comma-separated)
   - Tap "Save"

5. **Test It**: Edit notes, delete them, logout and login again - your data persists!

## 📡 API Endpoints (What Your Server Can Do)

| Method | URL | What It Does | Needs Login? |
|--------|-----|--------------|--------------|
| POST | `/api/register` | Create a new user account | No |
| POST | `/api/login` | Login and get an access token | No |
| GET | `/api/notes` | Get all notes for logged-in user | Yes |
| POST | `/api/notes` | Create a new note | Yes |
| PUT | `/api/notes/:id` | Update an existing note | Yes |
| DELETE | `/api/notes/:id` | Delete a note | Yes |

**Example**: When you tap "Create Note" in the app, it sends a POST request to `/api/notes` with your note data.

## 🧠 Key Concepts Explained (For Learning)

### 1. What is a REST API?

Think of it like a restaurant:
- **Menu (API endpoints)**: List of things you can order (GET notes, POST new note, etc.)
- **Waiter (HTTP requests)**: Takes your order to the kitchen
- **Kitchen (backend server)**: Prepares your order
- **Food (response)**: What you get back (your notes data)

Our API uses:
- **GET** - Fetch data (like asking "what's on the menu?")
- **POST** - Create new data (like ordering food)
- **PUT** - Update existing data (like changing your order)
- **DELETE** - Remove data (like canceling an order)

### 2. How Does Login Work? (JWT Authentication)

**JWT** = JSON Web Token (a secure, encrypted string)

1. You enter username + password
2. Server checks if they're correct
3. If yes, server creates a **token** (like a movie ticket)
4. Your app saves this token
5. Every future request includes the token (like showing your ticket)
6. Server checks the token to know who you are

**Why not send password every time?**
- More secure (password is only sent once)
- Faster (checking a token is quicker than hashing passwords)

### 3. Database Structure

Our SQLite database has 2 tables:

**users table**:
```
id | username | password_hash        | created_at
---|----------|---------------------|-------------------
1  | john     | $2a$10$encrypted... | 2024-01-15 10:30:00
2  | jane     | $2a$10$encrypted... | 2024-01-16 14:20:00
```

**notes table**:
```
id | user_id | title        | content              | tags        | created_at          | updated_at
---|---------|--------------|---------------------|-------------|---------------------|--------------------
1  | 1       | Shopping     | Buy milk, eggs      | personal    | 2024-01-15 11:00:00 | 2024-01-15 11:00:00
2  | 1       | Work         | Finish project      | work        | 2024-01-15 12:00:00 | 2024-01-16 09:30:00
3  | 2       | Recipe       | Pasta recipe        | cooking     | 2024-01-16 15:00:00 | 2024-01-16 15:00:00
```

**Relationship**: `notes.user_id` links to `users.id` (each note belongs to one user)

### 4. How Frontend Connects to Backend

```
Flutter App          →          Express Server          →          SQLite Database
[User taps button]   →   [HTTP request sent]     →   [Server queries database]
[Wait for response]  ←   [HTTP response sent]    ←   [Server gets data back]
[Display notes]      ←   [JSON data received]    ←   [Data formatted as JSON]
```

## 🔐 Security Features

- **Passwords are hashed**: Your password is never stored as plain text. We use bcrypt to encrypt it.
- **JWT tokens**: Tokens expire after 24 hours for security
- **Protected routes**: Can't access notes without being logged in
- **CORS enabled**: Allows your Flutter app to talk to the server
- **User isolation**: You can only see/edit/delete your own notes

## 🧪 Testing the API (Optional - For Learning)

Want to test the backend without the mobile app? You can use:
- **Thunder Client** (VS Code extension - easiest)
- **Postman** (popular API testing tool)
- **curl** (command line)

Example - Register a new user:
```bash
curl -X POST http://localhost:3000/api/register \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"password\":\"password123\"}"
```

## 🐛 Common Issues & Solutions

### Backend Issues

**"npm: command not found"**
- Node.js isn't installed. Download it from [nodejs.org](https://nodejs.org/)

**"Error: Cannot find module 'express'"**
- You forgot to run `npm install` in the backend folder

**"Error: listen EADDRINUSE :::3000"**
- Port 3000 is already in use
- Solution: Close the other program using port 3000, or change the port in `server.js`

### Frontend Issues

**"flutter: command not found"**
- Flutter isn't installed. Follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install)

**"No devices found"**
- Start an Android/iOS emulator, or connect your phone via USB
- Run `flutter doctor` to see what's missing

**"Network Error" or "Connection refused"**
- Make sure the backend server is running (you should see "Server running on port 3000")
- Check the IP address is correct in the app
- If using Android emulator, use `http://10.0.2.2:3000` (NOT `localhost`)
- If using real device, make sure your phone and computer are on the **same WiFi network**
- Try disabling your firewall temporarily

**"Unable to load asset"**
- Run `flutter clean` then `flutter pub get` and try again

### Database Issues

**"Table doesn't exist"**
- The database wasn't created properly
- Delete the `notes.db` file and restart the server (it will recreate it)

## 📚 Learning Path (Recommended Order)

### For Complete Beginners:

1. **Start with Backend** (backend/README.md)
   - Understand how a server works
   - Learn about API endpoints
   - See how data is stored in a database
   - Test endpoints with Thunder Client or Postman

2. **Then Frontend** (mobile/README.md)
   - Learn Flutter basics
   - Understand how to make HTTP requests
   - Build user interfaces
   - Connect UI to your backend

3. **Experiment and Extend**
   - Add a "favorite" feature to notes
   - Add note categories
   - Add search functionality
   - Change colors and styling

### Understanding the Code

All code files have **detailed comments** explaining:
- What each function does
- Why we're doing it this way
- What each line means

**Don't just copy-paste!** Read the comments and try to understand the flow.

## 🎯 Next Steps After Completing This Project

1. **Add Features**:
   - Note categories/folders
   - Mark notes as favorites
   - Search notes by content or tags
   - Add images to notes
   - Dark mode

2. **Deploy It**:
   - Deploy backend to Railway or Render (free hosting)
   - Share with friends
   - Access from anywhere

3. **Learn More**:
   - Add automated tests
   - Learn TypeScript for backend
   - Try different state management in Flutter
   - Build a web version with React or Vue

## 📖 Helpful Resources

- [Express.js Crash Course](https://www.youtube.com/watch?v=L72fhGm1tfE) (YouTube)
- [Flutter for Beginners](https://docs.flutter.dev/get-started/codelab) (Official Tutorial)
- [REST API Concepts](https://restfulapi.net/)
- [JWT Explained](https://jwt.io/introduction)
- [SQLite Tutorial](https://www.sqlitetutorial.net/)

## 💡 Tips for Success

1. **Read error messages carefully** - They tell you exactly what's wrong
2. **Test one thing at a time** - Don't change multiple things and hope it works
3. **Use console.log()** (backend) and **print()** (Flutter) to debug
4. **Google is your friend** - Someone else has had your problem before
5. **Take breaks** - Sometimes stepping away helps you see the solution

## ❓ Need Help?

1. Read the error message carefully
2. Check the README files in backend/ and mobile/ folders
3. Look at the code comments
4. Search the error on Google or Stack Overflow
5. Make sure all prerequisites are installed (`node --version`, `flutter doctor`)

---

**You've got this! 🚀 Happy Coding!**

*Remember: Every expert developer started exactly where you are now. The key is to keep experimenting and learning!*
