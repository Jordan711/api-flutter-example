/**
 * SERVER.JS - Main Express.js server file
 *
 * This file contains:
 * - Express app setup
 * - All API routes (endpoints)
 * - Authentication middleware
 * - Error handling
 *
 * How it works:
 * 1. Client sends HTTP request (GET, POST, PUT, DELETE)
 * 2. Express receives it and matches it to a route
 * 3. Route handler processes the request (maybe checks auth, queries database)
 * 4. Server sends back a response (JSON data)
 */

const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const os = require('os');
const db = require('./database');

// Create Express app
const app = express();
const PORT = 3000;

// Secret key for signing JWT tokens
// In production, this should be a long random string stored in environment variables
// For learning purposes, we're using a simple string
const JWT_SECRET = 'your-secret-key-change-this-in-production';

/**
 * MIDDLEWARE - Code that runs BEFORE route handlers
 */

// Enable CORS - Allows requests from Flutter app (different origin)
// Without this, browsers would block the requests
app.use(cors());

// Parse JSON request bodies
// This allows us to access req.body in our routes
app.use(express.json());

// Simple request logger - Logs every request
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next(); // Continue to the next middleware/route handler
});

/**
 * Authentication Middleware
 * Checks if the request has a valid JWT token
 * Use this for protected routes (routes that require login)
 */
function authenticateToken(req, res, next) {
  // Get the token from Authorization header
  // Expected format: "Bearer <token>"
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Get the token part

  // If no token provided, return error
  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  // Verify the token
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      // Token is invalid or expired
      return res.status(403).json({ error: 'Invalid or expired token' });
    }

    // Token is valid - attach user info to request object
    // Now any route handler can access req.user
    req.user = user;
    next(); // Continue to the route handler
  });
}

/**
 * ROUTES - API Endpoints
 */

// Test route - Check if server is running
app.get('/', (req, res) => {
  res.json({
    message: 'Notes API is running! 🚀',
    endpoints: {
      register: 'POST /api/register',
      login: 'POST /api/login',
      notes: 'GET /api/notes (requires auth)',
      createNote: 'POST /api/notes (requires auth)',
      updateNote: 'PUT /api/notes/:id (requires auth)',
      deleteNote: 'DELETE /api/notes/:id (requires auth)'
    }
  });
});

/**
 * AUTHENTICATION ROUTES
 */

/**
 * Register a new user
 * POST /api/register
 * Body: { username, password }
 */
app.post('/api/register', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Validation
    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    if (username.length < 3) {
      return res.status(400).json({ error: 'Username must be at least 3 characters' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    // Check if username already exists
    const existingUser = await db.getUserByUsername(username);
    if (existingUser) {
      return res.status(409).json({ error: 'Username already exists' });
    }

    // Create the user
    const user = await db.createUser(username, password);

    // Create a JWT token for the new user
    const token = jwt.sign(
      { id: user.id, username: user.username },
      JWT_SECRET,
      { expiresIn: '24h' } // Token expires in 24 hours
    );

    // Send back the token and user info
    res.status(201).json({
      message: 'User registered successfully',
      token: token,
      user: user
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * Login
 * POST /api/login
 * Body: { username, password }
 */
app.post('/api/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Validation
    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    // Verify credentials
    const user = await db.verifyUser(username, password);

    if (!user) {
      // Invalid username or password
      return res.status(401).json({ error: 'Invalid username or password' });
    }

    // Create JWT token
    const token = jwt.sign(
      { id: user.id, username: user.username },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    // Send back token and user info
    res.json({
      message: 'Login successful',
      token: token,
      user: user
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * NOTES ROUTES (All require authentication)
 */

/**
 * Get all notes for the logged-in user
 * GET /api/notes
 * Headers: Authorization: Bearer <token>
 */
app.get('/api/notes', authenticateToken, async (req, res) => {
  try {
    // req.user is set by authenticateToken middleware
    const notes = await db.getNotesByUserId(req.user.id);

    res.json({
      notes: notes,
      count: notes.length
    });

  } catch (error) {
    console.error('Get notes error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * Create a new note
 * POST /api/notes
 * Headers: Authorization: Bearer <token>
 * Body: { title, content, tags }
 */
app.post('/api/notes', authenticateToken, async (req, res) => {
  try {
    const { title, content, tags } = req.body;

    // Validation
    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }

    // Create the note
    const note = await db.createNote(req.user.id, title, content, tags || '');

    res.status(201).json({
      message: 'Note created successfully',
      note: note
    });

  } catch (error) {
    console.error('Create note error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * Update a note
 * PUT /api/notes/:id
 * Headers: Authorization: Bearer <token>
 * Body: { title, content, tags }
 */
app.put('/api/notes/:id', authenticateToken, async (req, res) => {
  try {
    const noteId = parseInt(req.params.id);
    const { title, content, tags } = req.body;

    // Validation
    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }

    // Update the note
    const updatedNote = await db.updateNote(noteId, req.user.id, title, content, tags || '');

    if (!updatedNote) {
      return res.status(404).json({ error: 'Note not found or unauthorized' });
    }

    res.json({
      message: 'Note updated successfully',
      note: updatedNote
    });

  } catch (error) {
    console.error('Update note error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * Delete a note
 * DELETE /api/notes/:id
 * Headers: Authorization: Bearer <token>
 */
app.delete('/api/notes/:id', authenticateToken, async (req, res) => {
  try {
    const noteId = parseInt(req.params.id);

    // Delete the note
    const success = await db.deleteNote(noteId, req.user.id);

    if (!success) {
      return res.status(404).json({ error: 'Note not found or unauthorized' });
    }

    res.json({ message: 'Note deleted successfully' });

  } catch (error) {
    console.error('Delete note error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * USER ACCOUNT ROUTES (Require authentication)
 */

/**
 * Change password
 * PUT /api/user/password
 * Headers: Authorization: Bearer <token>
 * Body: { oldPassword, newPassword }
 */
app.put('/api/user/password', authenticateToken, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    // Validation
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ error: 'Old password and new password are required' });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ error: 'New password must be at least 6 characters' });
    }

    if (oldPassword === newPassword) {
      return res.status(400).json({ error: 'New password must be different from old password' });
    }

    // Change password
    const success = await db.changePassword(req.user.id, oldPassword, newPassword);

    if (!success) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }

    res.json({ message: 'Password changed successfully' });

  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * Delete account
 * DELETE /api/user/account
 * Headers: Authorization: Bearer <token>
 * Body: { password }
 */
app.delete('/api/user/account', authenticateToken, async (req, res) => {
  try {
    const { password } = req.body;

    // Validation
    if (!password) {
      return res.status(400).json({ error: 'Password is required to delete account' });
    }

    // Delete account
    const success = await db.deleteUserAccount(req.user.id, password);

    if (!success) {
      return res.status(401).json({ error: 'Password is incorrect' });
    }

    res.json({ message: 'Account deleted successfully' });

  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * 404 Handler - Catch all undefined routes
 */
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

/**
 * Helper function to get local IP address
 */
function getLocalIpAddress() {
  const interfaces = os.networkInterfaces();

  // Look for IPv4 addresses that are not internal (not 127.0.0.1)
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      // Skip internal (loopback) and non-IPv4 addresses
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }

  return null;
}

/**
 * START THE SERVER
 */

// Initialize database (create tables if they don't exist)
db.initDatabase();

// Start listening for requests
app.listen(PORT, '0.0.0.0', () => {
  const localIp = getLocalIpAddress();

  console.log(`\n✅ Server running successfully!`);
  console.log(`\n📍 Server URLs:`);
  console.log(`   Local:    http://localhost:${PORT}`);

  if (localIp) {
    console.log(`   Network:  http://${localIp}:${PORT}`);
    console.log(`\n💡 For Flutter app, use:`);
    console.log(`   📱 Android Emulator: http://10.0.2.2:${PORT}`);
    console.log(`   📱 Real Device:      http://${localIp}:${PORT}`);
  } else {
    console.log(`   Network:  Unable to detect (use ipconfig/ifconfig)`);
  }

  console.log(`\n📝 API Endpoints:`);
  console.log(`   POST /api/register - Register new user`);
  console.log(`   POST /api/login - Login`);
  console.log(`   GET /api/notes - Get all notes (auth required)`);
  console.log(`   POST /api/notes - Create note (auth required)`);
  console.log(`   PUT /api/notes/:id - Update note (auth required)`);
  console.log(`   DELETE /api/notes/:id - Delete note (auth required)`);
  console.log(`\n🚀 Ready to accept requests!\n`);
});
