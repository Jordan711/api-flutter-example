# Backend API Documentation

This is the backend server for the Notes app. It's built with Express.js and uses SQLite for the database.

## 📁 Files Overview

```
backend/
├── server.js          # Main server file (all API routes)
├── database.js        # Database setup and functions
├── package.json       # Lists npm packages needed
├── notes.db           # SQLite database (created automatically)
└── README.md          # This file
```

## 🚀 Getting Started

### 1. Install Dependencies

```bash
npm install
```

This downloads all required packages:
- **express** - Web framework for building the API
- **cors** - Allows Flutter app to connect from different origin
- **bcryptjs** - Encrypts passwords
- **jsonwebtoken** - Creates secure login tokens
- **better-sqlite3** - SQLite database driver

### 2. Start the Server

```bash
npm start
```

You should see:
```
✅ Database initialized successfully
✅ Server running on http://localhost:3000
📡 Also accessible via your local IP on port 3000
🚀 Ready to accept requests!
```

### 3. Find Your Local IP Address

Your Flutter app needs to connect to your server using your computer's IP address.

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" under your active network adapter (e.g., `192.168.1.100`)

**Mac:**
```bash
ifconfig | grep "inet "
```

**Linux:**
```bash
hostname -I
```

Save this IP address - you'll need it in the Flutter app!

## 📡 API Endpoints

### Authentication Endpoints (No login required)

#### 1. Register New User

Creates a new user account.

**Endpoint:** `POST /api/register`

**Request Body:**
```json
{
  "username": "john",
  "password": "password123"
}
```

**Response (Success - 201):**
```json
{
  "message": "User registered successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "john",
    "created_at": "2024-01-15T10:30:00.000Z"
  }
}
```

**Response (Error - 409):**
```json
{
  "error": "Username already exists"
}
```

**Validation Rules:**
- Username must be at least 3 characters
- Password must be at least 6 characters
- Username must be unique

---

#### 2. Login

Login with existing account.

**Endpoint:** `POST /api/login`

**Request Body:**
```json
{
  "username": "john",
  "password": "password123"
}
```

**Response (Success - 200):**
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "john",
    "created_at": "2024-01-15T10:30:00.000Z"
  }
}
```

**Response (Error - 401):**
```json
{
  "error": "Invalid username or password"
}
```

---

### Notes Endpoints (Require Authentication)

All notes endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <your-token-here>
```

#### 3. Get All Notes

Get all notes for the logged-in user.

**Endpoint:** `GET /api/notes`

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (Success - 200):**
```json
{
  "notes": [
    {
      "id": 1,
      "user_id": 1,
      "title": "Shopping List",
      "content": "Buy milk, eggs, bread",
      "tags": "personal, shopping",
      "created_at": "2024-01-15T10:30:00.000Z",
      "updated_at": "2024-01-15T10:30:00.000Z"
    },
    {
      "id": 2,
      "user_id": 1,
      "title": "Work Tasks",
      "content": "Finish the project report",
      "tags": "work, urgent",
      "created_at": "2024-01-15T11:00:00.000Z",
      "updated_at": "2024-01-15T14:30:00.000Z"
    }
  ],
  "count": 2
}
```

---

#### 4. Create Note

Create a new note.

**Endpoint:** `POST /api/notes`

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Request Body:**
```json
{
  "title": "My New Note",
  "content": "This is the note content",
  "tags": "personal, ideas"
}
```

**Response (Success - 201):**
```json
{
  "message": "Note created successfully",
  "note": {
    "id": 3,
    "user_id": 1,
    "title": "My New Note",
    "content": "This is the note content",
    "tags": "personal, ideas",
    "created_at": "2024-01-15T15:00:00.000Z",
    "updated_at": "2024-01-15T15:00:00.000Z"
  }
}
```

**Validation Rules:**
- Title is required
- Content is required
- Tags are optional

---

#### 5. Update Note

Update an existing note.

**Endpoint:** `PUT /api/notes/:id`

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Request Body:**
```json
{
  "title": "Updated Title",
  "content": "Updated content",
  "tags": "updated, tags"
}
```

**Response (Success - 200):**
```json
{
  "message": "Note updated successfully",
  "note": {
    "id": 3,
    "user_id": 1,
    "title": "Updated Title",
    "content": "Updated content",
    "tags": "updated, tags",
    "created_at": "2024-01-15T15:00:00.000Z",
    "updated_at": "2024-01-15T16:30:00.000Z"
  }
}
```

**Response (Error - 404):**
```json
{
  "error": "Note not found or unauthorized"
}
```

**Note:** You can only update your own notes. Trying to update another user's note will return 404.

---

#### 6. Delete Note

Delete a note.

**Endpoint:** `DELETE /api/notes/:id`

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (Success - 200):**
```json
{
  "message": "Note deleted successfully"
}
```

**Response (Error - 404):**
```json
{
  "error": "Note not found or unauthorized"
}
```

---

## 🔐 How Authentication Works

### 1. Registration/Login Flow

```
User enters username + password
         ↓
Server checks credentials
         ↓
Server creates JWT token
         ↓
Token sent back to client
         ↓
Client saves token (stored in app memory/storage)
```

### 2. Making Authenticated Requests

```
Client wants to get notes
         ↓
Client sends request with token in Authorization header
         ↓
Server verifies token
         ↓
If valid: Process request and send response
If invalid: Return 403 error
```

### 3. What's in a JWT Token?

A JWT token looks like this:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJqb2huIiwiaWF0IjoxNjQyMjUyODAwfQ.signature
```

It's three parts separated by dots:
1. **Header** - Token type and algorithm
2. **Payload** - User data (id, username)
3. **Signature** - Ensures token hasn't been tampered with

The server can decode this token to know who the user is, without storing session data!

## 💾 Database Structure

### Users Table

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Auto-incrementing primary key |
| username | TEXT | Unique username |
| password_hash | TEXT | Encrypted password (never plain text!) |
| created_at | DATETIME | When account was created |

### Notes Table

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Auto-incrementing primary key |
| user_id | INTEGER | Links to users.id (who owns this note) |
| title | TEXT | Note title |
| content | TEXT | Note content/body |
| tags | TEXT | Comma-separated tags |
| created_at | DATETIME | When note was created |
| updated_at | DATETIME | When note was last modified |

**Relationship:** Each note belongs to one user (foreign key: user_id → users.id)

## 🧪 Testing the API

You can test the API without the Flutter app using:

### Option 1: Thunder Client (VS Code Extension)

1. Install "Thunder Client" extension in VS Code
2. Create a new request
3. Set method (POST, GET, etc.) and URL
4. Add body/headers as needed
5. Click Send

### Option 2: curl (Command Line)

**Register:**
```bash
curl -X POST http://localhost:3000/api/register \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"password\":\"password123\"}"
```

**Login:**
```bash
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"password\":\"password123\"}"
```

**Get Notes (replace TOKEN with your actual token):**
```bash
curl -X GET http://localhost:3000/api/notes \
  -H "Authorization: Bearer TOKEN"
```

**Create Note:**
```bash
curl -X POST http://localhost:3000/api/notes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d "{\"title\":\"Test Note\",\"content\":\"Test content\",\"tags\":\"test\"}"
```

## 🐛 Common Issues

### "Error: Cannot find module 'express'"
**Problem:** Dependencies not installed
**Solution:** Run `npm install` in the backend folder

### "Error: listen EADDRINUSE :::3000"
**Problem:** Port 3000 is already in use
**Solution:**
- Find and close the program using port 3000
- Or change the port in server.js: `const PORT = 3001;`

### "Database locked" errors
**Problem:** Multiple processes trying to access database
**Solution:** Make sure only one server instance is running

### Flutter app can't connect
**Problem:** Wrong IP address or firewall blocking
**Solution:**
- Verify server is running
- Check IP address is correct
- If using Android emulator, use `http://10.0.2.2:3000`
- Temporarily disable firewall to test

## 🔧 Code Structure Explained

### server.js

```javascript
// 1. Import packages
const express = require('express');

// 2. Create Express app
const app = express();

// 3. Add middleware (runs before routes)
app.use(cors());
app.use(express.json());

// 4. Define routes
app.post('/api/register', (req, res) => {
  // Handle registration
});

// 5. Start server
app.listen(3000);
```

### database.js

```javascript
// 1. Connect to database
const db = new Database('notes.db');

// 2. Create tables if they don't exist
function initDatabase() {
  db.exec('CREATE TABLE IF NOT EXISTS users...');
}

// 3. Export functions
module.exports = {
  createUser,
  getNotes,
  // ... other functions
};
```

## 📚 Learning Resources

- [Express.js Tutorial](https://expressjs.com/en/starter/hello-world.html)
- [REST API Concepts](https://restfulapi.net/)
- [JWT Explained](https://jwt.io/introduction)
- [SQLite Tutorial](https://www.sqlitetutorial.net/)
- [bcrypt Explained](https://github.com/kelektiv/node.bcrypt.js#readme)

## 🎯 Next Steps

Once you understand how this works, try:
- Adding a "Get note by ID" endpoint
- Adding note categories
- Adding a search endpoint
- Implementing refresh tokens
- Adding rate limiting for security

---

**You're now running a real REST API! 🎉**
