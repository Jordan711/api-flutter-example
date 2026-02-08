/**
 * DATABASE.JS - Handles all database operations
 *
 * This file sets up SQLite database and provides functions to:
 * - Create tables (users and notes)
 * - Add, get, update, delete users and notes
 *
 * SQLite is a file-based database - no server setup needed!
 * The database file (notes.db) is created automatically.
 */

const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcryptjs');

// Create or open the database file
// If notes.db doesn't exist, it will be created automatically
const db = new sqlite3.Database('notes.db', (err) => {
  if (err) {
    console.error('Error opening database:', err);
  }
});

/**
 * Initialize the database - Create tables if they don't exist
 * This runs when the server starts
 */
function initDatabase() {
  // Create users table
  // This stores user accounts with encrypted passwords
  db.serialize(() => {
    db.run(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create notes table
    // Each note is linked to a user via user_id (foreign key)
    db.run(`
      CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `, (err) => {
      if (err) {
        console.error('Error creating tables:', err);
      } else {
        console.log('✅ Database initialized successfully');
      }
    });
  });
}

/**
 * USER FUNCTIONS
 */

/**
 * Create a new user account
 * @param {string} username - The username (must be unique)
 * @param {string} password - The plain text password (will be hashed)
 * @returns {object} The created user (without password)
 */
function createUser(username, password) {
  // Hash the password before storing
  // bcrypt adds salt and encrypts the password - it's one-way (can't be decrypted)
  const passwordHash = bcrypt.hashSync(password, 10);

  return new Promise((resolve, reject) => {
    // Prepare SQL statement (prevents SQL injection)
    db.run(
      'INSERT INTO users (username, password_hash) VALUES (?, ?)',
      [username, passwordHash],
      function(err) {
        if (err) {
          reject(err);
        } else {
          // Return the new user (without the password hash for security)
          resolve({
            id: this.lastID,
            username: username,
            created_at: new Date().toISOString()
          });
        }
      }
    );
  });
}

/**
 * Find a user by username
 * @param {string} username - The username to search for
 * @returns {object|null} The user object or null if not found
 */
function getUserByUsername(username) {
  return new Promise((resolve, reject) => {
    db.get(
      'SELECT * FROM users WHERE username = ?',
      [username],
      (err, row) => {
        if (err) {
          reject(err);
        } else {
          resolve(row || null);
        }
      }
    );
  });
}

/**
 * Find a user by ID
 * @param {number} userId - The user ID
 * @returns {object|null} The user object or null if not found
 */
function getUserById(userId) {
  return new Promise((resolve, reject) => {
    db.get(
      'SELECT id, username, created_at FROM users WHERE id = ?',
      [userId],
      (err, row) => {
        if (err) {
          reject(err);
        } else {
          resolve(row || null);
        }
      }
    );
  });
}

/**
 * Verify user password
 * @param {string} username - The username
 * @param {string} password - The plain text password to check
 * @returns {object|null} The user object if password matches, null otherwise
 */
async function verifyUser(username, password) {
  try {
    const user = await getUserByUsername(username);

    // If user doesn't exist, return null
    if (!user) {
      return null;
    }

    // Compare the provided password with the stored hash
    // bcrypt.compareSync handles the comparison securely
    const isValid = bcrypt.compareSync(password, user.password_hash);

    if (isValid) {
      // Return user without password hash
      const { password_hash, ...userWithoutPassword } = user;
      return userWithoutPassword;
    }

    return null;
  } catch (error) {
    throw error;
  }
}

/**
 * NOTES FUNCTIONS
 */

/**
 * Get all notes for a specific user
 * @param {number} userId - The user ID
 * @returns {array} Array of note objects
 */
function getNotesByUserId(userId) {
  return new Promise((resolve, reject) => {
    db.all(
      'SELECT * FROM notes WHERE user_id = ? ORDER BY updated_at DESC',
      [userId],
      (err, rows) => {
        if (err) {
          reject(err);
        } else {
          resolve(rows || []);
        }
      }
    );
  });
}

/**
 * Get a single note by ID (with user ownership check)
 * @param {number} noteId - The note ID
 * @param {number} userId - The user ID (to verify ownership)
 * @returns {object|null} The note object or null
 */
function getNoteById(noteId, userId) {
  return new Promise((resolve, reject) => {
    db.get(
      'SELECT * FROM notes WHERE id = ? AND user_id = ?',
      [noteId, userId],
      (err, row) => {
        if (err) {
          reject(err);
        } else {
          resolve(row || null);
        }
      }
    );
  });
}

/**
 * Create a new note
 * @param {number} userId - The user ID (who owns this note)
 * @param {string} title - Note title
 * @param {string} content - Note content
 * @param {string} tags - Comma-separated tags
 * @returns {object} The created note
 */
async function createNote(userId, title, content, tags = '') {
  return new Promise((resolve, reject) => {
    db.run(
      'INSERT INTO notes (user_id, title, content, tags) VALUES (?, ?, ?, ?)',
      [userId, title, content, tags],
      async function(err) {
        if (err) {
          reject(err);
        } else {
          try {
            // Get the created note
            const note = await getNoteById(this.lastID, userId);
            resolve(note);
          } catch (error) {
            reject(error);
          }
        }
      }
    );
  });
}

/**
 * Update an existing note
 * @param {number} noteId - The note ID to update
 * @param {number} userId - The user ID (to verify ownership)
 * @param {string} title - New title
 * @param {string} content - New content
 * @param {string} tags - New tags
 * @returns {object|null} The updated note or null if not found/unauthorized
 */
async function updateNote(noteId, userId, title, content, tags) {
  try {
    // First check if the note exists and belongs to the user
    const existingNote = await getNoteById(noteId, userId);
    if (!existingNote) {
      return null;
    }

    return new Promise((resolve, reject) => {
      // Update the note and set updated_at to current time
      db.run(
        'UPDATE notes SET title = ?, content = ?, tags = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?',
        [title, content, tags, noteId, userId],
        async function(err) {
          if (err) {
            reject(err);
          } else {
            try {
              // Return the updated note
              const updatedNote = await getNoteById(noteId, userId);
              resolve(updatedNote);
            } catch (error) {
              reject(error);
            }
          }
        }
      );
    });
  } catch (error) {
    throw error;
  }
}

/**
 * Delete a note
 * @param {number} noteId - The note ID to delete
 * @param {number} userId - The user ID (to verify ownership)
 * @returns {boolean} True if deleted, false if not found/unauthorized
 */
async function deleteNote(noteId, userId) {
  try {
    // First check if the note exists and belongs to the user
    const existingNote = await getNoteById(noteId, userId);
    if (!existingNote) {
      return false;
    }

    return new Promise((resolve, reject) => {
      db.run(
        'DELETE FROM notes WHERE id = ? AND user_id = ?',
        [noteId, userId],
        function(err) {
          if (err) {
            reject(err);
          } else {
            resolve(this.changes > 0);
          }
        }
      );
    });
  } catch (error) {
    throw error;
  }
}

/**
 * USER ACCOUNT MANAGEMENT
 */

/**
 * Change user password
 * @param {number} userId - The user ID
 * @param {string} oldPassword - Current password for verification
 * @param {string} newPassword - New password to set
 * @returns {boolean} True if password changed successfully
 */
async function changePassword(userId, oldPassword, newPassword) {
  try {
    // Get the user
    const user = await new Promise((resolve, reject) => {
      db.get('SELECT * FROM users WHERE id = ?', [userId], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (!user) {
      return false;
    }

    // Verify old password
    const isValid = bcrypt.compareSync(oldPassword, user.password_hash);
    if (!isValid) {
      return false;
    }

    // Hash new password
    const newPasswordHash = bcrypt.hashSync(newPassword, 10);

    // Update password
    return new Promise((resolve, reject) => {
      db.run(
        'UPDATE users SET password_hash = ? WHERE id = ?',
        [newPasswordHash, userId],
        function(err) {
          if (err) {
            reject(err);
          } else {
            resolve(this.changes > 0);
          }
        }
      );
    });
  } catch (error) {
    throw error;
  }
}

/**
 * Delete user account and all associated notes
 * @param {number} userId - The user ID to delete
 * @param {string} password - Password for verification
 * @returns {boolean} True if account deleted successfully
 */
async function deleteUserAccount(userId, password) {
  try {
    // Get the user
    const user = await new Promise((resolve, reject) => {
      db.get('SELECT * FROM users WHERE id = ?', [userId], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (!user) {
      return false;
    }

    // Verify password
    const isValid = bcrypt.compareSync(password, user.password_hash);
    if (!isValid) {
      return false;
    }

    // Delete all user's notes first (due to foreign key constraint)
    await new Promise((resolve, reject) => {
      db.run('DELETE FROM notes WHERE user_id = ?', [userId], (err) => {
        if (err) reject(err);
        else resolve();
      });
    });

    // Delete the user
    return new Promise((resolve, reject) => {
      db.run('DELETE FROM users WHERE id = ?', [userId], function(err) {
        if (err) {
          reject(err);
        } else {
          resolve(this.changes > 0);
        }
      });
    });
  } catch (error) {
    throw error;
  }
}

// Export all functions so they can be used in server.js
module.exports = {
  initDatabase,
  createUser,
  getUserByUsername,
  getUserById,
  verifyUser,
  getNotesByUserId,
  getNoteById,
  createNote,
  updateNote,
  deleteNote,
  changePassword,
  deleteUserAccount
};
